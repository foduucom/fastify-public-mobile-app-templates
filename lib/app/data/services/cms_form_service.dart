import 'dart:convert';

import '/app/data/basic_provider.dart';
import '/app/data/models/form_schema_model.dart';

class CmsFormService {
  static const _nonInputTypes = {
    'submit',
    'button',
    'reset',
    'captcha',
    'header',
    'paragraph',
    'hidden',
    'total',
  };

  Future<List<FormSchemaField>> loadFields(String formSlug) async {
    final slug = _safeSlug(formSlug);
    Object? primaryError;
    try {
      final response = await BasicProvider('forms/$slug').getRequest();
      final fields = _extractFields(response);
      if (fields.isNotEmpty) return fields;
    } catch (error) {
      primaryError = error;
    }

    try {
      final fallback = await BasicProvider('form-builder/$slug').getRequest();
      final content = _readContent(fallback);
      final fromRows = _fieldsFromRows(content is Map
          ? content['content_json'] ?? content['content'] ?? content
          : content);
      if (fromRows.isNotEmpty) return fromRows;
    } catch (_) {
      // Report the primary API failure below when both schema endpoints fail.
    }
    if (primaryError != null) {
      throw StateError('Unable to load this form schema: $primaryError');
    }
    throw StateError('This form has no available fields.');
  }

  Future<dynamic> submit(String formSlug, Map<String, dynamic> payload) {
    return BasicProvider('forms/${_safeSlug(formSlug)}/submit')
        .postRequest(payload);
  }

  static String _safeSlug(String value) {
    final slug = value.trim();
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(slug)) {
      return 'contact';
    }
    return slug;
  }

  List<FormSchemaField> _extractFields(dynamic response) {
    final content = _readContent(response);
    if (content is List) return _mapFields(content);
    if (content is Map) {
      final candidates = [
        content['fields'],
        content['form_fields'],
        content['schema'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          final fields = _mapFields(candidate);
          if (fields.isNotEmpty) return fields;
        }
      }
      return _fieldsFromRows(content['content_json'] ?? content['content']);
    }
    return const [];
  }

  dynamic _readContent(dynamic value) {
    dynamic current = value;
    for (var depth = 0; depth < 4; depth++) {
      if (current is String) {
        try {
          current = jsonDecode(current);
        } catch (_) {
          return current;
        }
      }
      if (current is! Map) return current;
      if (current['fields'] is List ||
          current['form_fields'] is List ||
          current['schema'] is List) {
        return current;
      }
      final next = current['data'] ??
          current['content_json'] ??
          current['contentJson'] ??
          current['form'];
      if (next == null) return current;
      current = next;
    }
    return current;
  }

  List<FormSchemaField> _mapFields(List rawFields) => rawFields
      .whereType<Map>()
      .map(FormSchemaField.fromJson)
      .where((field) =>
          field.name.isNotEmpty && !_nonInputTypes.contains(field.type))
      .toList(growable: false);

  List<FormSchemaField> _fieldsFromRows(dynamic content) {
    if (content is! List) return const [];
    final fields = <FormSchemaField>[];
    for (final row in content) {
      if (row is! Map) continue;
      final columns = row['columns'];
      if (columns is! List) continue;
      for (final column in columns) {
        if (column is! Map || column['fields'] is! List) continue;
        fields.addAll(_mapFields(column['fields'] as List));
      }
    }
    return fields;
  }
}
