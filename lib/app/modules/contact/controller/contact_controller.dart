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

class ContactController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  final isPageLoading = false.obs;
  final error = ''.obs;
  final box = GetStorage();
  final boxUserData = {}.obs;

  final FormApiService _formService = FormApiService();

  static const _cacheKey = 'cms_page_contact_sections';
  static const _schemaCacheKey = 'cms_form_schema_contact';

  // Server-driven sections state
  final rawSections = <dynamic>[].obs;
  final sectionsData = ContactBroadcastSectionsData.canonical().obs;

  // FAQ accordion state
  final expandedFaqIndex = RxnInt(0); // Default first item open

  // Dynamic schema-driven form state
  final formFields = <FormSchemaField>[].obs;
  final isFormSchemaLoading = false.obs;
  final Map<String, TextEditingController> fieldControllers = {};
  final RxBool agreePolicy = true.obs;
  String currentFormSlug = 'contact';

  // Legacy controllers for backwards compatibility
  TextEditingController get nameController =>
      _controllerForName('full_name', fallbackType: 'text');
  TextEditingController get emailController =>
      _controllerForName('email', fallbackType: 'email');
  TextEditingController get phoneController =>
      _controllerForName('phone', fallbackType: 'tel');
  TextEditingController get messageController =>
      _controllerForName('message', fallbackType: 'textarea');

  TextEditingController _controllerForName(String key,
      {String fallbackType = 'text'}) {
    if (!fieldControllers.containsKey(key)) {
      fieldControllers[key] = TextEditingController();
      _prefillField(key, fallbackType, fieldControllers[key]!);
    }
    return fieldControllers[key]!;
  }

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
    final user = boxUserData["user"] ?? boxUserData["userData"] ?? boxUserData;
    if (user is! Map) return;

    final userName = user["name"] ?? user["first_name"] ?? '';
    final userEmail = user["email"] ?? '';
    final userMobile = user["mobile"] ?? user["phone"] ?? '';

    final lowerName = fieldName.toLowerCase();
    final lowerType = fieldType.toLowerCase();

    if (lowerType == 'email' || lowerName.contains('email')) {
      if (userEmail.toString().isNotEmpty) ctrl.text = userEmail.toString();
    } else if (lowerType == 'tel' ||
        lowerName.contains('phone') ||
        lowerName.contains('mobile')) {
      if (userMobile.toString().isNotEmpty) ctrl.text = userMobile.toString();
    } else if (lowerName.contains('name')) {
      if (userName.toString().isNotEmpty) ctrl.text = userName.toString();
    }
  }

  @override
  void onInit() {
    super.onInit();
    final userDetails = box.read('userDetails');
    if (userDetails is Map) {
      boxUserData.value = userDetails['userData'] ?? userDetails;
    }

    _loadCached();
    _loadCachedFormSchema();

    fetchContactLayout();
  }

  void _loadCached() {
    try {
      final cachedSections = box.read(_cacheKey);
      if (cachedSections is List && cachedSections.isNotEmpty) {
        rawSections.assignAll(cachedSections);
        sectionsData.value =
            ContactBroadcastSectionsData.fromSections(cachedSections);
      }
    } catch (_) {}
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

  /// Intercepts both initial fetch and live WebSocket broadcasts from FoduuStudioLayoutMixin
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (sections.isNotEmpty) {
      rawSections.assignAll(sections);
      sectionsData.value = ContactBroadcastSectionsData.fromSections(sections);
      try {
        box.write(_cacheKey, sections);
      } catch (_) {}

      final newSlug = sectionsData.value.formBuilder.formSlug;
      if (newSlug.isNotEmpty && newSlug != currentFormSlug) {
        currentFormSlug = newSlug;
        fetchFormSchema(newSlug);
      }
    }
  }

  /// 3-Tier resilient fetching for Contact Us layout
  Future<void> fetchContactLayout() async {
    isPageLoading(true);
    error('');

    try {
      // Tier 1: Fastify CMS layout (GET /api/mobile-app/contact-us)
      try {
        final response = await fetchLayout('contact-us');
        if (response != null && response is Map) {
          final list = response['sections'];
          if (list is List && list.isNotEmpty) {
            rawSections.assignAll(list);
            sectionsData.value = ContactBroadcastSectionsData.fromSections(list);
            try {
              box.write(_cacheKey, list);
            } catch (_) {}

            final formSlug = sectionsData.value.formBuilder.formSlug;
            currentFormSlug = formSlug.isNotEmpty ? formSlug : 'contact';
            await fetchFormSchema(currentFormSlug);
            return;
          }
        }
      } catch (cmsError) {
        debugPrint('ContactController: Tier 1 CMS fetchLayout error: $cmsError');
      }

      // Tier 2: Cached layout fallback
      if (rawSections.isNotEmpty) {
        sectionsData.value =
            ContactBroadcastSectionsData.fromSections(rawSections);
      } else {
        // Tier 3: Website Canonical Defaults (foduu-electronics-store.foduu.store/contact-us)
        sectionsData.value = ContactBroadcastSectionsData.canonical();
      }
      await fetchFormSchema(currentFormSlug);
    } catch (e) {
      debugPrint("ContactController.fetchContactLayout error: $e");
      if (sectionsData.value.channels.cards.isEmpty) {
        error('Unable to load Contact page');
      }
    } finally {
      isPageLoading(false);
    }
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
      debugPrint("fetchFormSchema error: $e");
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

    if (!agreePolicy.value) {
      HelperFunctions().showSnackBarError(
          'Please agree with the site privacy policy to continue.');
      return;
    }

    isSubmitting(true);
    try {
      await _submit();
    } catch (e) {
      debugPrint("sendFormData error: $e");
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> _submit() async {
    final Map<String, dynamic> payload = {};

    for (final field in formFields) {
      final ctrl = fieldControllers[field.name];
      final val = ctrl?.text.trim() ?? '';
      payload[field.name] = val;
    }

    // Add metadata
    payload['type'] = Platform.isAndroid ? 'Android App' : 'iOS App';
    if (agreePolicy.value) {
      payload['check-box'] = ["I agree with the site privacy policy"];
    }

    try {
      final response =
          await _formService.submitForm(currentFormSlug, payload);

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

      // Reset form fields
      for (final ctrl in fieldControllers.values) {
        ctrl.clear();
      }
    } catch (e) {
      handleError(e);
    }
  }
}
