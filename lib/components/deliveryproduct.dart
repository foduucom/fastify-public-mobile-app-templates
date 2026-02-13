// import 'package:flutter/cupertino.dart';
// import 'package:foduu_ecommerce/constants/theme.dart';
// import '../constants/constants.dart';

// class deliveryCartProducts extends StatelessWidget {
//   deliveryCartProducts({
//     required this.assetImage,
//     required this.productName,
//     required this.deliveryDate,
//     Key? key,
//   }) : super(key: key);
//   String assetImage;
//   String productName;
//   String deliveryDate;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(5),
//               child: Image.asset(assetImage,
//                   height: 90, width: 90, fit: BoxFit.cover),
//             ),
//             SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(productName,
//                     style: const TextStyle(
//                       fontFamily: 'lato',
//                     )),
//                 const SizedBox(height: 5.0),
//                 RichText(
//                     text: TextSpan(
//                   text: 'Delivery ',
//                   style: txtTheme().titleLarge!.copyWith(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                       fontFamily: "Lato"),
//                   children: [
//                     TextSpan(
//                         text: "${deliveryDate}th July",
//                         style: const TextStyle()),
//                   ],
//                 ))
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
