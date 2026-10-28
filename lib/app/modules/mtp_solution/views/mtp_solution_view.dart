import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import '../controllers/mtp_solution_controller.dart';

class MtpSolutionView extends GetView<MtpSolutionController> {
  const MtpSolutionView({Key? key}) : super(key: key);

  static const _poppins = 'Poppins';

  void _openSchematicViewer(BuildContext context) {
    final remoteUrl = controller.sectionsData.value.banner.imageUrl;
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

  Widget _buildSchematicBanner(BuildContext context) {
    return Obx(() {
      final banner = controller.sectionsData.value.banner;
      final textBlock = controller.sectionsData.value.textBlock;
      final isRemote = banner.imageUrl.isNotEmpty &&
          (banner.imageUrl.startsWith('http://') ||
              banner.imageUrl.startsWith('https://'));

      return InkWell(
        onTap: () => _openSchematicViewer(context),
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
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.themePrimaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/mtp-lead.webp',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(Icons.cable_rounded,
                            size: 40, color: context.themePrimaryColor),
                      ),
                    ),
                  ),
                )
              else
                Image.asset(
                  'assets/images/mtp-lead.webp',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Icon(Icons.cable_rounded,
                          size: 40, color: context.themePrimaryColor),
                    ),
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                color: context.themePrimaryColor.withValues(alpha: 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.zoom_in_rounded,
                        size: 16, color: context.themePrimaryColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        textBlock.text.isNotEmpty
                            ? textBlock.text
                            : 'Tap to inspect MTP lead specifications & pinout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.themePrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: context.themeBackground,
        appBar: AppBar(
          title: Text(
            'MTP Solution',
            style: TextStyle(
              fontFamily: _poppins,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: context.themeTextColor,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: context.themeTextColor),
          actions: [
            IconButton(
              icon: Icon(Icons.phone_in_talk_rounded,
                  size: 20, color: context.themePrimaryColor),
              tooltip: 'Call Support',
              onPressed: () => controller.callSupport(),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: context.themePrimaryColor,
          onRefresh: () => controller.fetchMtpSolutionLayout(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Engineering Schematic Banner with Tap to Zoom & CMS Binding
                  _buildSchematicBanner(context),

                  const SizedBox(height: 16),

                  // SECTION 1: Cable & Connector Specifications
                  _buildCardSection(
                    context: context,
                    title: 'Cable Specifications',
                    children: [
                      _buildDropdownField(
                        context: context,
                        label: 'Jacket Size',
                        value: controller.jacketSize,
                        options: controller.jacketSizeOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'Cable Mode',
                        value: controller.cableMode,
                        options: controller.cableModeOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'Core / Fibre Count',
                        value: controller.coreFiberCount,
                        options: controller.coreFiberOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'End A',
                        value: controller.endA,
                        options: controller.endAOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'End B',
                        value: controller.endB,
                        options: controller.endBOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'Polarity',
                        value: controller.polarity,
                        options: controller.polarityOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'Jacket Diameter',
                        value: controller.jacketDiameter,
                        options: controller.jacketDiameterOptions,
                      ),
                      _buildDropdownField(
                        context: context,
                        label: 'Standard Colour',
                        value: controller.standardColor,
                        options: controller.standardColorOptions,
                      ),
                      Obx(() {
                        if (controller.standardColor.value == 'No') {
                          return _buildDropdownField(
                            context: context,
                            label: 'Non-Standard Colour',
                            value: controller.nonStandardColor,
                            options: controller.nonStandardColorOptions,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      _buildDropdownField(
                        context: context,
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
                    context: context,
                    title: 'Project & Contact Details',
                    children: [
                      _buildInputField(
                        context: context,
                        label: 'Project Name',
                        controller: controller.projectName,
                        hintText: 'e.g. Data Center MTP Backbone',
                      ),
                      _buildInputField(
                        context: context,
                        label: 'Email Address *',
                        controller: controller.email,
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
                        controller: controller.contactNumber,
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
                        controller: controller.quantityRequired,
                        keyboardType: TextInputType.number,
                        hintText: '1',
                      ),
                      _buildInputField(
                        context: context,
                        label: 'Additional Notes / Comments',
                        controller: controller.additionalNotes,
                        maxLines: 3,
                        hintText: 'Any custom specifications or pinout notes...',
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Technical & Engineering Reference Notes (Bound to CMS rich_text)
                  _buildTechnicalNotesCard(context),

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
                          backgroundColor: context.themePrimaryColor,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                          onPressed: () => controller.callSupport(),
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

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
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

  Widget _buildTechnicalNotesCard(BuildContext context) {
    return Obx(() {
      final richText = controller.sectionsData.value.richText;
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
      );
    });
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
