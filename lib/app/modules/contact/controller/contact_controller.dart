import 'package:flutter/cupertino.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/contact_broadcast_sections.dart';
import 'package:zouhi/app/data/models/form_schema_model.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/form_api_service.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controllers/api_exception_handle_controller.dart';

class ContactController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  var box = GetStorage();
  var boxUserData = {}.obs;

  final PageApiService _pageService = PageApiService();
  final FormApiService _formService = FormApiService();

  static const _cacheKey = 'cms_page_contact_sections';
  static const _legacyCacheKey = 'cms_page_contact_content';
  static const _schemaCacheKey = 'cms_form_schema_contact_form';

  // Server-Driven CMS Broadcasting Layout
  final rawSections = <dynamic>[].obs;
  final sectionsData = ContactBroadcastSectionsData.canonical().obs;
  final components = <PageComponent>[].obs;
  final isPageLoading = false.obs;
  final error = ''.obs;
  final isSubscribing = false.obs;
  late final TextEditingController newsletterController;

  // Dynamic Schema-Driven Form
  final formFields = <FormSchemaField>[].obs;
  final isFormSchemaLoading = false.obs;
  final Map<String, TextEditingController> fieldControllers = {};
  final RxBool agreePolicy = true.obs;
  String currentFormSlug = 'contact-form';

  // Legacy controllers kept for backwards compatibility
  TextEditingController get nameController =>
      _controllerForName('Name', fallbackType: 'text');
  TextEditingController get emailController =>
      _controllerForName('field_1788010042053', fallbackType: 'email');
  TextEditingController get phoneController =>
      _controllerForName('field_1788010055717', fallbackType: 'tel');
  TextEditingController get messageController =>
      _controllerForName('message', fallbackType: 'text');

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
    final user = boxUserData["user"];
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
    } else if (fieldName == 'Name' || lowerName.contains('name')) {
      if (userName.toString().isNotEmpty) ctrl.text = userName.toString();
    }
  }

  @override
  void onInit() {
    super.onInit();
    boxUserData.value = box.read('userDetails') ?? {};
    newsletterController = TextEditingController();

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
        return;
      }
    } catch (_) {}

    try {
      final cachedLegacy = box.read(_legacyCacheKey);
      if (cachedLegacy is List && cachedLegacy.isNotEmpty) {
        final list = cachedLegacy
            .map((e) => PageComponent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.isNotEmpty) {
          components.assignAll(list);
          sectionsData.value =
              ContactBroadcastSectionsData.fromLegacyComponents(list);
        }
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

  /// Intercepts both initial fetch and live WebSocket broadcasts from Fastify Studio
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
      // Tier 1: Fastify CMS Broadcasting layout (GET /api/mobile-app/contact-us)
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
            currentFormSlug =
                formSlug.isNotEmpty ? formSlug : 'contact-form';
            await fetchFormSchema(currentFormSlug);
            return;
          }
        }
      } catch (cmsError) {
        debugPrint('ContactController: Tier 1 CMS fetchLayout error: $cmsError');
      }

      // Tier 2: Fallback to legacy Page API (GET /api/pages/contact)
      try {
        final response = await _pageService.getPageByType('contact');
        final content = response.data?.content ?? [];
        if (content.isNotEmpty) {
          components.assignAll(content);
          sectionsData.value =
              ContactBroadcastSectionsData.fromLegacyComponents(content);
          try {
            box.write(
                _legacyCacheKey, content.map((c) => c.toJson()).toList());
          } catch (_) {}

          for (final c in content) {
            if (c.type == 'contact-us_contact-form-section_form_banner') {
              final slug = c.fields['form_slug']?.toString().trim() ?? '';
              if (slug.isNotEmpty) {
                currentFormSlug = slug;
              }
              break;
            }
          }
          await fetchFormSchema(currentFormSlug);
          return;
        }
      } catch (pageError) {
        debugPrint('ContactController: Tier 2 Legacy Page error: $pageError');
      }

      // Tier 3: Website Canonical Defaults (https://vision.foduu.store/contact)
      if (rawSections.isNotEmpty) {
        sectionsData.value =
            ContactBroadcastSectionsData.fromSections(rawSections);
      } else {
        sectionsData.value = ContactBroadcastSectionsData.canonical();
      }
      await fetchFormSchema(currentFormSlug);
    } catch (e) {
      debugPrint("ContactController.fetchContactLayout error: $e");
      if (sectionsData.value.infoBadges.cards.isEmpty) {
        error('Unable to load Contact page');
      }
    } finally {
      isPageLoading(false);
    }
  }

  /// Backwards compatibility alias
  Future<void> fetchContactPage() => fetchContactLayout();

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

  Future<void> subscribeNewsletter() async {
    final email = newsletterController.text.trim();
    if (!GetUtils.isEmail(email)) {
      HelperFunctions().showSnackBarError('Please enter a valid email!');
      return;
    }
    if (isSubscribing.value) return;
    isSubscribing(true);
    try {
      final response = await BasicProvider("contact-us")
          .postRequest(FormData({
            'name': 'Newsletter Subscriber',
            'email': email,
            'mobile': null,
            'content': 'Newsletter subscription request',
            'type': 'Newsletter',
            'customer_id': null,
            'vendor_id': null,
          }))
          .catchError(handleError);
      if (response == null) return;
      HelperFunctions().showSnackBarSuccess('Subscribed Successfully');
      newsletterController.clear();
    } finally {
      isSubscribing(false);
    }
  }

  @override
  void onClose() {
    for (final ctrl in fieldControllers.values) {
      ctrl.dispose();
    }
    newsletterController.dispose();
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

    isLoading(true);
    try {
      await _submit();
    } catch (e) {
      debugPrint("sendFormData error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _submit() async {
    final Map<String, dynamic> payload = {};

    for (final field in formFields) {
      final ctrl = fieldControllers[field.name];
      final val = ctrl?.text.trim() ?? '';
      payload[field.name] = val;
    }

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
