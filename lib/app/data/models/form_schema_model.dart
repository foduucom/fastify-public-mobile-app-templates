class FormSchemaOption {
  final String label;
  final String value;

  const FormSchemaOption({required this.label, required this.value});

  factory FormSchemaOption.fromJson(Map<String, dynamic> json) {
    return FormSchemaOption(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  @override
  String toString() => label;
}

class FormSchemaField {
  final String name;
  final String type;
  final String label;
  final bool required;
  final String placeholder;
  final int? min;
  final int? max;
  final List<FormSchemaOption> options;

  const FormSchemaField({
    required this.name,
    required this.type,
    required this.label,
    required this.required,
    required this.placeholder,
    this.min,
    this.max,
    this.options = const [],
  });

  factory FormSchemaField.fromJson(Map<String, dynamic> json) {
    List<FormSchemaOption> parsedOptions = [];
    final rawOptions = json['options'];
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        if (opt is Map<String, dynamic>) {
          parsedOptions.add(FormSchemaOption.fromJson(opt));
        } else if (opt is Map) {
          parsedOptions.add(FormSchemaOption.fromJson(Map<String, dynamic>.from(opt)));
        } else if (opt is String) {
          parsedOptions.add(FormSchemaOption(label: opt, value: opt));
        }
      }
    }

    int? parseBound(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString().trim());
    }

    return FormSchemaField(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'text',
      label: json['label']?.toString() ?? '',
      required: json['required'] == true ||
          json['required']?.toString().toLowerCase() == 'true',
      placeholder: json['placeholder']?.toString() ?? '',
      min: parseBound(json['min']),
      max: parseBound(json['max']),
      options: parsedOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'label': label,
      'required': required,
      'placeholder': placeholder,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (options.isNotEmpty) 'options': options.map((e) => e.toJson()).toList(),
    };
  }

  /// Validates an input value against field specification and returns error message if invalid.
  String? validate(dynamic value) {
    final strVal = value?.toString().trim() ?? '';

    if (required) {
      if (type == 'checkbox') {
        if (value == null || (value is List && value.isEmpty) || strVal.isEmpty) {
          return '$label is required.';
        }
      } else if (strVal.isEmpty) {
        return '$label is required.';
      }
    }

    if (strVal.isEmpty) return null;

    if (type == 'email') {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(strVal)) {
        return 'Please enter a valid email address.';
      }
    }

    if (type == 'tel') {
      final digits = strVal.replaceAll(RegExp(r'[^0-9]'), '');
      final effectiveMin = min ?? 10;
      final effectiveMax = max ?? 15;
      if (digits.length < effectiveMin) {
        return '$label must be at least $effectiveMin digits.';
      }
      if (digits.length > effectiveMax) {
        return '$label cannot exceed $effectiveMax digits.';
      }
    }

    if (type == 'number') {
      final numVal = double.tryParse(strVal);
      if (numVal == null) return '$label must be a valid number.';
      if (min != null && numVal < min!) return '$label must be at least $min.';
      if (max != null && numVal > max!) return '$label cannot exceed $max.';
    }

    if (type == 'text' || type == 'textarea') {
      final effectiveMin = min ?? (required ? 3 : null);
      if (effectiveMin != null && strVal.length < effectiveMin) {
        return '$label must be at least $effectiveMin characters.';
      }
      if (max != null && strVal.length > max!) {
        return '$label cannot exceed $max characters.';
      }
    }

    return null;
  }

  /// Safe default schema based on GET /api/forms/contact-form specifications
  /// ensures immediate rendering without layout flicker.
  static List<FormSchemaField> get fallbackContactFormSchema => const [
        FormSchemaField(
          name: 'Name',
          type: 'text',
          label: 'Name',
          required: true,
          placeholder: 'Enter Name.....',
        ),
        FormSchemaField(
          name: 'field_1788010042053',
          type: 'email',
          label: 'Email Address',
          required: false,
          placeholder: 'Enter email...',
        ),
        FormSchemaField(
          name: 'field_1788010055717',
          type: 'tel',
          label: 'Phone Number',
          required: false,
          placeholder: 'Enter phone...',
        ),
        FormSchemaField(
          name: 'message',
          type: 'text',
          label: 'Message',
          required: false,
          placeholder: 'Leave a Message....',
        ),
      ];
}
