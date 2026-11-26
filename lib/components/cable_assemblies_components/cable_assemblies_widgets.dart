import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zouhi/app/data/models/cable_assemblies_sections.dart';
import 'package:zouhi/app/modules/cable_assemblies/controllers/cable_assemblies_controller.dart';
import 'package:zouhi/constants/constants.dart';

const _poppins = 'Poppins';
const _brandNavy = Color(0xFF1B3B64);
const _brandBlue = Color(0xFF20558A);
const _borderColor = Color(0xFFE5E7EB);
const _textDark = Color(0xFF212529);
const _labelColor = Color(0xFF374151);

void _openCableSchematicViewer(BuildContext context, String remoteUrl) {
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
                  : const AssetImage('assets/images/cable-banner.webp'),
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
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Pinch to zoom & inspect breakout pinout schematic',
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

/// 1. Top Engineering Schematic Banner
class CableSchematicBannerWidget extends StatelessWidget {
  const CableSchematicBannerWidget({
    super.key,
    required this.banner,
    this.textBlock,
  });

  final CableAssembliesBannerData banner;
  final CableAssembliesTextBlockData? textBlock;

  factory CableSchematicBannerWidget.fromContentJson(
      Map<String, dynamic> json) {
    return CableSchematicBannerWidget(
      banner: CableAssembliesBannerData.fromContentJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRemote = banner.imageUrl.isNotEmpty &&
        (banner.imageUrl.startsWith('http://') ||
            banner.imageUrl.startsWith('https://'));

    final ctrl = Get.isRegistered<CableAssembliesController>()
        ? Get.find<CableAssembliesController>()
        : null;
    final captionText = textBlock?.text ??
        ctrl?.sectionsData.value.textBlock.text ??
        'Tap to inspect detailed pinout & schematic';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      child: InkWell(
        onTap: () => _openCableSchematicViewer(context, banner.imageUrl),
        borderRadius: BorderRadius.circular(banner.borderRadius),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(banner.borderRadius),
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
              if (isRemote)
                CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, __) => Container(
                    height: 140,
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _brandNavy,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/cable-banner.webp',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                )
              else
                Image.asset(
                  'assets/images/cable-banner.webp',
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
                    const Icon(Icons.zoom_in_rounded,
                        size: 15, color: _brandBlue),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        captionText.isNotEmpty
                            ? captionText
                            : 'Tap to inspect detailed pinout & schematic',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _poppins,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: _brandBlue,
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

/// 2. Cable Assemblies Interactive Configurator Form
class CableConfiguratorFormWidget extends StatelessWidget {
  const CableConfiguratorFormWidget({
    super.key,
    this.controller,
  });

  final CableAssembliesController? controller;

  factory CableConfiguratorFormWidget.fromContentJson(
      Map<String, dynamic> json) {
    return const CableConfiguratorFormWidget();
  }

  @override
  Widget build(BuildContext context) {
    final CableAssembliesController ctrl = controller ??
        (Get.isRegistered<CableAssembliesController>()
            ? Get.find<CableAssembliesController>()
            : Get.put(CableAssembliesController()));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Form(
        key: ctrl.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardSection(
              title: 'A END (Pulling End)',
              children: [
                _buildDropdownField(
                  label: 'Connector Type',
                  value: ctrl.aConnectorType,
                  options: ctrl.connectorOptions,
                ),
                _buildDropdownField(
                  label: 'Break Out Type',
                  value: ctrl.aBreakoutType,
                  options: ctrl.breakoutTypeOptions,
                ),
                _buildDropdownField(
                  label: 'Break Out Length (mm)',
                  value: ctrl.aBreakoutLength,
                  options: ctrl.breakoutLengthOptions,
                ),
                _buildDropdownField(
                  label: 'Break Out Oversleeving',
                  value: ctrl.aBreakoutOversleeving,
                  options: ctrl.oversleevingOptions,
                ),
                _buildDropdownField(
                  label: 'Cable Gland Required',
                  value: ctrl.aCableGland,
                  options: ctrl.glandRequiredOptions,
                ),
                _buildDropdownField(
                  label: 'Pulling Sock',
                  value: ctrl.aPullingSock,
                  options: ctrl.pullingSockOptions,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardSection(
              title: 'CABLE',
              children: [
                _buildDropdownField(
                  label: 'Cable Selection',
                  value: ctrl.cableSelection,
                  options: ctrl.cableSelectionOptions,
                ),
                _buildDropdownField(
                  label: 'Mode',
                  value: ctrl.cableMode,
                  options: ctrl.cableModeOptions,
                ),
                _buildDropdownField(
                  label: 'No. of Cores',
                  value: ctrl.cableCores,
                  options: ctrl.coreCountOptions,
                ),
                _buildInputField(
                  label: 'Length (Metres)',
                  controller: ctrl.cableLength,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter no...',
                ),
                _buildDropdownField(
                  label: 'Drum Required',
                  value: ctrl.cableDrum,
                  options: ctrl.drumOptions,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardSection(
              title: 'B END',
              children: [
                _buildDropdownField(
                  label: 'Connector Type',
                  value: ctrl.bConnectorType,
                  options: ctrl.connectorOptions,
                ),
                _buildDropdownField(
                  label: 'Break Out Type',
                  value: ctrl.bBreakoutType,
                  options: ctrl.breakoutTypeOptions,
                ),
                _buildDropdownField(
                  label: 'Break Out Length (mm)',
                  value: ctrl.bBreakoutLength,
                  options: ctrl.breakoutLengthOptions,
                ),
                _buildDropdownField(
                  label: 'Break Out Oversleeving',
                  value: ctrl.bBreakoutOversleeving,
                  options: ctrl.oversleevingOptions,
                ),
                _buildDropdownField(
                  label: 'Cable Gland Required',
                  value: ctrl.bCableGland,
                  options: ctrl.glandRequiredOptions,
                ),
                _buildDropdownField(
                  label: 'Pulling Sock',
                  value: ctrl.bPullingSock,
                  options: ctrl.pullingSockOptions,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardSection(
              title: 'Project Details',
              children: [
                _buildInputField(
                  label: 'Project Name',
                  controller: ctrl.projectName,
                  hintText: 'Enter text..',
                ),
                _buildInputField(
                  label: 'Email *',
                  controller: ctrl.email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Enter email..',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!GetUtils.isEmail(val.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  label: 'Contact Number *',
                  controller: ctrl.contactNumber,
                  keyboardType: TextInputType.phone,
                  hintText: 'Enter contact phone..',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Contact number is required';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  label: 'Quantity Required',
                  controller: ctrl.quantityRequired,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter quantity..',
                ),
                _buildInputField(
                  label: 'Additional Notes',
                  controller: ctrl.additionalNotes,
                  maxLines: 3,
                  hintText:
                      'Any special routing, staggering, or jacket requirements...',
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
                      : () => ctrl.submitCableForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandNavy,
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
                          'Submit Cable Assembly Inquiry',
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
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
                    onPressed: () => ctrl.callSupport(),
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
            const SizedBox(height: 18),
          ],
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
    String hintText = 'Enter value..',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              fontFamily: _poppins,
              fontSize: 13.5,
              color: _textDark,
            ),
            decoration: InputDecoration(
              hintText: hintText,
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
}

/// 3. Cable Engineering & Specification Notes Card
class CableEngineeringNotesWidget extends StatelessWidget {
  const CableEngineeringNotesWidget({super.key, required this.richText});

  final CableAssembliesRichTextData richText;

  factory CableEngineeringNotesWidget.fromContentJson(
      Map<String, dynamic> json) {
    return CableEngineeringNotesWidget(
      richText: CableAssembliesRichTextData.fromContentJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBullets = richText.bulletPoints
        .where((b) =>
            !b.toLowerCase().contains('colour') &&
            !b.toLowerCase().contains('om1') &&
            !b.toLowerCase().contains('os2') &&
            !b.toLowerCase().contains('aqua') &&
            !b.toLowerCase().contains('red'))
        .toList();

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
            const Divider(
                height: 18, color: Color(0xFFE2E8F0), thickness: 0.8),
            const Text(
              'OVERSHEATH & CABLE STANDARD COLOURS',
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
                    label: 'OM1: Orange', dotColor: const Color(0xFFFF7A00)),
                _buildColorChip(
                    label: 'OM3/4/5: Aqua', dotColor: const Color(0xFF00B4D8)),
                _buildColorChip(
                    label: 'OS2: Yellow', dotColor: const Color(0xFFEAB308)),
                _buildColorChip(
                    label: 'Fire Rated: Red', dotColor: const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'MANUFACTURING & MEASUREMENT GUIDELINES',
              style: TextStyle(
                fontFamily: _poppins,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            if (filteredBullets.isNotEmpty)
              ...filteredBullets.map(
                (b) => _buildSpecBullet(b, isLast: b == filteredBullets.last),
              )
            else ...[
              _buildSpecBullet(
                'Staggered connectors are paired and spaced 40mm apart',
              ),
              _buildSpecBullet(
                'Cable Length: Measured from end of connector A End to end of connector B End',
              ),
              _buildSpecBullet(
                'Drum recommended for lengths in excess of 40m',
              ),
              _buildSpecBullet(
                'Breakout length is measured from breakout point to longest staggered connector',
                isLast: true,
              ),
            ],
          ],
        ),
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

  Widget _buildSpecBullet(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 7),
            child: Icon(
              Icons.fiber_manual_record,
              size: 6,
              color: _brandNavy,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: _poppins,
                fontSize: 11.5,
                height: 1.35,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
