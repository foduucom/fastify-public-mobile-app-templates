import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zouhi/constants/constants.dart';
import '../controllers/cable_assemblies_controller.dart';

class CableAssembliesView extends GetView<CableAssembliesController> {
  const CableAssembliesView({Key? key}) : super(key: key);

  static const _poppins = 'Poppins';
  static const _brandNavy = Color(0xFF1B3B64);
  static const _brandBlue = Color(0xFF20558A);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textDark = Color(0xFF212529);
  static const _labelColor = Color(0xFF374151);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _brandNavy,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/cable-banner.webp',
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
                )
              else
                Image.asset(
                  'assets/images/cable-banner.webp',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                color: _brandNavy.withValues(alpha: 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.zoom_in_rounded,
                        size: 16, color: _brandNavy),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        textBlock.text.isNotEmpty
                            ? textBlock.text
                            : 'Tap to inspect detailed pinout & schematic',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: _poppins,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _brandNavy,
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
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Cable assemblies',
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
        ),
        body: RefreshIndicator(
          color: _brandNavy,
          onRefresh: () => controller.fetchCableAssembliesLayout(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Engineering Schematic Banner with Tap to Zoom (Server-Driven)
                  _buildSchematicBanner(context),

                  const SizedBox(height: 16),

                // SECTION 1: A END (Pulling End)
                _buildCardSection(
                  title: 'A END (Pulling End)',
                  children: [
                    _buildDropdownField(
                      label: 'Connector Type',
                      value: controller.aConnectorType,
                      options: controller.connectorOptions,
                    ),
                    _buildDropdownField(
                      label: 'Break Out Type',
                      value: controller.aBreakoutType,
                      options: controller.breakoutTypeOptions,
                    ),
                    _buildDropdownField(
                      label: 'Break Out Length (mm)',
                      value: controller.aBreakoutLength,
                      options: controller.breakoutLengthOptions,
                    ),
                    _buildDropdownField(
                      label: 'Break Out Oversleeving',
                      value: controller.aBreakoutOversleeving,
                      options: controller.oversleevingOptions,
                    ),
                    _buildDropdownField(
                      label: 'Cable Gland Required',
                      value: controller.aCableGland,
                      options: controller.glandRequiredOptions,
                    ),
                    _buildDropdownField(
                      label: 'Pulling Sock',
                      value: controller.aPullingSock,
                      options: controller.pullingSockOptions,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // SECTION 2: CABLE
                _buildCardSection(
                  title: 'CABLE',
                  children: [
                    _buildDropdownField(
                      label: 'Cable Selection',
                      value: controller.cableSelection,
                      options: controller.cableSelectionOptions,
                    ),
                    _buildDropdownField(
                      label: 'Mode',
                      value: controller.cableMode,
                      options: controller.cableModeOptions,
                    ),
                    _buildDropdownField(
                      label: 'No. of Cores',
                      value: controller.cableCores,
                      options: controller.coreCountOptions,
                    ),
                    _buildInputField(
                      label: 'Length (Metres)',
                      controller: controller.cableLength,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter no...',
                    ),
                    _buildDropdownField(
                      label: 'Drum Required',
                      value: controller.cableDrum,
                      options: controller.drumOptions,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // SECTION 3: B END
                _buildCardSection(
                  title: 'B END',
                  children: [
                    _buildDropdownField(
                      label: 'Connector Type',
                      value: controller.bConnectorType,
                      options: controller.connectorOptions,
                    ),
                    _buildDropdownField(
                      label: 'Break Out Type',
                      value: controller.bBreakoutType,
                      options: controller.breakoutTypeOptions,
                    ),
                    _buildDropdownField(
                      label: 'Break Out Length (mm)',
                      value: controller.bBreakoutLength,
                      options: controller.breakoutLengthOptions,
                    ),
                    _buildDropdownField(
                      label: 'Break Out Oversleeving',
                      value: controller.bBreakoutOversleeving,
                      options: controller.oversleevingOptions,
                    ),
                    _buildDropdownField(
                      label: 'Cable Gland Required',
                      value: controller.bCableGland,
                      options: controller.glandRequiredOptions,
                    ),
                    _buildDropdownField(
                      label: 'Pulling Sock',
                      value: controller.bPullingSock,
                      options: controller.pullingSockOptions,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // SECTION 4: Project Details
                _buildCardSection(
                  title: 'Project Details',
                  children: [
                    _buildInputField(
                      label: 'Project Name',
                      controller: controller.projectName,
                      hintText: 'Enter text..',
                    ),
                    _buildInputField(
                      label: 'Email *',
                      controller: controller.email,
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
                      controller: controller.contactNumber,
                      keyboardType: TextInputType.phone,
                      hintText: 'Enter contact phone..',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Contact number is required';
                        }
                        return null;
                      },
                    ),
                    // _buildInputField(
                    //   label: 'Company / Alternate Contact',
                    //   controller: controller.companyOrAltContact,
                    //   hintText: 'Enter value..',
                    // ),
                    _buildInputField(
                      label: 'Quantity Required',
                      controller: controller.quantityRequired,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter quantity..',
                    ),
                    _buildInputField(
                      label: 'Additional Notes',
                      controller: controller.additionalNotes,
                      maxLines: 3,
                      hintText:
                          'Any special routing, staggering, or jacket requirements...',
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Technical & Engineering Reference Notes
                _buildTechnicalNotesCard(),

                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => controller.submitCableForm(context),
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

                // Support & Engineering Assistance Card
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

  Widget _buildTechnicalNotesCard() {
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
          if (richText.bulletPoints.isNotEmpty)
            ...richText.bulletPoints
                .where((b) =>
                    !b.toLowerCase().contains('colour') &&
                    !b.toLowerCase().contains('om1') &&
                    !b.toLowerCase().contains('os2') &&
                    !b.toLowerCase().contains('aqua') &&
                    !b.toLowerCase().contains('red'))
                .map(
                  (b) => _buildSpecBullet(b,
                      isLast: b == richText.bulletPoints.last),
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
    );
  });
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
