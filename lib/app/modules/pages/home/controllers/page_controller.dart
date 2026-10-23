import 'dart:convert';

import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' show parse;

class PagesController extends GetxController with BaseController {
  var isLoading = false.obs;
  final count = 0.obs;
  var pagedata = ''.obs;
  var name = ''.obs;
  var images = <String>[].obs; // Variable to hold image URLs

  @override
  void onInit() {
    super.onInit();
    try {
      printInfo(info: 'argument argument ${Get.arguments}');
      if (Get.arguments is Map) {
        var args = Get.arguments as Map; // Cast to Map
        printInfo(info: 'argument slug ${args['slug']}');
        getPage(slug: args['slug']);
      } else {
        print(
            'Expected arguments to be a Map but got ${Get.arguments.runtimeType}');
      }
    } catch (e) {
      print('error is here, $e');
    }
  }

  Future<void> getPage({required String slug}) async {
    isLoading(true);

    try {
      // 'frontend/pages/show'
      // var response = await BasicProvider("cms/pages/show/${slug}")
      var response = await BasicProvider("public/pages/show/${slug}")
          .getRequest()
          .catchError(handleError);

      print('Response from API: $response');

      if (response != null && response is Map) {
        // Update the name and pagedata
        name.value = response['name'] ?? '';
        updatePageData(
            response['content'] ?? ''); // Update pagedata and extract images
      } else {
        print('Error fetching page: Response is not a valid Map structure.');
        name.value = 'Page Not Found';
        updatePageData('<p>The requested page could not be loaded.</p>');
      }
    } catch (e) {
      print('Error fetching page: $e');
    } finally {
      isLoading(false);
    }
  }

  void extractImages() {
    // Clear the previous list of images
    images.clear();

    // Parse the HTML data only if it's not empty
    if (pagedata.value.isNotEmpty) {
      final document = parse(pagedata.value);
      final imageElements = document.getElementsByTagName('img');

      // Extract the src attributes and remove the images from the HTML
      for (var element in imageElements) {
        final src = element.attributes['src'];
        if (src != null) {
          images.add(src);
          print('Found image: $src'); // Log found images
        }
        // Remove the image element from the document
        element.remove();
      }

      // Clean up the HTML to remove extra spaces and empty tags
      pagedata.value = _cleanHtml(document.body?.innerHtml ?? '');
      print('Total images extracted: ${images.length}');
    } else {
      print('No pagedata to parse for images.');
    }
  }

  String _cleanHtml(String html) {
    // Remove empty tags and unnecessary spaces
    String cleanedHtml = html
        .replaceAll(
            RegExp(r'<\s*[^>]*>\s*</\s*[^>]*>'), '') // Remove empty tags
        .replaceAll(RegExp(r'\s+'),
            ' ') // Replace multiple spaces/new lines with a single space
        .trim(); // Trim leading and trailing whitespace

    return cleanedHtml;
  }

  void updatePageData(String data) {
    pagedata.value = data;
    extractImages(); // Extract images after updating data
  }
}
