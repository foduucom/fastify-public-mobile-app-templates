// ignore_for_file: avoid_print

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/foduuStudio/foduu_studio_layout_mixin.dart';

class CustomPageController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  var pageSlug = 'home';
  var pageLable = '';

  @override
  Future<void> onInit() async {
    super.onInit();

    Get.arguments['label'] != null
        ? pageLable = Get.arguments['label']
        : pageLable = 'Foduu';

    Get.arguments['slug'] != null
        ? pageSlug = Get.arguments['slug']
        : pageSlug = 'home';

    await fetchLayout(pageSlug);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
