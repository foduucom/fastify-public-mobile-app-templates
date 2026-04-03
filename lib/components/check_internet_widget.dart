import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class FoduuCheckInternetBody extends StatelessWidget {
  FoduuCheckInternetBody({Key? key, required this.child}) : super(key: key);

  final Widget child;

  // var internetState = Get.find<InternetconnectionController>();
  // var internetState = Get.put(InternetconnectionController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Obx(
        //   () => !internetState.connectionStatus.value
        //       ? const Scaffold(body: InternetConnectionError())
        //       : Container(),
        // ),
      ],
    );
  }
}

class InternetConnectionError extends StatelessWidget {
  const InternetConnectionError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/no-internet.json'),
          const Text("Sorry!",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
          const Text("No internet connection!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ]);
  }
}
