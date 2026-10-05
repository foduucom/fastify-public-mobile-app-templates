import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final String? fallbackAsset;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 36,
    this.borderColor,
    this.borderWidth = 0,
    this.boxShadow,
    this.fallbackAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;
    final colorScheme = Theme.of(context).colorScheme;

    Widget avatarContent;

    final hasNetworkImage = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        imageUrl!.startsWith('http');

    if (hasNetworkImage) {
      avatarContent = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: diameter,
          height: diameter,
          color: colorScheme.surfaceVariant,
          child: Center(
            child: SizedBox(
              width: radius * 0.6,
              height: radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(context, diameter),
      );
    } else {
      avatarContent = _buildFallback(context, diameter);
    }

    Widget avatarWidget = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? colorScheme.outlineVariant,
                width: borderWidth,
              )
            : null,
        boxShadow: boxShadow,
      ),
      child: ClipOval(child: avatarContent),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildFallback(BuildContext context, double diameter) {
    if (fallbackAsset != null && fallbackAsset!.trim().isNotEmpty) {
      return Container(
        width: diameter,
        height: diameter,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Image.asset(
          fallbackAsset!.trim(),
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholder(context, diameter),
        ),
      );
    }
    return _buildPlaceholder(context, diameter);
  }

  Widget _buildPlaceholder(BuildContext context, double diameter) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmedName = name?.trim() ?? '';

    if (trimmedName.isNotEmpty) {
      final parts = trimmedName.split(RegExp(r'\s+'));
      String initials = '';
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }

      if (initials.isNotEmpty) {
        return Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            initials,
            style: TextStyle(
              fontSize: radius * (initials.length > 1 ? 0.72 : 0.85),
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        );
      }
    }

    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.person_rounded,
        size: radius * 1.15,
        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
      ),
    );
  }
}
