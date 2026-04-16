import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_fastify_template/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../components/app_bar2.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/routes/app_pages.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ──────────────────────────────────────────────────────
      appBar: CustomAppBar2(title: 'Category'),

       body: FoduuStudioLayoutView(
        onRefresh: () async {
          await controller.onPullTorefresh();
        },
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
      ),

      // body: RefreshIndicator(
      //   onRefresh: controller.onRefresh,
      //   color: colorScheme.primary,
      //   child: SingleChildScrollView(
      //     physics: const AlwaysScrollableScrollPhysics(),
      //     padding: const EdgeInsets.symmetric(
      //       horizontal: 16,
      //     ),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         // ── Banner ─────────────────────────────────────────────
      //         _BannerCard(),

      //         const SizedBox(height: 18),

      //         // ── Categories ──────────────────────────────────────────
      //         Text(
      //           'Categories',
      //           style: textTheme.titleMedium?.copyWith(
      //             fontWeight: FontWeight.w600,
      //             color: colorScheme.onSurface,
      //             fontSize: 16,
      //           ),
      //         ),
      //         const SizedBox(height: 10),
      //         _CategoriesGrid(
      //           categories: controller.categories,
      //           colorScheme: colorScheme,
      //           textTheme: textTheme,
      //         ),

      //         const SizedBox(height: 18),

      //         // ── Best Selling ────────────────────────────────────────
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text(
      //               'Best Selling',
      //               style: textTheme.titleMedium?.copyWith(
      //                 fontWeight: FontWeight.bold,
      //                 color: colorScheme.onSurface,
      //                 fontSize: 18,
      //               ),
      //             ),
      //             GestureDetector(
      //               onTap: () => Get.toNamed(Routes.EXPLORE),
      //               child: Text(
      //                 'See All',
      //                 style: textTheme.bodyMedium?.copyWith(
      //                   color: colorScheme.primary,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 16),

      //         // ── Products ────────────────────────────────────────────
      //         Obx(() {
      //           if (controller.isLoading.value && controller.products.isEmpty) {
      //             return _buildShimmerGrid(context);
      //           }
      //           if (controller.products.isEmpty) {
      //             return Center(
      //               child: Padding(
      //                 padding: const EdgeInsets.symmetric(vertical: 40),
      //                 child: Text('No products found',
      //                     style: textTheme.bodyLarge
      //                         ?.copyWith(color: colorScheme.onSurfaceVariant)),
      //               ),
      //             );
      //           }
      //           return GridView.builder(
      //             shrinkWrap: true,
      //             physics: const NeverScrollableScrollPhysics(),
      //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //               crossAxisCount: 2,
      //               crossAxisSpacing: 14,
      //               mainAxisSpacing: 14,
      //               childAspectRatio: 0.68,
      //             ),
      //             itemCount: controller.products.length,
      //             itemBuilder: (context, index) {
      //               final product =
      //                   controller.products[index] as Map<String, dynamic>;
      //               return _ProductCard(
      //                 product: product,
      //                 controller: controller,
      //                 colorScheme: colorScheme,
      //                 textTheme: textTheme,
      //               );
      //             },
      //           );
      //         }),

      //         const SizedBox(height: 24),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  // ── Shimmer skeleton ────────────────────────────────────────────────
//   Widget _buildShimmerGrid(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final colorScheme = Theme.of(context).colorScheme;
//     return Shimmer.fromColors(
//       baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//       highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 14,
//           mainAxisSpacing: 14,
//           childAspectRatio: 0.68,
//         ),
//         itemCount: 4,
//         itemBuilder: (_, __) => Container(
//           decoration: BoxDecoration(
//             color: colorScheme.surface,
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BannerCard extends StatelessWidget {
//   const _BannerCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         height: 141,
//         width: 347,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           image: const DecorationImage(
//             image: AssetImage('assets/images/banner_fruits_bg.png'),
//             fit: BoxFit.cover, // 👈 ensures proper fill
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Categories Grid ───────────────────────────────────────────────────────────
// class _CategoriesGrid extends StatelessWidget {
//   final List<Map<String, String>> categories;
//   final ColorScheme colorScheme;
//   final TextTheme textTheme;

//   const _CategoriesGrid({
//     required this.categories,
//     required this.colorScheme,
//     required this.textTheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 16,
//         childAspectRatio: 0.8,
//       ),
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         final cat = categories[index];
//         return GestureDetector(
//           onTap: () {
//             // TODO: navigate to category products
//           },
//           child: Column(
//             children: [
//               // ── Circle icon ──────────────────────────────────────
//               Container(
//                 width: 68,
//                 height: 68,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   // border: Border.all(
//                   //     color: Colors.grey.shade200, width: 1.5),
//                   color: colorScheme.surface,
//                 ),
//                 padding: const EdgeInsets.all(14),
//                 child: Image.asset(
//                   cat['asset']!,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               // ── Name ────────────────────────────────────────────
//               Text(
//                 cat['name']!,
//                 style: textTheme.bodySmall?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Product Card ──────────────────────────────────────────────────────────────
// class _ProductCard extends StatelessWidget {
//   final Map<String, dynamic> product;
//   final CategoryController controller;
//   final ColorScheme colorScheme;
//   final TextTheme textTheme;

//   const _ProductCard({
//     required this.product,
//     required this.controller,
//     required this.colorScheme,
//     required this.textTheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = controller.getImageUrl(product);
//     final name = product['name']?.toString() ?? '';
//     final price = controller.getPrice(product);
//     final salePrice = controller.getSalePrice(product);
//     final hasDiscount = salePrice > 0 && salePrice < price;
//     final displayPrice = hasDiscount ? salePrice : price;
//     final discountPct =
//         hasDiscount ? ((price - salePrice) / price * 100).round() : 0;

//     return GestureDetector(
//       onTap: () {
//         final productId = product['_id']?.toString() ?? '';
//         if (productId.isNotEmpty) {
//           Get.to(
//             () => ProductView(),
//             binding: ShopBinding(),
//             arguments: {'productId': productId},
//           );
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: colorScheme.outline),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Image ───────────────────────────────────────────────
//             Expanded(
//               flex: 5,
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(15)),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: imageUrl.isNotEmpty
//                           ? CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               fit: BoxFit.cover,
//                               placeholder: (_, __) =>
//                                   Container(color: colorScheme.surfaceContainerHighest),
//                               errorWidget: (_, __, ___) => Container(
//                                 color: colorScheme.surfaceContainerHighest,
//                                 child: Icon(Icons.image_not_supported_outlined,
//                                     color: colorScheme.onSurfaceVariant),
//                               ),
//                             )
//                           : Container(
//                               color: colorScheme.surfaceContainerHighest,
//                               child: Icon(Icons.image_not_supported_outlined,
//                                   color: colorScheme.onSurfaceVariant),
//                             ),
//                     ),
//                   ),

//                   // ── Discount badge ─────────────────────────────
//                   if (hasDiscount)
//                     Positioned(
//                       top: 8,
//                       left: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: colorScheme.error,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '$discountPct%',
//                           style: TextStyle(
//                               color: colorScheme.onError,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // ── Details ─────────────────────────────────────────────
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       name,
//                       style: textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface,
//                         fontSize: 13,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       'For 1Kg',
//                       style: textTheme.bodySmall
//                           ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '\$${displayPrice.toStringAsFixed(2)}',
//                               style: textTheme.titleSmall?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: colorScheme.onSurface,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             if (hasDiscount)
//                               Text(
//                                 '\$${price.toStringAsFixed(2)}',
//                                 style: textTheme.bodySmall?.copyWith(
//                                   decoration: TextDecoration.lineThrough,
//                                   color: colorScheme.error,
//                                   decorationColor: colorScheme.error,
//                                   fontSize: 11,
//                                 ),
//                               ),
//                           ],
//                         ),
//                         // ── + Button ──────────────────────────────
//                         Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: colorScheme.primary.withValues(alpha: 0.12),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(Icons.add,
//                               color: colorScheme.primary, size: 18),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}
