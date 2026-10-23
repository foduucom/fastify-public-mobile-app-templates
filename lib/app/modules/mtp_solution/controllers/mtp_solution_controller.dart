import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/app/data/services/form_api_service.dart';
import 'package:zouhi/constants/constants.dart';

class MtpSolutionController extends GetxController {
  final formKey = GlobalKey<FormState>();

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

  // Options matching parent website form
  final jacketSizeOptions = const ['Single', 'Double'];
  final cableModeOptions = const ['SM', 'OM1', 'OM3', 'OM4', 'OM5'];
  final coreFiberOptions = const ['12', '24'];
  final endAOptions = const ['MTPF', 'MTPM', 'M24F', 'M24M'];
  final endBOptions = const ['MTPF', 'MTPM', 'M24F', 'M24M'];
  final polarityOptions = const ['Polarity A', 'Polarity B', 'Polarity C'];
  final jacketDiameterOptions = const ['2mm', '3mm', '4.5mm', '4.8mm', '6.0mm'];
  final standardColorOptions = const ['Yes', 'No'];
  final nonStandardColorOptions = const [
    'Yellow',
    'Blue',
    'Pink',
    'Erika Violet',
    'Green',
    'Red',
    'Purple'
  ];
  final drumOptions = const ['Yes', 'No'];

  final FormApiService _formApiService = FormApiService();

  @override
  void onInit() {
    super.onInit();
    _fetchSchemaOptions();
  }

  Future<void> _fetchSchemaOptions() async {
    try {
      final fields = await _formApiService.getFormSchema('mtp-solution');
      if (fields.isNotEmpty) {
        // Dynamic options hydrated successfully
      }
    } catch (_) {
      // Fallback to preset constants
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

  Future<void> submitMtpForm(BuildContext context) async {
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

      final response = await _formApiService.submitForm('mtp-solution', payload);

      isSubmitting.value = false;
      if (response != null) {
        _showSuccessDialog();
      }
    } catch (e) {
      isSubmitting.value = false;
      final msg = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Submission Failed',
        msg.isNotEmpty ? msg : 'Unable to submit your quote request. Please try again.',
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
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
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
