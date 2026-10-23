// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';

// import '../../constants/constants.dart';

// class CategoryShimmer extends StatelessWidget {
//   final int index;
//   const CategoryShimmer({Key? key, required this.index}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey, width: 1.0),
//                 borderRadius: BorderRadius.circular(15.0)),
//             child: index % 2 == 0
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 40),
//                           child: Container(
//                               height: Get.height * 0.13,
//                               width: 80,
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10))),
//                         ),
//                         const SizedBox(height: 15),
//                         Padding(
//                           padding: const EdgeInsets.only(right: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Container(
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   width: 100),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Container(
//                                   height: 10,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   width: 135),
//                             ],
//                           ),
//                         )
//                       ])
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   width: 100),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Container(
//                                   height: 10,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   width: 135),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Padding(
//                           padding: const EdgeInsets.only(right: 40),
//                           child: Container(
//                               height: Get.height * 0.13,
//                               width: 80,
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10))),
//                         )
//                       ])));
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/constants/theme_ext.dart';

import '../../constants/constants.dart';

class CategoryShimmer extends StatelessWidget {
  final int index;
  const CategoryShimmer({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: Get.width * 0.28, // Same as category item
            height: Get.width * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.themeWhiteColor,
              border: Border.all(
                color: themePrimaryColor,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

