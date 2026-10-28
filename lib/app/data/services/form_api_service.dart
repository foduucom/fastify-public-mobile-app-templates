import 'package:flutter/foundation.dart' show debugPrint;
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/form_schema_model.dart';

class FormApiService {
  /// Fetches dynamic schema for a given form slug (e.g. 'contact-form').
  /// Primary endpoint: GET /api/forms/{formSlug}
  /// Fallback endpoint: GET /api/form-builder/{formSlug}
  Future<List<FormSchemaField>> getFormSchema(String formSlug) async {
    final slug = formSlug.trim().isEmpty ? 'contact-form' : formSlug.trim();

    // 1. Try GET /api/forms/{slug} (Form Builder API Guide Section 3)
    try {
      final response = await BasicProvider("forms/$slug", showSnackBar: false)
          .getRequest();

      if (response != null) {
        dynamic fieldList;
        if (response is List) {
          fieldList = response;
        } else if (response is Map && response['data'] is List) {
          fieldList = response['data'];
        }

        if (fieldList is List && fieldList.isNotEmpty) {
          final fields = fieldList
              .whereType<Map>()
              .map((e) => FormSchemaField.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (fields.isNotEmpty) return fields;
        }
      }
    } catch (e) {
      debugPrint("FormApiService.getFormSchema (forms/$slug) error: $e");
    }

    // 2. Try GET /api/form-builder/{slug} (log2.txt fallback)
    try {
      final fbResponse = await BasicProvider("form-builder/$slug",
              showSnackBar: false)
          .getRequest();

      if (fbResponse != null && fbResponse is Map) {
        final data = fbResponse['data'];
        if (data is Map) {
          final contentJson = data['content_json'];
          final extracted = _extractFieldsFromContentJson(contentJson);
          if (extracted.isNotEmpty) return extracted;
        }
      }
    } catch (e) {
      debugPrint("FormApiService.getFormSchema (form-builder/$slug) error: $e");
    }

    // 3. Fallback to canonical fields
    return FormSchemaField.fallbackContactFormSchema;
  }

  /// Traverses raw FormBuilder rows -> columns -> fields to extract valid input fields.
  List<FormSchemaField> _extractFieldsFromContentJson(dynamic contentJson) {
    if (contentJson is! List) return [];
    final List<FormSchemaField> fields = [];

    const nonInputTypes = {
      'submit',
      'button',
      'captcha',
      'reset',
      'header',
      'paragraph',
      'hidden',
      'total'
    };

    for (final row in contentJson) {
      if (row is! Map) continue;
      final columns = row['columns'];
      if (columns is! List) continue;

      for (final col in columns) {
        if (col is! Map) continue;
        final rawFields = col['fields'];
        if (rawFields is! List) continue;

        for (final f in rawFields) {
          if (f is! Map) continue;
          final type = f['type']?.toString().toLowerCase() ?? '';
          if (nonInputTypes.contains(type)) continue;

          final fieldMap = Map<String, dynamic>.from(f);
          fields.add(FormSchemaField.fromJson(fieldMap));
        }
      }
    }

    return fields;
  }

  /// Submits form payload to POST /api/forms/{formSlug}/submit with raw JSON body.
  Future<dynamic> submitForm(
      String formSlug, Map<String, dynamic> payload) async {
    final slug = formSlug.trim().isEmpty ? 'contact-form' : formSlug.trim();
    try {
      final response =
          await BasicProvider("forms/$slug/submit").postRequest(payload);
      return response;
    } catch (e) {
      debugPrint("FormApiService.submitForm error ($slug): $e");
      rethrow;
    }
  }
}
