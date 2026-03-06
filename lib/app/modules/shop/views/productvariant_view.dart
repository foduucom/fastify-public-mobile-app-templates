// // ignore_for_file: prefer_const_constructors, sort_child_properties_last

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:foduu_ecommerce/app/modules/shop/controllers/productvariant_controller.dart';
// import 'package:foduu_ecommerce/components/colorextenstion.dart';
// import 'package:foduu_ecommerce/components/shimmer_effects.dart';
// import 'package:foduu_ecommerce/constants/constants.dart';
// import 'package:foduu_ecommerce/constants/helper_functions.dart';
// import 'package:foduu_ecommerce/constants/theme.dart';
// import 'package:get/get.dart';

// class ProductvariantView extends GetView<ProductvariantController> {
//   ProductvariantView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Obx(() {
//             if (controller.productDetials['name'] == null) {
//               return ShimmerEffect(height: 10, width: 100);
//             } else {
//               return Text(
//                 controller.productDetials['name'].toString(),
//                 style: const TextStyle(
//                     fontFamily: 'Lato',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600),
//               );
//             }
//           }),
//           titleSpacing: 0.0,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: Stack(
//           children: [
//             Positioned(
//               top: 0,
//               right: 0,
//               left: 0,
//               bottom: 0,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Obx(() {
//                       if (controller.productDetials['image'] == null) {
//                         return ShimmerEffect(
//                             height: Get.height * 0.6, width: Get.width);
//                       } else {
//                         return ClipRRect(
//                             borderRadius: BorderRadius.circular(3),
//                             child: CachedNetworkImage(
//                               height: Get.height * 0.6,
//                               width: Get.width,
//                               fit: BoxFit.cover,
//                               imageUrl:
//                                   controller.productDetials['image'].toString(),
//                               errorWidget: (context, url, error) => Container(
//                                 decoration:
//                                     BoxDecoration(color: Colors.grey.shade300),
//                                 child: Center(
//                                   child: Icon(Icons.error),
//                                 ),
//                               ),
//                               progressIndicatorBuilder:
//                                   (context, url, progress) => Container(
//                                 decoration:
//                                     BoxDecoration(color: Colors.grey.shade300),
//                                 height: 165,
//                                 child: Center(
//                                   child: SizedBox(
//                                     height: 40,
//                                     width: 40,
//                                     child: HelperFunctions().loadingIndicator(),
//                                   ),
//                                 ),
//                               ),
//                             ));
//                       }
//                     }),
//                     SizedBox(height: 8.0),
//                     Padding(
//                       padding: pageSurroundingPadding,
//                       child: Obx(() {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             controller.productDetials['name'] == null
//                                 ? ShimmerEffect(height: 10, width: 100)
//                                 : Text(
//                                     controller.productDetials['name']
//                                         .toString(),
//                                     style: txtTheme().headlineSmall),
//                             SizedBox(height: 10),
//                             Html(
//                               data: controller.productDetials['content'] ?? "",
//                               style: {
//                                 "body": Style(
//                                     // padding: EdgeInsets.zero,
//                                     fontFamily: "Lato")
//                               },
//                             ),
//                             SizedBox(height: 10),
//                             Html(
//                               data: controller.productDetials['long_content'] ??
//                                   "",
//                               style: {
//                                 "body": Style(
//                                     // padding: EdgeInsets.zero,
//                                     fontFamily: "Lato")
//                               },
//                             ),
//                             SizedBox(height: 10),
//                             Text("Product Price: ",
//                                 style: txtTheme().headlineSmall),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text("₹",
//                                     style: txtTheme()
//                                         .titleLarge!
//                                         .copyWith(fontSize: 20)),
//                                 Text(
//                                   controller.productDetials['sale_price'] ??
//                                       '0'.toString(),
//                                   style: txtTheme()
//                                       .titleLarge!
//                                       .copyWith(fontSize: 20),
//                                 ),
//                                 SizedBox(width: 04),
//                                 Text(
//                                   controller.productDetials['price'].toString(),
//                                   style: txtTheme().titleLarge!.copyWith(
//                                       decoration: TextDecoration.lineThrough),
//                                 )
//                               ],
//                             ),
//                             SizedBox(height: 10),
//                             Text("Select Color: ",
//                                 style: txtTheme().headlineSmall),
//                             SizedBox(height: 10),
//                             Row(
//                               children: List.generate(
//                                   controller.colorList.length,
//                                   (index) => Padding(
//                                         padding: EdgeInsets.only(right: 10),
//                                         child: Container(
//                                           width: 35,
//                                           height: 35,
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(50),
//                                               color:
//                                                   '${controller.colorList[index]['value']}'
//                                                       .toColor()),
//                                         ),
//                                       )),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("Select Size:",
//                                     style: TextStyle(
//                                         fontFamily: 'lato', fontSize: 16)),
//                                 GestureDetector(
//                                   onTap: () => sizeModel(context),
//                                   child: Text("Size Chart",
//                                       style: TextStyle(
//                                           fontFamily: 'lato', fontSize: 14)),
//                                 )
//                               ],
//                             ),
//                             SizedBox(height: 10),
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                   color: const Color(0xFFFF4C3B),
//                                   borderRadius: BorderRadius.circular(50)),
//                               child: Center(
//                                 child: Obx(() {
//                                   return Text(
//                                     controller.getYourSize.value.toString(),
//                                     style: TextStyle(
//                                         fontFamily: 'Lato', fontSize: 16),
//                                   );
//                                 }),
//                               ),
//                             ),
//                             // Row(
//                             //   children: List.generate(
//                             //       controller.sizeList.length,
//                             //       (index) => Padding(
//                             //             padding: EdgeInsets.only(right: 10),
//                             //             child: Container(
//                             //               width: 35,
//                             //               height: 35,
//                             //               decoration: BoxDecoration(
//                             //                   borderRadius:
//                             //                       BorderRadius.circular(50),
//                             //                   color: Colors.red),
//                             //               child: Center(
//                             //                 child: Text(
//                             //                   controller.sizeList[index]
//                             //                           ['value']
//                             //                       .toString(),
//                             //                   style: txtTheme()
//                             //                       .titleLarge!
//                             //                       .copyWith(
//                             //                           color: Colors.white),
//                             //                 ),
//                             //               ),
//                             //             ),
//                             //           )),
//                             // ),
//                             SizedBox(height: 100)
//                           ],
//                         );
//                       }),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//                 bottom: 0,
//                 child: Material(
//                   elevation: 10,
//                   child: Container(
//                       width: Get.width,
//                       height: 50,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton.icon(
//                               onPressed: () {},
//                               icon: SvgPicture.asset(
//                                   'assets/icon/appbarlike.svg'),
//                               label: const Text("WISHLIST",
//                                   style: TextStyle(
//                                     fontFamily: 'lato',
//                                     fontSize: 16,
//                                   )),
//                               style: ElevatedButton.styleFrom(
//                                   elevation: 0,
//                                   backgroundColor: Colors.transparent)),
//                           ElevatedButton.icon(
//                               onPressed: () {},
//                               icon: SvgPicture.asset(
//                                   'assets/icon/appbarshop.svg'),
//                               label: const Text("ADD TO BAG",
//                                   style: TextStyle(
//                                     fontFamily: 'lato',
//                                     fontSize: 16,
//                                   )),
//                               style: ElevatedButton.styleFrom(
//                                   elevation: 0,
//                                   backgroundColor: Colors.transparent))
//                         ],
//                       )),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }

//   sizeModel(BuildContext context) {
//     return Get.defaultDialog(
//         title: "",
//         titleStyle: TextStyle(height: 0.0),
//         contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
//         content: SizedBox(
//           width: MediaQuery.of(context).size.width * 80,
//           height: Get.height * 0.20,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Select Your Size',
//                 style: txtTheme().headlineSmall,
//               ),
//               SizedBox(
//                 height: 30,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: controller.sizeList.length,
//                   itemBuilder: (context, index) {
//                     return Obx(() {
//                       return GestureDetector(
//                         onTap: () {
//                           controller.getSelectedSize.value = index;
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 15),
//                           child: Container(
//                             width: 40,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(3)),
//                             child: Center(
//                               child: Text(
//                                 controller.sizeList[index]['value'].toString(),
//                                 style:
//                                     TextStyle(fontFamily: 'Lato', fontSize: 16),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     });
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: 45,
//                 width: Get.width,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Get.back();
//                     controller.sizeOnSubmit();
//                   },
//                   child: Text('Submit'.toUpperCase(),
//                       style:
//                           txtTheme().titleLarge!.copyWith(color: Colors.white)),
//                   style: themeButton,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         radius: 0.0);
//   }
// }
