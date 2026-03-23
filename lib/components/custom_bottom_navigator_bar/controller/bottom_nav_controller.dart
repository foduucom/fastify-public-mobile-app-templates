import 'package:get/get.dart';

class BottomNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;   // ✅ REMOVED the index == 2 skip
  }

  void onScanTap() {
    selectedIndex.value = 2;       // ✅ FIXED: was 3, now correctly 2 = AI screen
  }
}
