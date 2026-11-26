import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zouhi/app/data/models/mtp_solution_sections.dart';
import 'package:zouhi/app/modules/mtp_solution/controllers/mtp_solution_controller.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

const _poppins = 'Poppins';

void _openMtpSchematicViewer(BuildContext context, String remoteUrl) {
  final isRemote = remoteUrl.isNotEmpty &&
      (remoteUrl.startsWith('http://') || remoteUrl.startsWith('https://'));

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
              imageProvider: isRemote
                  ? CachedNetworkImageProvider(remoteUrl) as ImageProvider
                  : const AssetImage('assets/images/mtp-lead.webp'),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

/// 1. MTP Schematic Banner
class MtpSchematicBannerWidget extends StatelessWidget {
  const MtpSchematicBannerWidget({
    super.key,
    required this.banner,
    this.textBlock,
  });

  final MtpSolutionBannerData banner;
  final MtpSolutionTextBlockData? textBlock;

  factory MtpSchematicBannerWidget.fromContentJson(Map<String, dynamic> json) {
    return MtpSchematicBannerWidget(
      banner: MtpSolutionBannerData.fromContentJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRemote = banner.imageUrl.isNotEmpty &&
        (banner.imageUrl.startsWith('http://') ||
            banner.imageUrl.startsWith('https://'));

    final ctrl = Get.isRegistered<MtpSolutionController>()
        ? Get.find<MtpSolutionController>()
        : null;
    final captionText = textBlock?.text ??
        ctrl?.sectionsData.value.textBlock.text ??
        'Tap to inspect detailed pinout & schematic';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      child: InkWell(
        onTap: () => _openMtpSchematicViewer(context, banner.imageUrl),
        borderRadius: BorderRadius.circular(banner.borderRadius),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(banner.borderRadius),
            border: Border.all(color: context.themeBorderColor),
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
              if (isRemote)
                CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, __) => Container(
                    height: 140,
                    color: const Color(0xFFF1F5F9),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.themePrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/mtp-lead.webp',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                )
              else
                Image.asset(
                  'assets/images/mtp-lead.webp',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              Container(
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.zoom_in_rounded,
                        size: 15, color: context.themeSecondryColor),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        captionText.isNotEmpty
                            ? captionText
                            : 'Tap to inspect detailed pinout & schematic',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: context.themeSecondryColor,
                        ),
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
}

/// 2. MTP Solution Configurator Form
class MtpConfiguratorFormWidget extends StatelessWidget {
  const MtpConfiguratorFormWidget({super.key, this.controller});

  final MtpSolutionController? controller;

  factory MtpConfiguratorFormWidget.fromContentJson(Map<String, dynamic> json) {
    return const MtpConfiguratorFormWidget();
  }

  @override
  Widget build(BuildContext context) {
    final MtpSolutionController ctrl = controller ??
        (Get.isRegistered<MtpSolutionController>()
            ? Get.find<MtpSolutionController>()
            : Get.put(MtpSolutionController()));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Form(
        key: ctrl.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardSection(
              context: context,
              title: 'Cable Specifications',
              children: [
                _buildDropdownField(
                  context: context,
                  label: 'Jacket Size',
                  value: ctrl.jacketSize,
                  options: ctrl.jacketSizeOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'Cable Mode',
                  value: ctrl.cableMode,
                  options: ctrl.cableModeOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'Core / Fibre Count',
                  value: ctrl.coreFiberCount,
                  options: ctrl.coreFiberOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'End A',
                  value: ctrl.endA,
                  options: ctrl.endAOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'End B',
                  value: ctrl.endB,
                  options: ctrl.endBOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'Polarity',
                  value: ctrl.polarity,
                  options: ctrl.polarityOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'Jacket Diameter',
                  value: ctrl.jacketDiameter,
                  options: ctrl.jacketDiameterOptions,
                ),
                _buildDropdownField(
                  context: context,
                  label: 'Standard Colour',
                  value: ctrl.standardColor,
                  options: ctrl.standardColorOptions,
                ),
                Obx(() {
                  if (ctrl.standardColor.value == 'No') {
                    return _buildDropdownField(
                      context: context,
                      label: 'Non-Standard Colour',
                      value: ctrl.nonStandardColor,
                      options: ctrl.nonStandardColorOptions,
                    );
                  }
                  return const SizedBox.shrink();
                }),
                _buildDropdownField(
                  context: context,
                  label: 'Drum Required',
                  value: ctrl.drumRequired,
                  options: ctrl.drumOptions,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardSection(
              context: context,
              title: 'Project & Contact Details',
              children: [
                _buildInputField(
                  context: context,
                  label: 'Project Name',
                  controller: ctrl.projectName,
                  hintText: 'e.g. Data Center MTP Backbone',
                ),
                _buildInputField(
                  context: context,
                  label: 'Email Address *',
                  controller: ctrl.email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'name@example.com',
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
                  context: context,
                  label: 'Contact Number *',
                  controller: ctrl.contactNumber,
                  keyboardType: TextInputType.phone,
                  hintText: '+1 987 654 3210',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final digitsOnly = val.replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  context: context,
                  label: 'Quantity Required',
                  controller: ctrl.quantityRequired,
                  keyboardType: TextInputType.number,
                  hintText: '1',
                ),
                _buildInputField(
                  context: context,
                  label: 'Additional Notes / Comments',
                  controller: ctrl.additionalNotes,
                  maxLines: 3,
                  hintText: 'Any custom specifications or pinout notes...',
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isSubmitting.value
                      ? null
                      : () => ctrl.submitMtpForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.themePrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: ctrl.isSubmitting.value
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
                  Icon(Icons.support_agent_rounded,
                      size: 24, color: context.themePrimaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need urgent quotation?',
                          style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.themeTextColor,
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
                    onPressed: () => ctrl.callSupport(),
                    child: Text(
                      'Call Now',
                      style: TextStyle(
                        fontFamily: _poppins,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: context.themeSecondryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.themeBorderColor),
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
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required RxString value,
    required RxList<String> options,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: context.themeSecondrytext,
            ),
          ),
          const SizedBox(height: 5),
          Obx(
            () {
              final list = options.isNotEmpty ? options : [value.value];
              final currentVal = list.contains(value.value)
                  ? value.value
                  : (list.isNotEmpty ? list.first : '');

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.themeBorderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentVal.isNotEmpty ? currentVal : null,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6B7280)),
                    style: TextStyle(
                      fontFamily: _poppins,
                      fontSize: 13.5,
                      color: context.themeTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        value.value = newVal;
                      }
                    },
                    items: list.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
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
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: context.themeSecondrytext,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 13.5,
              color: context.themeTextColor,
            ),
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter value..',
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
                borderSide: BorderSide(color: context.themeBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: context.themePrimaryColor, width: 1.5),
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
}

/// 3. MTP Engineering & Specification Notes Card
class MtpEngineeringNotesWidget extends StatelessWidget {
  const MtpEngineeringNotesWidget({super.key, required this.richText});

  final MtpSolutionRichTextData richText;

  factory MtpEngineeringNotesWidget.fromContentJson(Map<String, dynamic> json) {
    return MtpEngineeringNotesWidget(
      richText: MtpSolutionRichTextData.fromContentJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      child: Container(
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
                    color: context.themePrimaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: context.themePrimaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Engineering & Specification Notes',
                    style: TextStyle(
                      fontFamily: _poppins,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.themePrimaryColor,
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
            const Divider(
                height: 18, color: Color(0xFFE2E8F0), thickness: 0.8),
            if (richText.bulletPoints.isNotEmpty) ...[
              ...richText.bulletPoints.map((bp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: context.themePrimaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bp,
                          style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 12,
                            height: 1.45,
                            color: context.themeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
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
                      dotColor: const Color(0xFFEAB308),
                      textColor: context.themeTextColor),
                  _buildColorChip(
                      label: 'OM3/OM4: Aqua',
                      dotColor: const Color(0xFF00B4D8),
                      textColor: context.themeTextColor),
                  _buildColorChip(
                      label: 'OM5: Lime Green',
                      dotColor: const Color(0xFF84CC16),
                      textColor: context.themeTextColor),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip({
    required String label,
    required Color dotColor,
    required Color textColor,
  }) {
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
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
