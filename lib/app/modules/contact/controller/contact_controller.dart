import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/models/contact_sections.dart';
import 'package:foduu_ecommerce/app/data/models/form_schema_model.dart';
import 'package:foduu_ecommerce/app/data/services/form_api_service.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller for the Contact Us screen, driven by Foduu Studio CMS
/// (`mobile-app/contact`) and live WebSocket broadcasting.
class ContactController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  final box = GetStorage();
  final boxUserData = {}.obs;

  final FormApiService _formService = FormApiService();

  static const _schemaCacheKey = 'cms_form_schema_contact';

  // FAQ accordion state (kept for backwards compatibility with legacy widgets)
  final expandedFaqIndex = RxnInt(0);

  // Dynamic schema-driven form state
  final formFields = <FormSchemaField>[].obs;
  final isFormSchemaLoading = false.obs;
  final Map<String, TextEditingController> fieldControllers = {};
  final RxBool agreePolicy = true.obs;
  String currentFormSlug = 'contact';

  TextEditingController controllerForField(FormSchemaField field) {
    if (!fieldControllers.containsKey(field.name)) {
      fieldControllers[field.name] = TextEditingController();
      _prefillField(field.name, field.type, fieldControllers[field.name]!);
    }
    return fieldControllers[field.name]!;
  }

  void _prefillField(
      String fieldName, String fieldType, TextEditingController ctrl) {
    if (ctrl.text.isNotEmpty || boxUserData.isEmpty) return;
    final user = boxUserData['user'] ?? boxUserData['userData'] ?? boxUserData;
    if (user is! Map) return;

    final userName =
        (user['name'] ?? user['first_name'] ?? '').toString().trim();
    final userLastName = (user['last_name'] ?? '').toString().trim();
    final userEmail = (user['email'] ?? '').toString().trim();
    final userMobile =
        (user['mobile'] ?? user['phone'] ?? '').toString().trim();

    final lowerName = fieldName.toLowerCase();
    final lowerType = fieldType.toLowerCase();

    if (lowerType == 'email' || lowerName.contains('email')) {
      if (userEmail.isNotEmpty) ctrl.text = userEmail;
    } else if (lowerType == 'tel' ||
        lowerName.contains('phone') ||
        lowerName.contains('mobile')) {
      if (userMobile.isNotEmpty) ctrl.text = userMobile;
    } else if (lowerName.contains('first')) {
      if (userName.isNotEmpty) {
        ctrl.text = userName.split(RegExp(r'\s+')).first;
      }
    } else if (lowerName.contains('last')) {
      if (userLastName.isNotEmpty) {
        ctrl.text = userLastName;
      } else if (userName.contains(' ')) {
        ctrl.text = userName.split(RegExp(r'\s+')).skip(1).join(' ');
      }
    } else if (lowerName.contains('name')) {
      if (userName.isNotEmpty) ctrl.text = userName;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final userDetails = box.read('userDetails');
    if (userDetails is Map) {
      boxUserData.value = userDetails['userData'] ?? userDetails;
    }

    _loadCachedFormSchema();
    fetchContactLayout();
  }

  void _loadCachedFormSchema() {
    try {
      final cached = box.read(_schemaCacheKey);
      if (cached is List && cached.isNotEmpty) {
        final fields = cached
            .map((e) => FormSchemaField.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (fields.isNotEmpty) {
          _updateFormFields(fields);
          return;
        }
      }
    } catch (_) {}

    _updateFormFields(FormSchemaField.fallbackContactFormSchema);
  }

  void _updateFormFields(List<FormSchemaField> fields) {
    formFields.assignAll(fields);
    for (final f in fields) {
      controllerForField(f);
    }
  }

  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    for (final sec in sections) {
      if (sec is! Map) continue;
      final type = sec['type']?.toString().toLowerCase() ?? '';
      if (type == 'formbuilder' || type == 'form_builder') {
        final content = sec['content_json'];
        if (content is Map) {
          final formData = ContactFormBuilderData.fromContentJson(
            Map<String, dynamic>.from(content),
          );
          if (formData.formSlug.isNotEmpty &&
              formData.formSlug != currentFormSlug) {
            currentFormSlug = formData.formSlug;
            fetchFormSchema(currentFormSlug);
          }
        }
      }
    }
  }

  /// Fetches the `contact-us` CMS layout and falls back to canonical
  /// `foduu-electro.foduu.store` (`log.txt`) 4-section payload if empty.
  Future<void> fetchContactLayout() async {
    await fetchLayout('contact-us');
    if (widgetList.isEmpty) {
      hasError.value = false;
      errorMessage.value = '';
      buildLayout(_canonicalFallbackSections);
    }
    await fetchFormSchema(currentFormSlug);
  }

  Future<void> fetchFormSchema(String slug) async {
    isFormSchemaLoading(true);
    try {
      final fields = await _formService.getFormSchema(slug);
      if (fields.isNotEmpty) {
        _updateFormFields(fields);
        box.write(_schemaCacheKey, fields.map((f) => f.toJson()).toList());
      }
    } catch (e) {
      debugPrint('fetchFormSchema error: $e');
    } finally {
      isFormSchemaLoading(false);
    }
  }

  void toggleFaq(int index) {
    if (expandedFaqIndex.value == index) {
      expandedFaqIndex.value = null;
    } else {
      expandedFaqIndex.value = index;
    }
  }

  @override
  void onClose() {
    for (final ctrl in fieldControllers.values) {
      ctrl.dispose();
    }
    super.onClose();
  }

  Future<void> sendFormData() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    isSubmitting(true);
    try {
      await _submit();
    } catch (e) {
      debugPrint('sendFormData error: $e');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> _submit() async {
    final Map<String, dynamic> payload = {};

    for (final field in formFields) {
      final ctrl = fieldControllers[field.name];
      payload[field.name] = ctrl?.text.trim() ?? '';
    }

    payload['type'] = Platform.isAndroid ? 'Android App' : 'iOS App';

    try {
      final response = await _formService.submitForm(currentFormSlug, payload);

      String successMessage =
          'Thank you for contacting us. We will get back to you soon.';

      if (response is Map) {
        if (response['message'] != null &&
            response['message'].toString().trim().isNotEmpty) {
          successMessage = response['message'].toString();
        } else if (response['data'] != null &&
            response['data'] is String &&
            response['data'].toString().trim().isNotEmpty) {
          successMessage = response['data'].toString();
        }
      }

      HelperFunctions().showSnackBarSuccess(successMessage);

      for (final ctrl in fieldControllers.values) {
        ctrl.clear();
      }
    } catch (e) {
      handleError(e);
    }
  }

  static final List<Map<String, dynamic>> _canonicalFallbackSections = [
    {
      'id': 'slider',
      'type': 'slider',
      'visible': true,
      'content_json': {
        'height': 200,
        'slider': {
          'slug': 'contact-us-slider',
          'content': [
            {
              'heading': 'Contact Us',
              'sub_heading': 'Get In Touch',
              'description':
                  'We are here for you! how can we help, We are here for you!',
              'filePath': '2026/11/24/contact-us-2173b173.webp',
            },
          ],
        },
      },
    },
    {
      'id': 'rich_text',
      'type': 'rich_text',
      'visible': true,
      'content_json': {
        'html_content': "Let's ConnectSend Your Message",
      },
    },
    {
      'id': 'text_block',
      'type': 'text_block',
      'visible': true,
      'content_json': {
        'text':
            'Have questions or feedback? Fill out the form below and our team will get back to you shortly.',
        'size': 16,
        'weight': 'normal',
        'alignment': 'left',
        'color': '#000000',
      },
    },
    {
      'id': 'formbuilder',
      'type': 'formbuilder',
      'visible': true,
      'content_json': {
        'form_id': {
          'value': '6b05644bd7ab01ed35811117',
          'label': 'Contact Us',
          'slug': 'contact',
        },
        'title': 'Send Your Message',
      },
    },
  ];
}
