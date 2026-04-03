import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class BlogDetailsController extends GetxController with BaseController {
  var blogDetails = {}.obs;

  late PageController pageController;
  @override
  void onInit() async {
    try {
      var newsID = Get.arguments['id'];

      await getBlogByID(newsID);
    } catch (e) {
      print('ERROR IN newcontronller $e');
    }

    super.onInit();
  }

  Future<void> getBlogByID(String id) async {
    try {
      var response =
          await BasicProvider("blogs/$id").getRequest().catchError(handleError);
      if (response == null) return;
      blogDetails.addAll(response);
    } catch (e) {
      print('vacancy error $e');
    }
  }
}
