import 'package:get/get.dart';

class HomeWishlistControllers extends GetxController {
  RxList<Map<String, dynamic>> favoriteCollections = <Map<String, dynamic>>[
    {
      'title': 'My Favorites',
      'subtitle': '6 Items',
      'images': [
        'assets/images/skirts.png',
        'assets/images/women-1.png',
        'assets/images/kidscard1.png',
        'assets/images/flowerprint.png',
      ],
    },
    {
      'title': 'Formal Collection',
      'subtitle': '4 Items',
      'images': [
        'assets/images/categeory.png',
        'assets/images/categoryimg.png',
        'assets/images/categerrybeauty.png',
        'assets/images/categerryjwellery.png',
      ],
    },
    {
      'title': 'Watch',
      'subtitle': '9 Items',
      'images': [
        'assets/images/categeryshoes.png',
        'assets/images/categoryimg.png',
        'assets/images/categoryimgfive.png',
        'assets/images/categoryimgsix.png',
      ],
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
