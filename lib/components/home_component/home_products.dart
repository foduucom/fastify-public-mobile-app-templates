import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/commonWidgets/product_card.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TrendingProductSection extends StatefulWidget {
  final Map<String, dynamic>? contentJson;

  const TrendingProductSection({
    super.key,
    this.contentJson,
  });

  @override
  State<TrendingProductSection> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductSection>
    with BaseController {
  List trendingList = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    if (widget.contentJson != null && widget.contentJson!['products'] != null) {
      trendingList = List.from(widget.contentJson!['products']);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = widget.contentJson?['heading'] ?? 'Trending';
    final subheading = widget.contentJson?['subheading'] ?? '';
    final categoryType =
        widget.contentJson?['category_type'] ?? 'random_category';
    final categoryIds = widget.contentJson?['categories'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: pageSurroundingPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(heading, style: textTheme.titleLarge),
                  subheading.isEmpty
                      ? Container()
                      : Text(subheading,
                          style: textTheme.titleSmall!
                              .copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                    'productId': categoryIds,
                    'name': heading,
                    'productype': categoryType,
                    'source': 'dashboard'
                  });
                },
                child: Text(
                  'See all',
                  style: textTheme.labelLarge!
                      .copyWith(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: SizedBox(
            height: 300,
            child: trendingList.isEmpty
                ? const TrendingProductsShimmer()
                : ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 5),
                    shrinkWrap: false,
                    cacheExtent: 9999,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingList.length,
                    itemBuilder: (context, index) {
                      final product = trendingList[index];
                      final priceInfo =
                          ProductHelper.calculatePriceInfo(product);

                      // Skip products with no valid variants if it's a variable product
                      if (!priceInfo['hasValidVariants']) {
                        return Container();
                      }

                      return ProductCard(
                        product: product,
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class TrendingProductsShimmer extends StatelessWidget {
  const TrendingProductsShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: colorScheme.surfaceVariant,
        highlightColor: colorScheme.onSurfaceVariant.withOpacity(0.3),
        child: ListView.separated(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                  ),
                  height: 180,
                  width: 160,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 150,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 100,
                ),
              ],
            );
          },
        ));
  }
}
