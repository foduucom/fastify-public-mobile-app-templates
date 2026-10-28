import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/mtp_solution_sections.dart';
import 'package:zouhi/app/data/services/form_api_service.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';

class MtpSolutionController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final formKey = GlobalKey<FormState>();

  static const _cacheKey = 'cms_page_mtp_solution_sections';
  final box = GetStorage();

  // ── Dynamic CMS Broadcasting Reactive Layout ────────────────────────────────
  final sectionsData = MtpSolutionSectionsData.canonical().obs;
  final isPageLoading = false.obs;

  // ── Specifications (matching https://vision.foduu.store/mtp-solution) ───
  final jacketSize = 'Single'.obs;
  final cableMode = 'SM'.obs;
  final coreFiberCount = '12'.obs;
  final endA = 'MTPF'.obs;
  final endB = 'MTPF'.obs;
  final polarity = 'Polarity A'.obs;
  final jacketDiameter = '3mm'.obs;
  final standardColor = 'Yes'.obs;
  final nonStandardColor = 'Yellow'.obs;
  final drumRequired = 'No'.obs;

  // ── Project & Contact Details ──────────────────────────────────────────
  final projectName = TextEditingController();
  final email = TextEditingController();
  final contactNumber = TextEditingController();
  final companyOrAltContact = TextEditingController();
  final quantityRequired = TextEditingController(text: '1');
  final additionalNotes = TextEditingController();

  final isSubmitting = false.obs;
  final isSchemaLoading = false.obs;

  // ── Dynamic Reactive Option Lists (Synced from GET /api/forms/mtp-solution) ─
  final jacketSizeOptions = <String>['Single', 'Double'].obs;
  final cableModeOptions = <String>['SM', 'OM1', 'OM3', 'OM4', 'OM5'].obs;
  final coreFiberOptions = <String>['12', '24'].obs;
  final endAOptions = <String>['MTPF', 'MTPM', 'M24F', 'M24M'].obs;
  final endBOptions = <String>['MTPF', 'MTPM', 'M24F', 'M24M'].obs;
  final polarityOptions =
      <String>['Polarity A', 'Polarity B', 'Polarity C'].obs;
  final jacketDiameterOptions =
      <String>['2mm', '3mm', '4.5mm', '4.8mm', '6.0mm'].obs;
  final standardColorOptions = <String>['Yes', 'No'].obs;
  final nonStandardColorOptions = <String>[
    'Yellow',
    'Blue',
    'Pink',
    'Erika Violet',
    'Green',
    'Red',
    'Purple'
  ].obs;
  final drumOptions = <String>['Yes', 'No'].obs;

  final FormApiService _formApiService = FormApiService();

  @override
  void onInit() {
    super.onInit();
    _prefillUserDetails();
    _loadCachedLayout();
    fetchMtpSolutionLayout();
  }

  void _prefillUserDetails() {
    try {
      final userDetails = box.read('userDetails');
      if (userDetails is Map) {
        final user = userDetails['user'];
        if (user is Map) {
          final userEmail = user['email']?.toString() ?? '';
          final userPhone =
              user['mobile']?.toString() ?? user['phone']?.toString() ?? '';
          if (email.text.isEmpty && userEmail.isNotEmpty) {
            email.text = userEmail;
          }
          if (contactNumber.text.isEmpty && userPhone.isNotEmpty) {
            contactNumber.text = userPhone;
          }
        }
      }
    } catch (_) {}
  }

  void _loadCachedLayout() {
    try {
      final cached = box.read(_cacheKey);
      if (cached is List && cached.isNotEmpty) {
        sectionsData.value = MtpSolutionSectionsData.fromSections(cached);
      }
    } catch (_) {}
  }

  /// Intercepts both initial fetch and live WebSocket broadcasts from Fastify Studio
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (sections.isNotEmpty) {
      sectionsData.value = MtpSolutionSectionsData.fromSections(sections);
      try {
        box.write(_cacheKey, sections);
      } catch (_) {}

      final slug = sectionsData.value.formBuilder.formSlug;
      if (slug.isNotEmpty) {
        _fetchSchemaOptions(slug);
      }
    }
  }

  /// 3-Tier Resilient CMS Broadcasting Layout Fetch
  Future<void> fetchMtpSolutionLayout() async {
    isPageLoading(true);

    try {
      // Tier 1: Fastify CMS Broadcasting (GET /api/mobile-app/mtp-solution)
      final response = await fetchLayout('mtp-solution');
      if (response != null && response is Map) {
        final list = response['sections'];
        if (list is List && list.isNotEmpty) {
          sectionsData.value = MtpSolutionSectionsData.fromSections(list);
          try {
            box.write(_cacheKey, list);
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('MtpSolutionController.fetchMtpSolutionLayout error: $e');
      // Tier 2: Cache was already preloaded in onInit
      // Tier 3: Canonical fallback is initialized in the .obs definition
    } finally {
      isPageLoading(false);
      final slug = sectionsData.value.formBuilder.formSlug;
      _fetchSchemaOptions(slug.isNotEmpty ? slug : 'mtp-solution');
    }
  }

  Future<void> _fetchSchemaOptions(String formSlug) async {
    isSchemaLoading(true);
    try {
      final fields = await _formApiService.getFormSchema(formSlug);
      if (fields.isNotEmpty) {
        for (final field in fields) {
          final label = field.label.toLowerCase().trim();
          final options =
              field.options.map((e) => e.label.trim()).where((e) => e.isNotEmpty).toList();

          if (options.isEmpty) continue;

          if (label.contains('jacket size')) {
            jacketSizeOptions.assignAll(options);
            if (!options.contains(jacketSize.value)) {
              jacketSize.value = options.first;
            }
          } else if (label.contains('cable mode') || label.contains('mode')) {
            cableModeOptions.assignAll(options);
            if (!options.contains(cableMode.value)) {
              cableMode.value = options.first;
            }
          } else if (label.contains('core') || label.contains('fibre') || label.contains('fiber')) {
            coreFiberOptions.assignAll(options);
            if (!options.contains(coreFiberCount.value)) {
              coreFiberCount.value = options.first;
            }
          } else if (label.contains('end a')) {
            endAOptions.assignAll(options);
            if (!options.contains(endA.value)) {
              endA.value = options.first;
            }
          } else if (label.contains('end b')) {
            endBOptions.assignAll(options);
            if (!options.contains(endB.value)) {
              endB.value = options.first;
            }
          } else if (label.contains('polarity')) {
            polarityOptions.assignAll(options);
            if (!options.contains(polarity.value)) {
              polarity.value = options.first;
            }
          } else if (label.contains('diameter')) {
            jacketDiameterOptions.assignAll(options);
            if (!options.contains(jacketDiameter.value)) {
              jacketDiameter.value = options.first;
            }
          } else if (label.contains('drum')) {
            drumOptions.assignAll(options);
            if (!options.contains(drumRequired.value)) {
              drumRequired.value = options.first;
            }
          }
        }
      }
    } catch (_) {
      // Retain verified fallback constants
    } finally {
      isSchemaLoading(false);
    }
  }

  @override
  void onClose() {
    projectName.dispose();
    email.dispose();
    contactNumber.dispose();
    companyOrAltContact.dispose();
    quantityRequired.dispose();
    additionalNotes.dispose();
    super.onClose();
  }

  /// Standardized Form Submission adhering to form-submission-api-guide.md
  Future<void> submitMtpForm(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Required Fields',
        'Please enter all required contact details before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      var rawQty = quantityRequired.text.trim();
      if (rawQty.isEmpty) rawQty = '1';
      // Backend validates text inputs with minimum 3 characters
      final formattedQty = rawQty.length < 3 ? '$rawQty units' : rawQty;

      final formSlug = sectionsData.value.formBuilder.formSlug.isNotEmpty
          ? sectionsData.value.formBuilder.formSlug
          : 'mtp-solution';

      final payload = {
        'Jacket Size': jacketSize.value,
        'Cable Mode': cableMode.value,
        'Core / Fibre Count': coreFiberCount.value,
        'End A': endA.value,
        'End B': endB.value,
        'Polarity': polarity.value,
        'Jacket Diameter': jacketDiameter.value,
        'Standard Colour': standardColor.value,
        'Non-Standard Colours':
            standardColor.value == 'No' ? nonStandardColor.value : 'N/A',
        'Drum': drumRequired.value,
        'Project Name': projectName.text.trim().isNotEmpty
            ? projectName.text.trim()
            : 'MTP Solution Inquiry',
        'Email': email.text.trim(),
        'Contact Number': contactNumber.text.trim(),
        'Company': companyOrAltContact.text.trim(),
        'Quantity Required': formattedQty,
        'Additional Notes': additionalNotes.text.trim(),
      };

      final response = await _formApiService.submitForm(formSlug, payload);

      isSubmitting.value = false;
      if (response != null) {
        _showSuccessDialog();
      }
    } catch (e) {
      isSubmitting.value = false;
      final msg = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Submission Notice',
        msg.isNotEmpty
            ? msg
            : 'Unable to submit your quote request. Please check your network or try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Submitted Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B3B64),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your MTP Solution inquiry has been submitted. Our optical engineering team will review your specifications and contact you shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3B64),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Get.back(); // close dialog
                    _resetForm();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _resetForm() {
    projectName.clear();
    email.clear();
    contactNumber.clear();
    companyOrAltContact.clear();
    quantityRequired.text = '1';
    additionalNotes.clear();
  }

  Future<void> callSupport() async {
    final clean = supportContact.replaceAll(RegExp(r'[^0-9+]'), '');
    final telUrl = 'tel:$clean';
    if (await canLaunchUrlString(telUrl)) {
      await launchUrlString(telUrl);
    } else {
      Get.snackbar(
        'Call Support',
        'Call our team toll-free at $supportContact',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> sendEmailInquiry() async {
    final subject = Uri.encodeComponent(
      'MTP Solution Inquiry: ${cableMode.value} ${coreFiberCount.value}F [${endA.value}-${endB.value}]',
    );
    final body = Uri.encodeComponent(
      'Hello Vision Infrastructure Team,\n\n'
      'I would like to inquire about MTP Solutions:\n'
      '• Mode: ${cableMode.value}\n'
      '• Fiber Count: ${coreFiberCount.value}\n'
      '• Connectors: ${endA.value} - ${endB.value}\n'
      '• Polarity: ${polarity.value}\n'
      '• Jacket Diameter: ${jacketDiameter.value}\n\n'
      'Please send me wholesale pricing and delivery timeline.',
    );
    final mailtoUrl = 'mailto:$supportEmail?subject=$subject&body=$body';
    if (await canLaunchUrlString(mailtoUrl)) {
      await launchUrlString(mailtoUrl);
    }
  }
}
