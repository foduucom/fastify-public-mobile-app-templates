import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/internetconnection_controller.dart';

class OfflineRibbon extends StatelessWidget {
  const OfflineRibbon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InternetconnectionController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<InternetconnectionController>();

    return Obx(() {
      final isOffline = !controller.connectionStatus.value;
      final showBackOnline = controller.showBackOnline.value;

      if (!isOffline && !showBackOnline) {
        return const SizedBox.shrink();
      }

      final double height = 26.0;
      final backgroundColor = isOffline ? Colors.red[700]! : Colors.green[700]!;
      final icon = isOffline ? Icons.wifi_off : Icons.wifi;
      final text = isOffline ? "No Internet Connection • Offline Mode" : "Back Online";

      return Container(
        width: double.infinity,
        height: height,
        color: backgroundColor,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    });
  }
}
