// lib/app/modules/security/controllers/security_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SecurityController extends GetxController {
  final _box = GetStorage();

  var isFaceIdEnabled        = false.obs;
  var isRememberPassword     = false.obs;
  var isTouchIdEnabled       = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved preferences
    isFaceIdEnabled.value    = _box.read('face_id')    ?? false;
    isRememberPassword.value = _box.read('remember_pw') ?? false;
    isTouchIdEnabled.value   = _box.read('touch_id')   ?? false;
  }

  void toggleFaceId(bool value) {
    isFaceIdEnabled.value = value;
    _box.write('face_id', value);
  }

  void toggleRememberPassword(bool value) {
    isRememberPassword.value = value;
    _box.write('remember_pw', value);
  }

  void toggleTouchId(bool value1) {
    isTouchIdEnabled.value = value1;
    _box.write('touch_id', value1);
  }
}
