// class FilterPage extends StatelessWidget {
//   final controller = Get.find<ShopController>();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: context.surfaceColor, // Theme-aware
//           title: Text(
//             "Filters",
//             style: txtTheme().titleLarge!.copyWith(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: context.onSurfaceColor, // Theme-aware
//                 ),
//           ),
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
//                       Text(
//                         "Brand: ",
//                         style: TextStyle(
//                           fontFamily: 'lato',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           color: context.onSurfaceColor, // Theme-aware
//                         ),
//                       ),
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
//                               final isSelected =
//                                   controller.selectBrand.value == index;
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.selectBrand.value = index;
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(5),
//                                     color: isSelected
//                                         ? context.primaryColor.withOpacity(0.1)
//                                         : context.surfaceVariantColor,
//                                     border: Border.all(
//                                       color: isSelected
//                                           ? context.primaryColor
//                                           : context.outlineColor,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       controller.brads[index]['brandname']
//                                           .toString(),
//                                       style: TextStyle(
//                                         fontFamily: 'lato',
//                                         fontSize: 14,
//                                         color: isSelected
//                                             ? context.primaryColor
//                                             : context.onSurfaceColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             });
//                           }),
//                         ),
//                       ),
//                       Text(
//                         "Size:",
//                         style: TextStyle(
//                           fontFamily: 'lato',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           color: context.onSurfaceColor, // Theme-aware
//                         ),
//                       ),
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
//                               final isSelected =
//                                   controller.selectSize.value == index;
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.selectSize.value = index;
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(5),
//                                     color: isSelected
//                                         ? context.primaryColor.withOpacity(0.1)
//                                         : context.surfaceVariantColor,
//                                     border: Border.all(
//                                       color: isSelected
//                                           ? context.primaryColor
//                                           : context.outlineColor,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       controller.size[index]['size'].toString(),
//                                       style: TextStyle(
//                                         fontFamily: 'lato',
//                                         fontSize: 14,
//                                         color: isSelected
//                                             ? context.primaryColor
//                                             : context.onSurfaceColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             });
//                           }),
//                         ),
//                       ),
//                       Text(
//                         "Price:",
//                         style: TextStyle(
//                           fontFamily: 'lato',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           color: context.onSurfaceColor, // Theme-aware
//                         ),
//                       ),
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
//                           activeColor: context.primaryColor, // Theme-aware
//                           inactiveColor: context.outlineColor, // Theme-aware
//                         );
//                       }),
//                       Text(
//                         "Colors:",
//                         style: TextStyle(
//                           fontFamily: 'lato',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           color: context.onSurfaceColor, // Theme-aware
//                         ),
//                       ),
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
//                               final isSelected =
//                                   controller.selectedColor.value == index;
//                               return GestureDetector(
//                                 onTap: () {
//                                   controller.selectedColor.value = index;
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: controller.colorList[index]['color'],
//                                     borderRadius: BorderRadius.circular(50),
//                                     border: Border.all(
//                                       color: isSelected
//                                           ? context.primaryColor
//                                           : Colors.transparent,
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: isSelected
//                                       ? Icon(
//                                           Icons.check,
//                                           color: context.onPrimaryColor,
//                                           size: 16,
//                                         )
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
