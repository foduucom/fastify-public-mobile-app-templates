import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/app/data/services/form_api_service.dart';
import 'package:zouhi/constants/constants.dart';

class CableAssembliesController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // ── Section 1: A END (Pulling End) ──────────────────────────────────────────
  final aConnectorType = 'LC'.obs;
  final aBreakoutType = 'Staggered Simplex'.obs;
  final aBreakoutLength = '500 (standard)'.obs;
  final aBreakoutOversleeving = '2mm'.obs;
  final aCableGland = 'No'.obs;
  final aPullingSock = 'Not Required'.obs;

  // ── Section 2: CABLE ────────────────────────────────────────────────────────
  final cableSelection = 'Riser DX'.obs;
  final cableMode = 'OS2'.obs;
  final cableCores = '12'.obs;
  final cableLength = TextEditingController();
  final cableDrum = 'No'.obs;

  // ── Section 3: B END ────────────────────────────────────────────────────────
  final bConnectorType = 'LC'.obs;
  final bBreakoutType = 'Staggered Simplex'.obs;
  final bBreakoutLength = '500 (standard)'.obs;
  final bBreakoutOversleeving = '2mm'.obs;
  final bCableGland = 'No'.obs;
  final bPullingSock = 'Not Required'.obs;

  // ── Section 4: Project Details ──────────────────────────────────────────────
  final projectName = TextEditingController();
  final email = TextEditingController();
  final contactNumber = TextEditingController();
  final companyOrAltContact = TextEditingController();
  final quantityRequired = TextEditingController(text: '1');
  final additionalNotes = TextEditingController();

  final isSubmitting = false.obs;

  // ── Dynamic Reactive Option Lists (Synced from GET /api/forms/cable-form) ───
  final connectorOptions = <String>[
    'LC',
    'LCA',
    'SC',
    'SCA',
    'ST',
    'FC',
    'FCA',
    'MTP',
  ].obs;

  final breakoutTypeOptions = <String>[
    'Staggered Simplex',
    'Staggered Duplex',
  ].obs;

  final breakoutLengthOptions = <String>[
    '100',
    '200',
    '300',
    '400',
    '500 (standard)',
    '600',
    '700',
    '800',
    '900',
    '1000',
  ].obs;

  final oversleevingOptions = <String>[
    '2mm',
    '3mm',
  ].obs;

  final glandRequiredOptions = <String>[
    'Yes',
    'No',
  ].obs;

  final pullingSockOptions = <String>[
    'Not Required',
    'Nylon (Light Duty)',
    'Conduit (Heavy Duty)',
  ].obs;

  final cableSelectionOptions = <String>[
    'Riser DX',
    'Riser BX',
    'Mini (Loose Tube)',
    'Tactical DX',
    'Tactical BX',
    'Fire Rated',
    'Microcore',
  ].obs;

  final cableModeOptions = <String>[
    'OS2',
    'OM1',
    'OM3',
    'OM4',
    'OM5',
  ].obs;

  final coreCountOptions = <String>[
    '2',
    '4',
    '6',
    '12',
    '24',
    '48',
  ].obs;

  final drumOptions = <String>[
    'Yes',
    'No',
  ].obs;

  final FormApiService _formApiService = FormApiService();

  @override
  void onInit() {
    super.onInit();
    _fetchSchemaOptions();
  }

  Future<void> _fetchSchemaOptions() async {
    try {
      final fields = await _formApiService.getFormSchema('cable-form');
      for (final field in fields) {
        if (field.options.isEmpty) continue;
        final opts = field.options
            .map((o) => o.label.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (opts.isEmpty) continue;

        final label = field.label.trim().toLowerCase();
        if (label == 'connector type') {
          connectorOptions.assignAll(opts);
        } else if (label == 'break out type') {
          breakoutTypeOptions.assignAll(opts);
        } else if (label.contains('length')) {
          breakoutLengthOptions.assignAll(opts);
        } else if (label.contains('oversleeving')) {
          oversleevingOptions.assignAll(opts);
        } else if (label.contains('gland')) {
          glandRequiredOptions.assignAll(opts);
        } else if (label.contains('sock')) {
          pullingSockOptions.assignAll(opts);
        } else if (label == 'cable selection') {
          cableSelectionOptions.assignAll(opts);
        } else if (label == 'mode') {
          cableModeOptions.assignAll(opts);
        } else if (label.contains('core')) {
          coreCountOptions.assignAll(opts);
        } else if (label.contains('drum')) {
          drumOptions.assignAll(opts);
        }
      }
    } catch (_) {
      // Clean offline fallback to pre-seeded arrays
    }
  }

  @override
  void onClose() {
    cableLength.dispose();
    projectName.dispose();
    email.dispose();
    contactNumber.dispose();
    companyOrAltContact.dispose();
    quantityRequired.dispose();
    additionalNotes.dispose();
    super.onClose();
  }

  Future<void> submitCableForm(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Required Fields',
        'Please enter your contact details before submitting.',
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
      // Backend validates text inputs with min 3 characters
      final formattedQty = rawQty.length < 3 ? '$rawQty units' : rawQty;

      // Compile comprehensive spec summary for engineer review
      final specSummary = [
        'A End: [Connector: ${aConnectorType.value}, Breakout: ${aBreakoutType.value}, Length: ${aBreakoutLength.value}mm, Oversleeving: ${aBreakoutOversleeving.value}, Gland: ${aCableGland.value}, Sock: ${aPullingSock.value}]',
        'Cable: [Selection: ${cableSelection.value}, Mode: ${cableMode.value}, Cores: ${cableCores.value}, Length: ${cableLength.text.trim().isNotEmpty ? cableLength.text.trim() : "100"}m, Drum: ${cableDrum.value}]',
        'B End: [Connector: ${bConnectorType.value}, Breakout: ${bBreakoutType.value}, Length: ${bBreakoutLength.value}mm, Oversleeving: ${bBreakoutOversleeving.value}, Gland: ${bCableGland.value}, Sock: ${bPullingSock.value}]',
        if (companyOrAltContact.text.trim().isNotEmpty)
          'Company/Alt: ${companyOrAltContact.text.trim()}',
        if (additionalNotes.text.trim().isNotEmpty)
          'Notes: ${additionalNotes.text.trim()}',
      ].join(' | ');

      final payload = {
        'Email': email.text.trim(),
        'Project Name': projectName.text.trim().isNotEmpty
            ? projectName.text.trim()
            : 'Custom Cable Assembly Inquiry',
        'Contact Number': contactNumber.text.trim(),
        'Quantity Required': formattedQty,
        'Length (Metres)': cableLength.text.trim().isNotEmpty
            ? cableLength.text.trim()
            : '100',
        'Cable Selection': cableSelection.value,
        'Connector Type': aConnectorType.value,
        'Break Out Type': aBreakoutType.value,
        'Break Out Length(mm)': aBreakoutLength.value,
        'Break Out Oversleeving': aBreakoutOversleeving.value,
        'Cable Gland Required': aCableGland.value,
        'Pulling Sock': aPullingSock.value,
        'Mode': cableMode.value,
        'No. of Cores': cableCores.value,
        'Drum Required': cableDrum.value,
        'Additional Notes': specSummary,
      };

      final response = await _formApiService.submitForm('cable-form', payload);

      isSubmitting.value = false;
      if (response != null) {
        _showSuccessDialog();
      }
    } catch (e) {
      isSubmitting.value = false;
      final msg = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Submission Failed',
        msg.isNotEmpty ? msg : 'Unable to submit your cable assembly inquiry. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }

  Future<void> callSupport() async {
    final cleanPhone = supportContact.replaceAll(RegExp(r'[^0-9+]'), '');
    final telUri = 'tel:$cleanPhone';
    try {
      if (await canLaunchUrlString(telUri)) {
        await launchUrlString(telUri);
      }
    } catch (_) {}
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
                'Your cable assembly inquiry has been submitted. Our optical engineering team will review your specifications and contact you shortly.',
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
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3B64),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
}
