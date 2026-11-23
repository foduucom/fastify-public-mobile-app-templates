import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/constants/helper_functions.dart';
import '/components/app_image_placeholder.dart';
import '/services/order_product_image_resolver.dart';

class OrderProductImage extends StatelessWidget {
  const OrderProductImage({
    super.key,
    required this.orderLine,
    required this.width,
    required this.height,
    this.radius = 10,
    this.fit = BoxFit.contain,
  });

  final dynamic orderLine;
  final double width;
  final double height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final directImage = OrderProductImageResolver.immediate(orderLine);
    if (directImage != HelperFunctions.getNoImage()) {
      return _image(directImage);
    }

    return FutureBuilder<String>(
      future: OrderProductImageResolver.resolve(orderLine),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;
        if (imageUrl == null || imageUrl == HelperFunctions.getNoImage()) {
          return _placeholder();
        }
        return _image(imageUrl);
      },
    );
  }

  Widget _image(String imageUrl) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: width,
          height: height,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _placeholder(),
          ),
        ),
      );

  Widget _placeholder() => AppImagePlaceholder(
        radius: radius,
        width: width,
        height: height,
        fit: fit,
        backgroundColor: Colors.white,
      );
}
