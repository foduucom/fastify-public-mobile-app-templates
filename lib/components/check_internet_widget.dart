import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

// ignore: must_be_immutable
class FoduuCheckInternetBody extends StatelessWidget {
  FoduuCheckInternetBody({Key? key, required this.child}) : super(key: key);

  final Widget child;

  final internetState = Get.find<InternetconnectionController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Obx(
          () => !internetState.connectionStatus.value
              ? const Scaffold(body: InternetConnectionError())
              : Container(),
        ),
      ],
    );
  }
}

class InternetConnectionError extends StatelessWidget {
  final VoidCallback? onRetry;
  const InternetConnectionError({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lotti/no-internet.json',
              width: 250,
              height: 250,
              errorBuilder: (context, error, stackTrace) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 120,
                    color: context.themeRedColor,
                  ),
                );
              },
            ),
            const Text("Sorry!",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
            const Text("No internet connection!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themeRedColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onRetry,
                child: Text(
                  "Retry",
                  style: TextStyle(
                      color: context.colors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ]),
    );
  }
}

/// Shown when a request failed for a reason other than connectivity (server
/// error, unexpected response). Never claims the user is offline.
class GenericErrorRetry extends StatelessWidget {
  final VoidCallback? onRetry;
  const GenericErrorRetry({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 100, color: context.themeRedColor),
          const SizedBox(height: 16),
          const Text("Something went wrong",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Please try again in a moment.",
              style: TextStyle(fontSize: 15)),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themeRedColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onRetry,
              child: Text("Retry",
                  style: TextStyle(
                      color: context.colors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
