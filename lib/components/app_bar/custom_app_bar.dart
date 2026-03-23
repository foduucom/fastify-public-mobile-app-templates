import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../app/modules/cart/view/cart_view.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showCart;
  final VoidCallback? onBackTap;
  final VoidCallback? onCartTap;
  final Widget? rightWidget;

  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.showCart = true,
    this.onBackTap,
    this.onCartTap,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [

          // ── Back Button ──────────────────────────────
          if (showBack)
            _CircleButton(
              iconPath: 'assets/icons/back.png', // change to your asset
              fallbackIcon: Icons.arrow_back,
              onTap: onBackTap ?? () => Get.back(),
            )
          else
            const SizedBox(width: 48),

          // ── Title ────────────────────────────────────
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          // ── Right (Cart or Custom) ──────────────────
          if (rightWidget != null)
            rightWidget!
          else if (showCart)
            _CircleButton(
              iconPath: 'assets/icons/ic_cart.png', // change to your asset
              fallbackIcon: Icons.shopping_bag_outlined,
              onTap: onCartTap ?? () {
                Navigator.push(
                  Get.context!, // since you're inside GetX widget
                  MaterialPageRoute(
                    builder: (context) => CartView(),
                  ),
                );
              },
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Circle Button (supports PNG + SVG + fallback Icon)
// ─────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final String? iconPath;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _CircleButton({
    this.iconPath,
    required this.fallbackIcon,
    required this.onTap,
  });

  bool _isSvg(String path) => path.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconPath != null && iconPath!.isNotEmpty) {

      // SVG support
      if (_isSvg(iconPath!)) {
        return SvgPicture.asset(
          iconPath!,
          width: 22,
          height: 22,
          color: const Color(0xFF1A1A1A),
        );
      }

      // PNG/JPG support
      return Image.asset(
        iconPath!,
        width: 22,
        height: 22,
        color: const Color(0xFF1A1A1A),
        errorBuilder: (_, __, ___) {
          return Icon(
            fallbackIcon,
            size: 22,
            color: const Color(0xFF1A1A1A),
          );
        },
      );
    }

    // fallback if no asset
    return Icon(
      fallbackIcon,
      size: 22,
      color: const Color(0xFF1A1A1A),
    );
  }
}