// lib/app/modules/notification_settings/controllers/notification_settings_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationSettingsController extends GetxController {
  final _box = GetStorage();

  var isPaymentEnabled    = false.obs;
  var isNewRecipeEnabled  = false.obs;
  var isStreamingEnabled  = false.obs;
  var isNotificationEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    isPaymentEnabled.value      = _box.read('notif_payment')      ?? true;
    isNewRecipeEnabled.value    = _box.read('notif_new_recipe')   ?? true;
    isStreamingEnabled.value    = _box.read('notif_streaming')    ?? true;
    isNotificationEnabled.value = _box.read('notif_notification') ?? true;
  }

  void togglePayment(bool value) {
    isPaymentEnabled.value = value;
    _box.write('notif_payment', value);
  }

  void toggleNewRecipe(bool value) {
    isNewRecipeEnabled.value = value;
    _box.write('notif_new_recipe', value);
  }

  void toggleStreaming(bool value) {
    isStreamingEnabled.value = value;
    _box.write('notif_streaming', value);
  }

  void toggleNotification(bool value) {
    isNotificationEnabled.value = value;
    _box.write('notif_notification', value);
  }
}
