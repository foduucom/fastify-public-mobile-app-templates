import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zouhi/constants/constants.dart';
import '../controllers/mtp_solution_controller.dart';

class MtpSolutionView extends GetView<MtpSolutionController> {
  const MtpSolutionView({Key? key}) : super(key: key);

  static const _poppins = 'Poppins';
  static const _brandNavy = Color(0xFF1B3B64);
  static const _brandBlue = Color(0xFF20558A);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textDark = Color(0xFF212529);
  static const _labelColor = Color(0xFF374151);

  void _openSchematicViewer(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: PhotoView(
                imageProvider: const AssetImage('assets/images/mtp-lead.webp'),
                backgroundDecoration: const BoxDecoration(color: Colors.white),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.5,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.65),
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pinch or double-tap to inspect MTP pinout schematic',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: _poppins,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'MTP Solution',
            style: TextStyle(
              fontFamily: _poppins,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: _textDark,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: _textDark),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone_in_talk_rounded,
                  size: 20, color: _brandNavy),
              tooltip: 'Call Support',
              onPressed: () => controller.callSupport(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Engineering Schematic Banner with Tap to Zoom
                InkWell(
                  onTap: () => _openSchematicViewer(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/mtp-lead.webp',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.cable_rounded,
                                  size: 40, color: _brandNavy),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          color: _brandNavy.withValues(alpha: 0.05),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.zoom_in_rounded,
                                  size: 16, color: _brandNavy),
                              SizedBox(width: 6),
                              Text(
                                'Tap to inspect MTP lead specifications & pinout',
                                style: TextStyle(
                                  fontFamily: _poppins,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _brandNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SECTION 1: Cable & Connector Specifications
                _buildCardSection(
                  title: 'Cable Specifications',
                  children: [
                    _buildDropdownField(
                      label: 'Jacket Size',
                      value: controller.jacketSize,
                      options: controller.jacketSizeOptions,
                    ),
                    _buildDropdownField(
                      label: 'Cable Mode',
                      value: controller.cableMode,
                      options: controller.cableModeOptions,
                    ),
                    _buildDropdownField(
                      label: 'Core / Fibre Count',
                      value: controller.coreFiberCount,
                      options: controller.coreFiberOptions,
                    ),
                    _buildDropdownField(
                      label: 'End A',
                      value: controller.endA,
                      options: controller.endAOptions,
                    ),
                    _buildDropdownField(
                      label: 'End B',
                      value: controller.endB,
                      options: controller.endBOptions,
                    ),
                    _buildDropdownField(
                      label: 'Polarity',
                      value: controller.polarity,
                      options: controller.polarityOptions,
                    ),
                    _buildDropdownField(
                      label: 'Jacket Size',
                      value: controller.jacketDiameter,
                      options: controller.jacketDiameterOptions,
                    ),
                    _buildDropdownField(
                      label: 'Standard Colour',
                      value: controller.standardColor,
                      options: controller.standardColorOptions,
                    ),
                    Obx(() {
                      if (controller.standardColor.value == 'No') {
                        return _buildDropdownField(
                          label: 'Non-Standard Colour',
                          value: controller.nonStandardColor,
                          options: controller.nonStandardColorOptions,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    _buildDropdownField(
                      label: 'Drum Required',
                      value: controller.drumRequired,
                      options: controller.drumOptions,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // SECTION 2: Project & Contact Details
                _buildCardSection(
                  title: 'Project & Contact Details',
                  children: [
                    _buildInputField(
                      label: 'Project Name',
                      controller: controller.projectName,
                    ),
                    _buildInputField(
                      label: 'Email Address *',
                      controller: controller.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!GetUtils.isEmail(val.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    _buildInputField(
                      label: 'Contact Number *',
                      controller: controller.contactNumber,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    // _buildInputField(
                    //   label: 'Company / Organization',
                    //   controller: controller.companyOrAltContact,
                    // ),
                    _buildInputField(
                      label: 'Quantity Required',
                      controller: controller.quantityRequired,
                      keyboardType: TextInputType.number,
                    ),
                    _buildInputField(
                      label: 'Additional Notes / Comments',
                      controller: controller.additionalNotes,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Technical & Engineering Reference Notes
                _buildTechnicalNotesCard(),

                const SizedBox(height: 22),

                // SECTION 3: Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => controller.submitMtpForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit MTP Inquiry',
                              style: TextStyle(
                                fontFamily: _poppins,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Assistance Card
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent_rounded,
                          size: 24, color: _brandNavy),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Need urgent quotation?',
                              style: TextStyle(
                                fontFamily: _poppins,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'Call toll-free $supportContact',
                              style: const TextStyle(
                                fontFamily: _poppins,
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.callSupport(),
                        child: const Text(
                          'Call Now',
                          style: TextStyle(
                            fontFamily: _poppins,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _brandBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: _poppins,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required RxString value,
    required List<String> options,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: _poppins,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 5),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: options.contains(value.value)
                      ? value.value
                      : options.first,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B7280)),
                  style: const TextStyle(
                    fontFamily: _poppins,
                    fontSize: 13.5,
                    color: _textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (newVal) {
                    if (newVal != null) {
                      value.value = newVal;
                    }
                  },
                  items: options.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt,
                      child: Text(opt),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: _poppins,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontFamily: _poppins,
              fontSize: 13.5,
              color: _textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Enter value..',
              hintStyle: const TextStyle(
                fontFamily: _poppins,
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _brandNavy, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFDC2626), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalNotesCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _brandNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: _brandNavy,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Engineering & Specification Notes',
                  style: TextStyle(
                    fontFamily: _poppins,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _brandNavy,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Standards',
                  style: TextStyle(
                    fontFamily: _poppins,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFE2E8F0), thickness: 0.8),
          const Text(
            'STANDARD FIBER COLOURS',
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildColorChip(
                  label: 'Single Mode: Yellow',
                  dotColor: const Color(0xFFEAB308)),
              _buildColorChip(
                  label: 'OM3/OM4: Aqua', dotColor: const Color(0xFF00B4D8)),
              _buildColorChip(
                  label: 'OM5: Lime Green',
                  dotColor: const Color(0xFF84CC16)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'STANDARD JACKET SIZES',
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Single Jacket',
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '2mm / 3mm',
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Double Jacket',
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '4.5mm / 4.8mm / 6.0mm',
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip({required String label, required Color dotColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _poppins,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}
