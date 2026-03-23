import 'package:flutter/material.dart';
import 'app_shimmer.dart';

// ─────────────────────────────────────────────────────────────────
// PRODUCT CARD  (Featured horizontal card — 220×320)
// ─────────────────────────────────────────────────────────────────
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 230,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E6E3),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.full(height: 12, radius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 80, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// COLLECTION CARD  (Small 160×220)
// ─────────────────────────────────────────────────────────────────
class CollectionCardShimmer extends StatelessWidget {
  const CollectionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E6E3),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.full(height: 10, radius: 6),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 60, height: 10, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CATEGORY CIRCLE  (62×62)
// ─────────────────────────────────────────────────────────────────
class CategoryCircleShimmer extends StatelessWidget {
  const CategoryCircleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(child: ShimmerCircle(size: 62));
  }
}

// ─────────────────────────────────────────────────────────────────
// CART ITEM CARD
// ─────────────────────────────────────────────────────────────────
class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ShimmerBox(width: 90, height: 90, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.full(height: 12, radius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 100, height: 12, radius: 6),
                  const SizedBox(height: 14),
                  ShimmerBox(width: 140, height: 36, radius: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WISHLIST CARD
// ─────────────────────────────────────────────────────────────────
class WishlistCardShimmer extends StatelessWidget {
  const WishlistCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 90, height: 100, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.full(height: 12, radius: 6),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 120, height: 10, radius: 6),
                  const SizedBox(height: 12),
                  ShimmerBox(width: 80, height: 14, radius: 6),
                  const SizedBox(height: 14),
                  ShimmerBox.full(height: 36, radius: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ORDER HISTORY CARD
// ─────────────────────────────────────────────────────────────────
class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ShimmerBox(width: 72, height: 72, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.full(height: 12, radius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 100, height: 10, radius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 10, radius: 6),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ShimmerBox(width: 60, height: 26, radius: 50),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ORDER DETAIL — Product row
// ─────────────────────────────────────────────────────────────────
class OrderDetailRowShimmer extends StatelessWidget {
  const OrderDetailRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ShimmerBox(width: 58, height: 58, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.full(height: 11, radius: 6),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 80, height: 10, radius: 6),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ShimmerBox(width: 50, height: 14, radius: 6),
          ],
        ),
      ),
    );
  }
}
// ── Terms & Conditions Shimmer ─────────────────────────────────
class _TermsShimmer extends StatelessWidget {
  const _TermsShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Block 1 — heading + 2 paragraphs
          ShimmerBox(width: 180, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 260, height: 11, radius: 6),
          const SizedBox(height: 20),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 200, height: 11, radius: 6),

          // Block 2 — heading + 2 paragraphs
          const SizedBox(height: 28),
          ShimmerBox(width: 220, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 240, height: 11, radius: 6),
          const SizedBox(height: 20),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 180, height: 11, radius: 6),

          // Block 3 — heading + 2 paragraphs
          const SizedBox(height: 28),
          ShimmerBox(width: 160, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 210, height: 11, radius: 6),
          const SizedBox(height: 20),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 150, height: 11, radius: 6),

          // Block 4 — heading + 1 paragraph
          const SizedBox(height: 28),
          ShimmerBox(width: 200, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 190, height: 11, radius: 6),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────
// PRODUCT DETAIL PAGE
// ─────────────────────────────────────────────────────────────────
class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ShimmerBox.full(height: 320, radius: 24),
            const SizedBox(height: 20),
            ShimmerBox.full(height: 16, radius: 8),
            const SizedBox(height: 10),
            ShimmerBox(width: 180, height: 14, radius: 8),
            const SizedBox(height: 16),
            ShimmerBox(width: 100, height: 20, radius: 8),
            const SizedBox(height: 24),
            // Variant chips
            Row(children: [
              ShimmerBox(width: 60, height: 32, radius: 50),
              const SizedBox(width: 10),
              ShimmerBox(width: 60, height: 32, radius: 50),
              const SizedBox(width: 10),
              ShimmerBox(width: 60, height: 32, radius: 50),
            ]),
            const SizedBox(height: 24),
            ShimmerBox.full(height: 12, radius: 6),
            const SizedBox(height: 8),
            ShimmerBox.full(height: 12, radius: 6),
            const SizedBox(height: 8),
            ShimmerBox(width: 200, height: 12, radius: 6),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PROFILE PAGE
// ─────────────────────────────────────────────────────────────────
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(child: ShimmerCircle(size: 90)),
            const SizedBox(height: 14),
            Center(child: ShimmerBox(width: 140, height: 14, radius: 8)),
            const SizedBox(height: 6),
            Center(child: ShimmerBox(width: 180, height: 11, radius: 6)),
            const SizedBox(height: 32),
            ...List.generate(5, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ShimmerBox.full(height: 56, radius: 16),
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GENERIC LIST  — for any screen, pass count + builder
// ─────────────────────────────────────────────────────────────────
class ShimmerList extends StatelessWidget {
  final int count;
  final Widget Function(int index) itemBuilder;
  final EdgeInsets padding;
  final double spacing;

  const ShimmerList({
    super.key,
    this.count      = 4,
    required this.itemBuilder,
    this.padding    = const EdgeInsets.symmetric(horizontal: 20),
    this.spacing    = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      shrinkWrap: true,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, i) => itemBuilder(i),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GENERIC HORIZONTAL LIST
// ─────────────────────────────────────────────────────────────────
class ShimmerHorizontalList extends StatelessWidget {
  final int count;
  final Widget child;
  final double height;

  const ShimmerHorizontalList({
    super.key,
    this.count = 4,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => child,
      ),
    );
  }
}
