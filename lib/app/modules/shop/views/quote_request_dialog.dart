import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/shop/models/registry_form_model.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';

class QuoteRequestDialog extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final String productId;
  final String currentVariantId;
  final RxBool isSubmittingQuote;
  final Future<void> Function(Map<String, dynamic> formData) onSubmit;
  final RegistryForm form;

  const QuoteRequestDialog({
    Key? key,
    required this.productDetails,
    required this.productId,
    required this.currentVariantId,
    required this.isSubmittingQuote,
    required this.onSubmit,
    required this.form,
  }) : super(key: key);

  @override
  State<QuoteRequestDialog> createState() => _QuoteRequestDialogState();
}

class _QuoteRequestDialogState extends State<QuoteRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _dropdownValues = {};
  bool _termsAccepted = false;

  late List<RegistryFormField> _numberFields;
  late List<RegistryFormField> _selectFields;
  late List<RegistryFormField> _textareaFields;
  late List<RegistryFormField> _checkboxFields;
  late List<RegistryFormField> _hiddenFields;

  @override
  void initState() {
    super.initState();
    _partitionFields();
    for (final field in widget.form.fields) {
      if (field.type == 'number' || field.type == 'textarea') {
        _textControllers[field.name] = TextEditingController();
      }
      if (field.type == 'select' && field.options.isNotEmpty) {
        _dropdownValues[field.name] = null;
      }
    }
  }

  void _partitionFields() {
    _hiddenFields =
        widget.form.fields.where((f) => f.type == 'hidden').toList();
    _numberFields =
        widget.form.fields.where((f) => f.type == 'number').toList();
    _selectFields =
        widget.form.fields.where((f) => f.type == 'select').toList();
    _textareaFields =
        widget.form.fields.where((f) => f.type == 'textarea').toList();
    _checkboxFields =
        widget.form.fields.where((f) => f.type == 'checkbox').toList();
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _availableQuantity {
    final qty = widget.productDetails['quantity'];
    if (qty is num) return qty.toInt();
    return int.tryParse(qty?.toString() ?? '') ?? 9999;
  }

  String get _productName => widget.productDetails['name']?.toString() ?? '';

  String get _productSku => widget.productDetails['sku']?.toString() ?? '';

  String? get _productImage {
    final gallery = widget.productDetails['gallery'];
    if (gallery is List && gallery.isNotEmpty && gallery.first != null) {
      return HelperFunctions().getImage(gallery.first);
    }
    final img = widget.productDetails['featured_image'] ??
        widget.productDetails['featuredImage'];
    if (img != null) return HelperFunctions().getImage(img);
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please agree to the Terms & Conditions and Privacy Policy.'),
          backgroundColor: themeRedColor,
        ),
      );
      return;
    }

    final Map<String, dynamic> formData = {};

    for (final f in _hiddenFields) {
      if (f.name == 'product_id') {
        formData[f.name] = widget.productId;
      } else if (f.name == 'variant_id') {
        formData[f.name] = widget.currentVariantId;
      } else {
        formData[f.name] = '';
      }
    }

    for (final f in [..._numberFields, ..._textareaFields]) {
      formData[f.name] = _textControllers[f.name]?.text ?? '';
    }
    for (final f in _selectFields) {
      formData[f.name] = _dropdownValues[f.name] ?? '';
    }
    for (final f in _checkboxFields) {
      formData[f.name] = _termsAccepted ? 'agreed' : '';
    }

    await widget.onSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.themeWhiteColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductCard(),
                    const SizedBox(height: 16),
                    _buildTwoColumnRow(),
                    ..._textareaFields.map(_buildTextareaField),
                    ..._checkboxFields.map(_buildCheckboxField),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.themeBorderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Request a Quote',
            style: txtTheme().headlineMedium!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.themeTextColor),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.close, size: 22, color: context.themeTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: context.themeBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: (_productImage != null &&
                    _productImage!.isNotEmpty &&
                    _productImage != HelperFunctions.getNoImage())
                ? Container(
                    width: 60,
                    height: 60,
                    color: context.themegreyColor,
                    child: CachedNetworkImage(
                      imageUrl: _productImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const SizedBox(
                        width: 60,
                        height: 60,
                        child: ProductImagePlaceholder(radius: 6),
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 60,
                    height: 60,
                    child: ProductImagePlaceholder(radius: 6),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _productName,
                  style: txtTheme().bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.themeTextColor),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_productSku.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'SKU: $_productSku',
                    style: txtTheme().bodySmall!.copyWith(
                        color: context.themeSecondrytext, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow() {
    if (_numberFields.isEmpty && _selectFields.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_numberFields.isNotEmpty)
          Expanded(child: _buildNumberField(_numberFields.first)),
        if (_numberFields.isNotEmpty && _selectFields.isNotEmpty)
          const SizedBox(width: 12),
        if (_selectFields.isNotEmpty)
          Expanded(child: _buildSelectField(_selectFields.first)),
      ],
    );
  }

  Widget _buildNumberField(RegistryFormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(field.label, required: field.required),
        const SizedBox(height: 6),
        TextFormField(
          controller: _textControllers[field.name],
          keyboardType: TextInputType.number,
          style: TextStyle(color: context.themeTextColor, fontSize: 14),
          decoration: _inputDecoration(field.placeholder.isNotEmpty
              ? field.placeholder
              : 'Enter quantity'),
          validator: (val) {
            if (field.required && (val == null || val.trim().isEmpty)) {
              return 'Required';
            }
            final n = int.tryParse(val?.trim() ?? '');
            if (n == null) return 'Enter a valid number';
            if (n < field.min) return 'Min is ${field.min}';
            if (n > _availableQuantity) {
              return 'Cannot exceed $_availableQuantity';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Available Quantity: $_availableQuantity',
          style: txtTheme()
              .bodySmall!
              .copyWith(fontSize: 11, color: context.themeSecondrytext),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSelectField(RegistryFormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(field.label, required: field.required),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: _inputDecoration('Select timeline'),
          isExpanded: true,
          dropdownColor: context.themeWhiteColor,
          items: field.options
              .map((o) => DropdownMenuItem(
                  value: o.value,
                  child: Text(o.label,
                      style: TextStyle(color: context.themeTextColor))))
              .toList(),
          onChanged: (val) => setState(() => _dropdownValues[field.name] = val),
          validator: field.required
              ? (val) => (val == null || val.isEmpty) ? 'Required' : null
              : null,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextareaField(RegistryFormField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(field.label, required: field.required),
        const SizedBox(height: 6),
        TextFormField(
          controller: _textControllers[field.name],
          maxLines: field.rows > 0 ? field.rows : 5,
          style: TextStyle(color: context.themeTextColor, fontSize: 14),
          decoration: _inputDecoration(field.placeholder.isNotEmpty
              ? field.placeholder
              : 'Enter details...'),
          validator: field.required
              ? (val) => (val == null || val.trim().isEmpty) ? 'Required' : null
              : null,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCheckboxField(RegistryFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _termsAccepted,
              activeColor: themeRedColor,
              onChanged: (val) => setState(() => _termsAccepted = val ?? false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: txtTheme()
                    .bodySmall!
                    .copyWith(fontSize: 12, color: context.themeTextColor),
                children: const [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                        color: themeRedColor,
                        decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        color: themeRedColor,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = widget.isSubmittingQuote.value;
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themePrimaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: loading ? null : _submit,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'SUBMIT QUOTE REQUEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      );
    });
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: txtTheme().bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: context.themeTextColor),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: themeRedColor)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.themeSecondrytext, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: context.themeBorderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: context.themeBorderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: themeRedColor)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: themeRedColor)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: themeRedColor)),
      filled: true,
      fillColor: context.themegreyColor,
    );
  }
}
