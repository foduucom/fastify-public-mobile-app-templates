import '/app/controllers/api_exception_handle_controller.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';

class AboutusController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final pageSlug = 'about-us';

  @override
  void onInit() {
    super.onInit();
    fetchAboutUs();
  }

  Future<void> fetchAboutUs() async {
    await fetchLayout(pageSlug);
  }
}
