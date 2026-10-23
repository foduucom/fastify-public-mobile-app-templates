import 'package:get/get.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/shop/models/registry_form_model.dart';
import 'package:zouhi/app/modules/shop/views/quote_request_dialog.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';

class RegistryQuoteFlow with BaseController {
  Future<void> open(String productId, {String? variantId}) async {
    if (!AuthDetails.isUserLogin()) {
      HelperFunctions.showLoginDialog('You need to log in to request a quote.');
      return;
    }

    HelperFunctions().showOverlayLoader();
    var response = await BasicProvider("products/$productId")
        .getRequest()
        .catchError(handleError);
    Get.back(); // close loader

    RegistryForm? form;
    if (response is Map &&
        response['is_registry'] == true &&
        response['registry_form_id'] is Map) {
      try {
        form = RegistryForm.fromJson(
            Map<String, dynamic>.from(response['registry_form_id']));
      } catch (_) {
        form = null;
      }
    }

    if (form == null) {
      HelperFunctions.defaultdialogbox(
          'Unable to load quote form. Please try again.', themeRedColor);
      return;
    }

    final isSubmittingQuote = false.obs;

    Get.dialog(QuoteRequestDialog(
      productDetails: Map<String, dynamic>.from(response),
      productId: productId,
      currentVariantId: variantId ?? '',
      isSubmittingQuote: isSubmittingQuote,
      onSubmit: (formData) => _submit(form!, formData, isSubmittingQuote),
      form: form,
    ));
  }

  Future<void> _submit(
    RegistryForm form,
    Map<String, dynamic> formData,
    RxBool isSubmittingQuote,
  ) async {
    isSubmittingQuote.value = true;
    try {
      var response = await BasicProvider(form.submitEndpoint)
          .postRequest(formData)
          .catchError(handleError);
      if (response != null) {
        Get.back();
        HelperFunctions.defaultdialogbox(
            'Quote submitted successfully!', themeGreenColor);
      }
    } catch (e) {
      HelperFunctions.defaultdialogbox(
          'Submission failed. Please try again.', themeRedColor);
    } finally {
      isSubmittingQuote.value = false;
    }
  }
}
