import 'package:flutter/foundation.dart' show debugPrint;
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/form_schema_model.dart';

class FormApiService {
  /// Fetches dynamic schema for a given form slug (e.g. 'contact-form').
  /// Endpoint: GET /api/forms/{formSlug}
  Future<List<FormSchemaField>> getFormSchema(String formSlug) async {
    final slug = formSlug.trim().isEmpty ? 'contact-form' : formSlug.trim();
    try {
      final response = await BasicProvider("forms/$slug", showSnackBar: false)
          .getRequest();

      if (response == null) return [];

      dynamic fieldList;
      if (response is List) {
        fieldList = response;
      } else if (response is Map && response['data'] is List) {
        fieldList = response['data'];
      }

      if (fieldList is List) {
        return fieldList
            .whereType<Map>()
            .map((e) => FormSchemaField.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("FormApiService.getFormSchema error ($slug): $e");
      return [];
    }
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
