// import 'package:flutter/material.dart';

// import 'package:get/get.dart';

// class FilterPage extends StatelessWidget {
//   final controller = Get.find<ShopController>();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           title: Text("Filters",
//               style: txtTheme()
//                   .titleLarge!
//                   .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
//         ),
//         body: Stack(
//           children: [
//             Positioned(
//               top: 0,
//               bottom: 0,
//               right: 0,
//               left: 0,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: pageSurroundingPadding,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Brand: ",
//                           style: TextStyle(
//                               fontFamily: 'lato',
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400)),
//                       const SizedBox(height: 15),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.25,
//                         child: GridView.builder(
//                           physics: NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                   childAspectRatio: 2 / 0.5,
//                                   crossAxisCount: 2,
//                                   crossAxisSpacing: 20,
//                                   mainAxisSpacing: 15),
//                           itemCount: controller.brads.length,
//                           itemBuilder: ((context, index) {
//                             return Obx(() {
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.selectBrand.value = index;
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5)),
//                                   child: Center(
//                                       child: Text(
//                                           controller.brads[index]['brandname']
//                                               .toString(),
//                                           style: TextStyle(
//                                             fontFamily: 'lato',
//                                             fontSize: 14,
//                                           ))),
//                                 ),
//                               );
//                             });
//                           }),
//                         ),
//                       ),
//                       const Text("Size:",
//                           style: TextStyle(
//                               fontFamily: 'lato',
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400)),
//                       const SizedBox(height: 15),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.15,
//                         child: GridView.builder(
//                           physics: NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                   childAspectRatio: 2 / 0.7,
//                                   crossAxisCount: 3,
//                                   crossAxisSpacing: 20,
//                                   mainAxisSpacing: 15),
//                           itemCount: controller.size.length,
//                           itemBuilder: ((context, index) {
//                             return Obx(() {
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.selectSize.value = index;
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5)),
//                                   child: Center(
//                                       child: Text(
//                                           controller.size[index]['size']
//                                               .toString(),
//                                           style: TextStyle(
//                                             fontFamily: 'lato',
//                                             fontSize: 14,
//                                           ))),
//                                 ),
//                               );
//                             });
//                           }),
//                         ),
//                       ),
//                       const Text("Price:",
//                           style: TextStyle(
//                               fontFamily: 'lato',
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400)),
//                       Obx(() {
//                         return RangeSlider(
//                           values: controller.currentRangeValues.value,
//                           max: double.parse(
//                               controller.filterMaxPrice.toString()),
//                           divisions: 5,
//                           labels: RangeLabels(
//                             controller.currentRangeValues.value.start
//                                 .round()
//                                 .toString(),
//                             controller.currentRangeValues.value.end
//                                 .round()
//                                 .toString(),
//                           ),
//                           onChanged: (RangeValues values) {
//                             controller.updateSlider(values);
//                           },
//                         );
//                       }),
//                       const Text("Colors:",
//                           style: TextStyle(
//                               fontFamily: 'lato',
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400)),
//                       const SizedBox(height: 15),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.15,
//                         child: GridView.builder(
//                           physics: NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                   childAspectRatio: 1 / 1,
//                                   crossAxisCount: 7,
//                                   crossAxisSpacing: 10,
//                                   mainAxisSpacing: 15),
//                           itemCount: controller.colorList.length,
//                           itemBuilder: ((context, index) {
//                             return Obx(() {
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.selectedColor.value = index;
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       color: controller.colorList[index]
//                                           ['color'],
//                                       borderRadius: BorderRadius.circular(50)),
//                                   child: controller.selectedColor.value == index
//                                       ? Icon(Icons.check)
//                                       : SizedBox(),
//                                 ),
//                               );
//                             });
//                           }),
//                         ),
//                       ),
//                       SizedBox(height: 60)
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             filterButton(
//               reset: 'reset',
//               filter: 'apply filter',
//               pressEvnetFilter: () {
//                 print(controller.currentRangeValues.value.start);
//                 controller.allProductList.clear();
//                 controller.currentPage.value = 0;
//                 controller.maxPage.value = 0;
//                 controller.filterProducts();
//                 Get.back();
//               },
//               pressEvnetReset: () {
//                 controller.isFilter.value = false;
//                 Get.back();
//                 controller.onPullTorefresh();
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
