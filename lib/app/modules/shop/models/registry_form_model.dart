class RegistryFormFieldOption {
  final String label;
  final String value;

  RegistryFormFieldOption({required this.label, required this.value});

  factory RegistryFormFieldOption.fromJson(Map<String, dynamic> json) {
    return RegistryFormFieldOption(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? json['label']?.toString() ?? '',
    );
  }
}

class RegistryFormField {
  final String id;
  final String type;
  final String name;
  final String label;
  final String placeholder;
  final bool required;
  final int min;
  final int rows;
  final List<RegistryFormFieldOption> options;

  RegistryFormField({
    required this.id,
    required this.type,
    required this.name,
    required this.label,
    required this.placeholder,
    required this.required,
    required this.min,
    required this.rows,
    required this.options,
  });

  factory RegistryFormField.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    List<RegistryFormFieldOption> opts = [];
    if (rawOptions is List) {
      for (var o in rawOptions) {
        if (o is Map<String, dynamic>) {
          opts.add(RegistryFormFieldOption.fromJson(o));
        } else if (o is String) {
          opts.add(RegistryFormFieldOption(label: o, value: o));
        }
      }
    }
    return RegistryFormField(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      placeholder: json['placeholder']?.toString() ?? '',
      required: json['required'] == true,
      min: json['min'] is num
          ? (json['min'] as num).toInt()
          : int.tryParse(json['min']?.toString() ?? '') ?? 1,
      rows: json['rows'] is num
          ? (json['rows'] as num).toInt()
          : int.tryParse(json['rows']?.toString() ?? '') ?? 3,
      options: opts,
    );
  }
}

class RegistryForm {
  final String id;
  final String name;
  final String submitEndpoint;
  final List<RegistryFormField> fields;

  RegistryForm({
    required this.id,
    required this.name,
    required this.submitEndpoint,
    required this.fields,
  });

  factory RegistryForm.fromJson(Map<String, dynamic> json) {
    final rawItems = json['content_json'];
    final List<RegistryFormField> fields = [];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is! Map<String, dynamic>) continue;
        final type = item['type']?.toString() ?? '';
        if (type == 'hidden') {
          fields.add(RegistryFormField.fromJson(item));
        } else if (type == 'row-layout') {
          final columns = item['columns'];
          if (columns is List) {
            for (final col in columns) {
              if (col is! Map) continue;
              final colFields = col['fields'];
              if (colFields is List) {
                for (final f in colFields) {
                  if (f is Map<String, dynamic>) {
                    fields.add(RegistryFormField.fromJson(f));
                  } else if (f is Map) {
                    fields.add(
                        RegistryFormField.fromJson(f.cast<String, dynamic>()));
                  }
                }
              }
            }
          }
        }
      }
    }

    final slug = json['slug']?.toString() ?? '';
    return RegistryForm(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      submitEndpoint: 'forms/$slug/submit',
      fields: fields,
    );
  }
}
