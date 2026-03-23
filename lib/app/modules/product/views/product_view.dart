import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '/components/ProductGallery.dart';
import '/app/modules/product/controllers/product_controller.dart';
import '/core/services/wishlistService.dart';
import '/app/routes/app_pages.dart';
import '../../../../components/shimmer/shimmer_effects.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import '/constants/theme.dart';
import 'package:get/get.dart';

class ProductView extends GetView<ProductController> {
  ProductView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.create(() => ProductController(), permanent: false);
    final controller = Get.find<ProductController>();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (controller.productDetials['name'] == null) {
            return const ShimmerEffect(height: 10, width: 100);
          } else {
            return Text(
              controller.productDetials['name'].toString(),
              style: Theme.of(context).textTheme.titleLarge,
            );
          }
        }),
        actions: const [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     IconButton(
          //         onPressed: () {},
          //         icon: SvgPicture.asset('assets/icon/appbarshare.svg')),
          //     Obx(
          //       () => Get.find<BottombarController>().cartbadge(
          //           child: CartIcon(() {
          //             Get.toNamed(Routes.CART);
          //           }),
          //           badgeNumber: 0),
          //     ),
          //     const SizedBox(
          //       width: 14,
          //     )
          //   ],
          // )
        ],
        titleSpacing: 0.0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              final galleryImages = ProductHelper.getProductGallery(
                Map<String, dynamic>.from(controller.productDetials),
                variantIndex: controller.selectedVariantIndex.value,
              );

              return ProductGallery(
                isLoading: controller.isLoading.value,
                controller: controller,
                productGallery: galleryImages,
              );
            }),
            const SizedBox(height: 8.0),
            Column(
              children: [
                Padding(
                  padding: pageSurroundingPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Obx(() => controller.productDetials['name'] == null
                          ? const ShimmerEffect(height: 10, width: 100)
                          : Text(
                              controller.productDetials['name'].toString(),
                              style: Theme.of(context).textTheme.titleLarge,
                            )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Obx(() {
                          return controller.productDetials['content'] != null
                              ? HtmlWidget(controller.productDetials['content']
                                  .toString())
                              : Container();
                        }),
                      ),
                      Obx(
                        () => Row(
                          children: [
                            RatingBarIndicator(
                              rating:
                                  controller.productDetials['average_rating'] ==
                                          null
                                      ? 0.0
                                      : double.parse(controller
                                          .productDetials['average_rating']
                                          .toString()),
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              unratedColor:
                                  Theme.of(context).colorScheme.outline,
                              itemCount: 5,
                              itemSize: 18.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              controller.productDetials['rating_count'] == null
                                  ? '0'
                                  : controller.productDetials['rating_count']
                                      .toString(),
                              style: txtTheme().titleLarge!.copyWith(),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (controller.productDetials['name'] == null) {
                          return const ShimmerEffect(height: 10, width: 50);
                        } else {
                          final priceInfo = ProductHelper.calculatePriceInfo(
                            Map<String, dynamic>.from(
                                controller.productDetials),
                            variantIndex: controller.selectedVariantIndex.value,
                          );

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${priceInfo['productPrice']}",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 04),
                              priceInfo['salePrice'] == "0" ||
                                      priceInfo['salePrice'] == ""
                                  ? Container()
                                  : Text(
                                      "₹${priceInfo['salePrice']}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                    ),
                              Text(
                                priceInfo['discountRate'] ?? '',
                                style: txtTheme().titleLarge!.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              )
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).dividerTheme.color,
                ),
                Padding(
                  padding: pageSurroundingPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () {
                          return Column(
                            children: [
                              ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, parentIndex) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Select ${controller.labels[parentIndex]}',
                                            style: txtTheme()
                                                .titleLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: SizedBox(
                                            height: 40,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller
                                                  .labelVariant[parentIndex]
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    controller.onSelectVariant(
                                                        controller.labels[
                                                            parentIndex],
                                                        controller.labelVariant[
                                                                parentIndex]
                                                            [index]);
                                                  },
                                                  child: Obx(
                                                    () {
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: controller.selectedVariant[controller.labels[parentIndex]] ==
                                                                      controller
                                                                              .labelVariant[parentIndex]
                                                                          [
                                                                          index]
                                                                  ? 2.5
                                                                  : 1.5,
                                                              color: controller.selectedVariant[controller.labels[parentIndex]] ==
                                                                      controller
                                                                              .labelVariant[parentIndex]
                                                                          [
                                                                          index]
                                                                  ? Theme.of(context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(context)
                                                                      .colorScheme
                                                                      .outline),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(08),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            controller.labelVariant[
                                                                    parentIndex]
                                                                [index],
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .labelLarge,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      height: 10,
                                    );
                                  },
                                  itemCount: controller.labels.length)
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text("Quantity:",
                          style: txtTheme()
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Container(
                        width: Get.width * 0.32,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  controller.decrement();
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(0.01),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(02),
                                      border: Border.all(
                                          width: 1.2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline)),
                                  child: const Icon(Icons.remove, size: 14),
                                )),
                            Obx(() {
                              return Text(controller.count.toString());
                            }),
                            IconButton(
                                onPressed: () {
                                  controller.increment();
                                },
                                icon: Container(
                                    padding: const EdgeInsets.all(0.01),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(02),
                                        border: Border.all(
                                            width: 1.2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline)),
                                    child: const Icon(Icons.add, size: 14))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Obx(() {
                          return Html(
                            data:
                                controller.productDetials['long_content'] ?? "",
                            style: {
                              "body": Style(
                                fontFamily: "Lato",
                              ),
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 50)
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: OrderButton(
        btntext: 'Add to Bag',
        controller: controller,
        wishListTap: () async {
          final productDetails = controller.productDetials;
          String variantSlug = '';
          String? variantId;
          if (productDetails['variants'] != null &&
              (productDetails['variants'] as List).isNotEmpty) {
            final variants = productDetails['variants'] as List;
            final selectedIndex = controller.selectedVariantIndex.value;
            if (selectedIndex < variants.length) {
              variantSlug = variants[selectedIndex]['slug'] ?? '';
              variantId = (variants[selectedIndex]['_id'] ??
                      variants[selectedIndex]['id'])
                  ?.toString();
            }
          } else {
            variantSlug = productDetails['variant_slug'] ?? '';
            variantId =
                (productDetails['_id'] ?? productDetails['id'])?.toString();
          }

          await WishListService.to.toggleWishlist(
            productId: controller.productId,
            variantSlug: variantSlug,
            variantId: variantId,
          );
        },
        addToCartTap: () async {
          HelperFunctions().showOverlayLoader();

          await controller.addToCart().then((value) {
            Get.until((route) => !Get.isDialogOpen!);
            return Get.toNamed(Routes.CART);
          });
        },
      ),
    ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.wishListTap,
    required this.addToCartTap,
    required this.controller,
    required this.btntext,
  }) : super(key: key);

  final VoidCallback wishListTap;
  final String btntext;
  final Function() addToCartTap;
  final ProductController controller;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.2,
          ),
        ),
      ),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.wishListTap();
                _controller
                    .forward(
                      from: 0.0,
                    )
                    .then((value) => _controller.reverse());
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Obx(() {
                          final isInWishlist = WishListService.to
                              .isInWishlist(widget.controller.productId);
                          return SvgPicture.asset(
                            isInWishlist
                                ? 'assets/icon/like.svg'
                                : 'assets/icon/unlike.svg',
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Text("WISHLIST",
                          style: Theme.of(context).textTheme.bodyMedium)
                    ],
                  );
                },
              ),
            ),
          ),
          const VerticalDivider(
            width: 20,
            thickness: 1.5,
            indent: 10,
            endIndent: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: widget.addToCartTap,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icon/addtobag.svg',
                    width: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.btntext,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
