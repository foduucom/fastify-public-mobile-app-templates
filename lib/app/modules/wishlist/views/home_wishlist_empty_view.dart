import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';

class HomeWishlistEmptyView extends StatelessWidget {
  final VoidCallback? onShoppingPressed;
  final String? title;
  final String? description;
  final IconData? icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const HomeWishlistEmptyView({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    this.onShoppingPressed,
    this.title,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isGuest = !AuthDetails.isUserLogin();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // ── Premium Illustrated Icon Badge ──
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer soft glow ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.06),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.12),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Middle gradient circle
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withOpacity(0.18),
                          colorScheme.primary.withOpacity(0.08),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon ?? Icons.favorite_rounded,
                        size: 52,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

                  // Decorative floating spark badge (top right)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

                  // Subtle micro-dot accent (bottom left)
                  Positioned(
                    bottom: 18,
                    left: 14,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Headline ──
          Text(
            title ?? "Your Wishlist is Empty",
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          // ── Subtitle / Explainer ──
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width * 0.78),
            child: Text(
              description ??
                  "Explore our collections and tap the heart icon on items you love to save them here for later.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Primary Action Button (Start Exploring) ──
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onShoppingPressed,
              icon: const Icon(Icons.explore_outlined, size: 19),
              label: const Text(
                "Start Exploring",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 3,
                shadowColor: colorScheme.primary.withOpacity(0.35),
              ),
            ),
          ),

          // ── Guest Sync Banner (Only shown if user is not logged in) ──
          if (isGuest) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Sign in to sync your wishlist across your devices",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.LOGIN),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(50, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
