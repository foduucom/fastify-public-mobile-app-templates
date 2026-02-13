// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
// import 'package:get/get.dart';

// import '../../../../../components/buttons/bottombutton.dart';
// import '../../../../../constants/constants.dart';

// class CuponView extends GetView<CartController> {
//   const CuponView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Coupons',
//               style: TextStyle(
//                   fontSize: 16,
//                   color: themeTextColor,
//                   fontWeight: FontWeight.w600)),
//           iconTheme: const IconThemeData(
//             color: Colors.black,
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: Stack(
//           children: [
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Padding(
//                 padding: pageSurroundingPadding,
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 40,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(3),
//                           color: themegreyColor),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Row(
//                           children: [
//                             SvgPicture.asset(
//                               'assets/icon/cupon.svg',
//                               width: 50,
//                             ),
//                             const SizedBox(width: 10),
//                             const Expanded(
//                                 child: Text(
//                               'Apply Coupons',
//                             )),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Flexible(
//                       child: Obx(
//                         () => ListView.separated(
//                             // physics: const NeverScrollableScrollPhysics(),
//                             separatorBuilder: (context, index) => const Divider(
//                                   thickness: 0.9,
//                                   color: themegreyColor,
//                                 ),
//                             itemCount: controller.allCoupon.length,
//                             itemBuilder: ((context, index) {
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(children: [
//                                     Text(controller.allCoupon[index]['code'],
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                         )),
//                                     const SizedBox(width: 10),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(3),
//                                           color: themegreyColor),
//                                       child: const Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 8, vertical: 4),
//                                         child: Text('Save \u{20B9} 20.00',
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: themeSecondrytext)),
//                                       ),
//                                     ),
//                                     const Expanded(child: SizedBox()),
//                                     Obx(
//                                       () => GestureDetector(
//                                         onTap: () {
//                                           controller.isClicked.toggle();
//                                         },
//                                         child:
//                                             controller.isClicked.value == true
//                                                 ? const Text('APPLIED',
//                                                     style: TextStyle(
//                                                       color: themeRedColor,
//                                                     ))
//                                                 : const Text('APPLY',
//                                                     style: TextStyle(
//                                                       color: themeRedColor,
//                                                     )),
//                                       ),
//                                     )
//                                   ]),
//                                   const SizedBox(height: 8.0),
//                                   Text(
//                                       controller.allCoupon[index]
//                                           ['description'],
//                                       style: const TextStyle(
//                                           fontSize: 12,
//                                           color: themeSecondrytext)),
//                                   const SizedBox(height: 8.0),
//                                   const Text('View T&C',
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color: themeGreenColor)),
//                                   const SizedBox(
//                                     height: 20,
//                                   )
//                                 ],
//                               );
//                             })),
//                       ),
//                     ),
//                     bottomButton(
//                       opacity: 0.5,
//                       d
//                       buttonText: 'Apply',
//                       priceText: '1900.00',
//                       keypressEvent: () {},
//                       otherText: 'Maximum savings',
//                     ) 
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
