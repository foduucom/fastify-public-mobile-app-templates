import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foddu/app/data/models/form_schema_model.dart';
import 'package:foddu/app/data/services/cms_form_service.dart';
import 'package:get/get.dart';

class CmsFormBuilderSection extends StatefulWidget {
  const CmsFormBuilderSection({super.key, required this.content});

  final Map<String, dynamic> content;

  @override
  State<CmsFormBuilderSection> createState() => _CmsFormBuilderSectionState();
}

class _CmsFormBuilderSectionState extends State<CmsFormBuilderSection> {
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

  final _formKey = GlobalKey<FormState>();
  final _service = CmsFormService();
  final _controllers = <String, TextEditingController>{};
  final _selectedOptions = <String, String>{};
  final _checks = <String, bool>{};
  List<FormSchemaField> _fields = const [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  String get _formSlug {
    final id = widget.content['form_id'];
    final nestedSlug = id is Map ? id['slug'] : null;
    return (widget.content['form_slug'] ?? nestedSlug ?? 'contact').toString();
  }

  String get _title =>
      (widget.content['title'] ?? 'Send us a message').toString().trim();

  String get _submitLabel =>
      (widget.content['submit_label'] ?? 'Submit').toString();

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    final inline = _parseInlineFields(widget.content);
    if (inline.isNotEmpty) {
      _setFields(inline);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _setFields(await _service.loadFields(_formSlug));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Bad state:', '').trim();
        _loading = false;
      });
    }
  }

  List<FormSchemaField> _parseInlineFields(Map<String, dynamic> content) {
    final direct = content['fields'] ?? content['form_fields'];
    if (direct is List) {
      return direct
          .whereType<Map>()
          .map(FormSchemaField.fromJson)
          .where((field) =>
              field.name.isNotEmpty && !_nonInputTypes.contains(field.type))
          .toList();
    }
    final rows = content['content_json'] ?? content['content'];
    if (rows is! List) return const [];
    final fields = <FormSchemaField>[];
    for (final row in rows) {
      if (row is! Map || row['columns'] is! List) continue;
      for (final column in row['columns'] as List) {
        if (column is Map && column['fields'] is List) {
          fields.addAll((column['fields'] as List)
              .whereType<Map>()
              .map(FormSchemaField.fromJson)
              .where((field) =>
                  field.name.isNotEmpty &&
                  !_nonInputTypes.contains(field.type)));
        }
      }
    }
    return fields;
  }

  void _setFields(List<FormSchemaField> fields) {
    if (!mounted) return;
    for (final field in fields) {
      _controllers.putIfAbsent(field.name, TextEditingController.new);
      if (field.options.isNotEmpty) {
        _selectedOptions.putIfAbsent(field.name, () => '');
      }
      _checks.putIfAbsent(field.name, () => false);
    }
    setState(() {
      _fields = fields;
      _loading = false;
      _error = fields.isEmpty ? 'This form has no fields yet.' : null;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final payload = <String, dynamic>{};
      for (final field in _fields) {
        if (field.options.isNotEmpty) {
          payload[field.name] = _selectedOptions[field.name] ?? '';
        } else if (field.type == 'checkbox') {
          payload[field.name] = _checks[field.name] ?? false;
        } else {
          payload[field.name] = _controllers[field.name]?.text.trim() ?? '';
        }
      }
      payload['type'] = Platform.isAndroid ? 'Android App' : 'iOS App';
      final response = await _service.submit(_formSlug, payload);
      if (response == null) {
        throw StateError('The form could not be submitted.');
      }
      if (!mounted) return;
      final responseMessage = response is Map
          ? (response['message'] ?? response['data'])?.toString()
          : null;
      Get.snackbar(
        'Submitted',
        responseMessage?.isNotEmpty == true
            ? responseMessage!
            : 'Thanks. Your message has been sent.',
        snackPosition: SnackPosition.BOTTOM,
      );
      for (final controller in _controllers.values) {
        controller.clear();
      }
      _selectedOptions.updateAll((_, __) => '');
      _checks.updateAll((_, __) => false);
      _formKey.currentState?.reset();
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Unable to submit',
        e.toString().replaceFirst('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_title.isEmpty ? 'Send us a message' : _title,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                _buildError(context)
              else
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      for (final field in _fields) ...[
                        _buildField(context, field),
                        const SizedBox(height: 14),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_submitLabel),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _loading ? null : _loadFields,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context, FormSchemaField field) {
    final label = field.label.isEmpty ? field.name : field.label;
    if (field.options.isNotEmpty ||
        const {'select', 'dropdown', 'radio'}.contains(field.type)) {
      final hasOptions = field.options.isNotEmpty;
      return DropdownButtonFormField<String>(
        initialValue: _selectedOptions[field.name]?.isEmpty == true
            ? null
            : _selectedOptions[field.name],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: field.options
            .map((option) => DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ))
            .toList(),
        validator: (value) => !hasOptions
            ? 'No options are configured for $label.'
            : field.required && value == null
                ? 'Please select $label.'
                : null,
        hint: Text(hasOptions ? 'Select $label' : 'Options unavailable'),
        isExpanded: true,
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedOptions[field.name] = value);
          }
        },
      );
    }
    if (field.type == 'checkbox') {
      return FormField<bool>(
        initialValue: _checks[field.name] ?? false,
        validator: (value) =>
            field.required && value != true ? 'Please confirm $label.' : null,
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              value: _checks[field.name] ?? false,
              onChanged: (value) {
                final checked = value ?? false;
                setState(() => _checks[field.name] = checked);
                state.didChange(checked);
              },
            ),
            if (state.hasError)
              Text(state.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      );
    }
    final type = field.type;
    final isMultiline = type == 'textarea' || type == 'paragraph';
    return TextFormField(
      controller: _controllers[field.name],
      keyboardType: type == 'email'
          ? TextInputType.emailAddress
          : type == 'tel' || type == 'phone'
              ? TextInputType.phone
              : type == 'number'
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : isMultiline
                      ? TextInputType.multiline
                      : TextInputType.text,
      maxLines: isMultiline ? 4 : 1,
      validator: field.validate,
      decoration: InputDecoration(
        labelText: label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
