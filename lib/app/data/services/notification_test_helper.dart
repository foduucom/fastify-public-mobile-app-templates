import 'package:zouhi/app/data/services/notification_service.dart';

class NotificationTestHelper {
  /// Scenario 1: User Registration (Welcome)
  /// Target: Shop/Home (`/shop` or `/home`)
  static void triggerWelcomeNotification() {
    final payload = {"type": "welcome"};
    NotificationService.navigateOnNotificationClick(payload);
  }

  /// Scenario 2: Order Placement Success
  /// Target: Order Details (`/order-details`) with arguments `{'id': '98213'}`
  static void triggerOrderSuccessNotification({String orderNo = "98213"}) {
    final payload = {"type": "order", "order_no": orderNo};
    NotificationService.navigateOnNotificationClick(payload);
  }

  /// Scenario 3: Order Dispatch & Delivery
  /// Target: Order Details (`/order-details`) with arguments `{'id': '98213'}`
  static void triggerOrderDispatchNotification({String orderNo = "98213"}) {
    final payload = {"type": "order", "order_no": orderNo};
    NotificationService.navigateOnNotificationClick(payload);
  }

  /// Scenario 4: Account Security (New Login)
  /// Target: Security Settings (`/security-settings`)
  static void triggerSecurityAlertNotification() {
    final payload = {"type": "security"};
    NotificationService.navigateOnNotificationClick(payload);
  }

  /// Scenario 5: Cart Abandonment Reminder
  /// Target: Cart Screen (`/cart`)
  static void triggerCartAbandonmentNotification() {
    final payload = {"type": "cart"};
    NotificationService.navigateOnNotificationClick(payload);
  }

  /// Scenario 6: Promo/Broadcast (Topics)
  /// Target: Shop Screen (`/shop`)
  static void triggerPromoNotification() {
    final payload = {"type": "promo"};
    NotificationService.navigateOnNotificationClick(payload);
  }
}
