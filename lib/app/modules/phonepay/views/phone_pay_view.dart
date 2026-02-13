 
// import 'package:flutter/material.dart';
// import 'package:foduu_ecommerce/app/modules/phonepay/controllers/phonepay_controller.dart';
// import 'package:get/get.dart';

// class PhonePayView extends GetView<PhonePayController> {
//   const PhonePayView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//             appBar: AppBar(
//               leading: Transform.translate(
//                 offset: const Offset(15, 0),
//                 child: Image.asset('assets/images/logo.png'),
//               ),
//               leadingWidth: 77,
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//             ),
//             body: Obx(
//               () => Column(
//                 children: [
//                   ElevatedButton(
//                       onPressed: () {
//                         controller.startPgTransaction();
//                       },
//                       child: Text('payment')),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Text('result ${controller.resultValue}')
//                 ],
//               ),
//             )));
//   }
// }
