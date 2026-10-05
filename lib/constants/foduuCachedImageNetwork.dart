import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class FoduuCachedNetworkImage extends StatelessWidget {
  const FoduuCachedNetworkImage({
    Key? key,
    required this.image,
    this.height = 100,
    this.width = 100,
    this.radius = 20,
    this.onTap,
    this.fit = BoxFit.fill,
    this.colorFilter,
  }) : super(key: key);

  final String? image;
  final double height;
  final double width;
  final double radius;
  final VoidCallback? onTap;
  final BoxFit fit;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    if (image != null && image != "" && image!.contains(".svg")) {
      return GestureDetector(
        onTap: onTap,
        child: SvgPicture.network(
          image!,
          height: height,
          width: width,
          fit: fit,
          colorFilter: colorFilter,
        ),
      );
    } else if (image == null || image == "" || !image!.contains("http")) {
      final assetWidget = Image.asset(
        "assets/images/noImage.png",
        height: height,
        width: width,
        fit: fit,
      );
      return GestureDetector(
        onTap: onTap,
        child: colorFilter != null
            ? ColorFiltered(colorFilter: colorFilter!, child: assetWidget)
            : assetWidget,
      );
    } else {
      Widget netImage = CachedNetworkImage(
        alignment: Alignment.center,
        imageUrl: image!,
        fit: fit,
        height: height,
        width: width,
        progressIndicatorBuilder: (context, url, downloadProgress) => Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(radius)),
            child: Center(
                child: SizedBox(
                    height: height,
                    width: width,
                    child: HelperFunctions().loadingIndicator()))),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Colors.grey.shade300),
          child: const Center(
            child: Icon(Icons.error),
          ),
        ),
      );

      if (colorFilter != null) {
        netImage = ColorFiltered(colorFilter: colorFilter!, child: netImage);
      }

      return GestureDetector(
        onTap: onTap,
        child: netImage,
      );
    }
  }
}
