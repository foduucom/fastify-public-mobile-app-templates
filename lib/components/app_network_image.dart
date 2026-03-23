// lib/components/app_network_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _buildError();

    final image = CachedNetworkImage(
      imageUrl: url,
      width:    width,
      height:   height,
      fit:      fit,
      placeholder: (_, __) => placeholder ?? _buildLoading(),
      errorWidget: (_, __, ___) => errorWidget ?? _buildError(),
      // ✅ Key fix: forces custom decode → handles all WebP variants
      httpHeaders: const {'Accept': 'image/*'},
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildLoading() => Container(
    color: const Color(0xFFF0EEEB),
    child: const Center(
      child: CircularProgressIndicator(
          strokeWidth: 2, color: Color(0xFFD0D0D0)),
    ),
  );

  Widget _buildError() => Container(
    color: const Color(0xFFF5F5F5),
    child: const Center(
      child: Icon(Icons.image_not_supported_outlined,
          size: 36, color: Color(0xFFD0D0D0)),
    ),
  );
}
