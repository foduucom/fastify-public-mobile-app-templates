// import 'package:flutter/material.dart';
// import 'package:foduu_ecommerce/app/routes/app_pages.dart';
// import 'package:foduu_ecommerce/constants/constants.dart';
// import 'package:foduu_ecommerce/constants/theme.dart';
// import 'package:get/get.dart';

// class OfferCorner extends StatefulWidget {
//   List offerCornerList = [];
//   OfferCorner({super.key, required this.offerCornerList});

//   @override
//   State<OfferCorner> createState() => _OfferCornerState();
// }

// class _OfferCornerState extends State<OfferCorner>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: pageSurroundingPadding,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 10),
//           Text(
//             'Offer Corner',
//             style: txtTheme().displayMedium,
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 100,
//             child: GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                   maxCrossAxisExtent: 200,
//                   childAspectRatio: 7 / 1.7,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10),
//               itemCount: widget.offerCornerList.length,
//               itemBuilder: ((context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
//                       'name':
//                           'Below ${widget.offerCornerList[index]['below_price']}',
//                       'source': 'offerCorner',
//                       'price': widget.offerCornerList[index]['below_price']
//                     });
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(3),
//                         image: DecorationImage(
//                             image: const AssetImage('assets/images/bg.png'),
//                             fit: BoxFit.cover)),
//                     child: Center(
//                       child: Text(
//                         'Under \u{20B9}${widget.offerCornerList[index]['below_price'].toString()}',
//                         style: const TextStyle(
//                             fontSize: 16,
//                             fontFamily: 'Lato',
//                             fontWeight: FontWeight.w400),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//           const SizedBox(height: 5),
//         ],
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
