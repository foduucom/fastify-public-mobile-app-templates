// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// import 'package:flutter/material.dart';
// import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
// import 'package:get/get.dart';
// import '../../../../../../constants/constants.dart';

// class NotificationView extends GetView<ProfileController> {
//   NotificationView({Key? key}) : super(key: key);
//   final _controller = Get.lazyPut<ProfileController>(() => ProfileController());
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: AppBar(
//             title: Text('Notification',
//                 style: TextStyle(
//                     fontFamily: 'lato',
//                     fontSize: 16,
//                     color: themeTextColor,
//                     fontWeight: FontWeight.w600)),
//             iconTheme: IconThemeData(
//               color: Colors.black,
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//           ),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: pageSurroundingPadding,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 32,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: controller.notification.length,
//                       itemBuilder: (context, index) {
//                         return Obx(() {
//                           return GestureDetector(
//                             onTap: () {
//                               controller.selectNotification.value = index;
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.only(right: 15),
//                               child: Container(
//                                 width: 90,
//                                 decoration: BoxDecoration(
//                                     color:
//                                         controller.selectNotification.value ==
//                                                 index
//                                             ? const Color(0xFFFF4C3B)
//                                             : themegreyColor,
//                                     borderRadius: BorderRadius.circular(3)),
//                                 child: Center(
//                                   child: Text(
//                                     controller.notification[index]['name'],
//                                     style: TextStyle(
//                                         fontFamily: 'Lato',
//                                         color: controller
//                                                     .selectNotification.value ==
//                                                 index
//                                             ? themeWhiteColor
//                                             : themeTextColor,
//                                         fontSize: 14),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         });
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   SizedBox(
//                     height: 500,
//                     child: ListView.separated(
//                         physics: NeverScrollableScrollPhysics(),
//                         itemBuilder: ((context, index) {
//                           return Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(5),
//                                 child: Image.asset(
//                                     'assets/images/notification.png',
//                                     height: 70,
//                                     width: 70,
//                                     fit: BoxFit.cover),
//                               ),
//                               SizedBox(width: 10),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.62,
//                                       child: Text(
//                                           'Exclusive Brand Day Sale!! HURRY, LIMITED period offer!',
//                                           style: TextStyle(
//                                               fontFamily: 'lato',
//                                               color: themeTextColor,
//                                               fontWeight: FontWeight.w600))),
//                                   SizedBox(height: 10.0),
//                                   Text('10 July, 2021',
//                                       style: TextStyle(
//                                           fontFamily: 'lato',
//                                           color: themeSecondryColor)),
//                                 ],
//                               )
//                             ],
//                           );
//                         }),
//                         separatorBuilder: (context, index) => const Divider(
//                               thickness: 0.9,
//                               color: themegreyColor,
//                             ),
//                         itemCount: 8),
//                   )
//                 ],
//               ),
//             ),
//           )),
//     );
//   }
// }
