import 'package:get/get.dart';

class FormSchemaOption {
  const FormSchemaOption({required this.label, required this.value});

  final String label;
  final String value;

  factory FormSchemaOption.fromJson(dynamic json) {
    if (json is Map) {
      final label =
          (json['label'] ?? json['name'] ?? json['value'] ?? '').toString();
      return FormSchemaOption(
        label: label,
        value: (json['value'] ?? json['id'] ?? label).toString(),
      );
    }
    final text = json?.toString() ?? '';
    return FormSchemaOption(label: text, value: text);
  }
}

class FormSchemaField {
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

  final String name;
  final String type;
  final String label;
  final bool required;
  final String placeholder;
  final int? min;
  final int? max;
  final List<FormSchemaOption> options;

  factory FormSchemaField.fromJson(Map json) {
    final rawOptions = json['options'] ?? json['values'];
    return FormSchemaField(
      name: (json['name'] ?? json['key'] ?? json['id'] ?? '').toString().trim(),
      type: (json['type'] ?? 'text').toString().trim().toLowerCase(),
      label: (json['label'] ?? json['title'] ?? json['name'] ?? '').toString(),
      required: json['required'] == true ||
          const {'true', '1', 'yes'}
              .contains(json['required']?.toString().trim().toLowerCase()),
      placeholder: (json['placeholder'] ?? json['hint'] ?? '').toString(),
      min: int.tryParse((json['min'] ?? json['min_length'] ?? '').toString()),
      max: int.tryParse((json['max'] ?? json['max_length'] ?? '').toString()),
      options: rawOptions is List
          ? rawOptions.map(FormSchemaOption.fromJson).toList()
          : const [],
    );
  }

  String? validate(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (required && text.isEmpty) return 'Please enter $label.';
    if (text.isEmpty) return null;

    if (type == 'email' && !GetUtils.isEmail(text)) {
      return 'Enter a valid email address.';
    }
    if (type == 'tel' || type == 'phone') {
      final digits = text.replaceAll(RegExp(r'\D'), '');
      if (digits.length < (min ?? 7)) return 'Enter a valid phone number.';
      if (max != null && digits.length > max!) {
        return 'Phone number is too long.';
      }
    }
    if (type == 'number') {
      final number = num.tryParse(text);
      if (number == null) return 'Enter a valid number.';
      if (min != null && number < min!) return 'Minimum value is $min.';
      if (max != null && number > max!) return 'Maximum value is $max.';
    }
    if (min != null && text.length < min! && type != 'number') {
      return 'Enter at least $min characters.';
    }
    if (max != null && text.length > max! && type != 'number') {
      return 'Enter no more than $max characters.';
    }
    return null;
  }
}
