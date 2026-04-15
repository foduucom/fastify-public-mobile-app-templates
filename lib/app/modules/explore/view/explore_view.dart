import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_back_button.dart';
import '../../../../components/app_bar2.dart';
import '../controller/explore_controller.dart';
import '/app/routes/app_pages.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({Key? key}) : super(key: key);
  @override
  ExploreController get controller {
    if (!Get.isRegistered<ExploreController>()) {
      Get.put(ExploreController());
    }
    return Get.find<ExploreController>();
  }
  // ── Fix 1: Explicit types on dummy lists ─────────────────────────────
  static final List<Map<String, dynamic>> _dummyNearbyStores = [
    {
      'name': 'Sweet & Savory Farmstand',
      'location': 'London, United Kingdom',
      'rating': '4.4',
      'date': 'October 08, 2024',
      'image': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=600',
    },
    {
      'name': 'Sunny Fruits Emporium',
      'location': 'London, United Kingdom',
      'rating': '4.2',
      'date': 'October 09, 2024',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600',
    },
    {
      'name': 'Sweet & Savory Farmstand',
      'location': 'London, United Kingdom',
      'rating': '4.4',
      'date': 'October 08, 2024',
      'image': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=600',
    },
  ];

  static final List<Map<String, dynamic>> _dummyOtherStores = [
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
    {
      'name': 'The Store Pantry',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '19 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
    },
    {
      'name': 'Fruestama Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '26 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'location': 'London, United Kingdom',
      'distance': '0.6 km',
      'time': '15 mins',
      'rating': '4.4',
      'promo': true,
      'image': 'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },

  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppBar2(
        title: 'Explore',
        showBackButton: false,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        return RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: controller.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 8),

                // ── Search Bar ────────────────────────────────────────
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.SEARCH),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: colorScheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.tune,
                              color: colorScheme.onSurfaceVariant, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Nearby Store ─────────────────────────────────────
                _SectionHeader(
                  title: 'Nearby Store',
                  onSeeAll: () {},
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),

                const SizedBox(height: 12),

                // ── Fix 2: Remove nested Obx for page dots ────────────
                Obx(() {
                  final List<Map<String, dynamic>> stores =
                  controller.nearbyStores.isEmpty
                      ? _dummyNearbyStores
                      : List<Map<String, dynamic>>.from(
                      controller.nearbyStores);

                  return Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          onPageChanged: (i) =>
                          controller.currentBannerIndex.value = i,
                          itemCount: stores.length,
                          itemBuilder: (context, index) =>
                              _NearbyStoreCard(
                                store: stores[index],
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ✅ No nested Obx — already inside outer Obx
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          stores.length,
                              (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: controller.currentBannerIndex.value == i
                                ? 28
                                : 8,
                            height: 8,
                            margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color:
                              controller.currentBannerIndex.value == i
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 28),

                // ── Other Store ──────────────────────────────────────
                _SectionHeader(
                  title: 'Catergoryies',
                  onSeeAll: () {
                    Get.toNamed(Routes.CATEGORY);
                  },
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  seeAllColor: colorScheme.primary,
                ),

                const SizedBox(height: 12),

                Obx(() {
                  final List<Map<String, dynamic>> stores =
                  controller.otherStores.isEmpty
                      ? _dummyOtherStores
                      : List<Map<String, dynamic>>.from(
                      controller.otherStores);

                  return Column(
                    children: List.generate(
                      stores.length,
                          (index) => _OtherStoreTile(
                        store: stores[index],
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                        onTap: () {},
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final Color? seeAllColor;

  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    required this.textTheme,
    required this.colorScheme,
    this.seeAllColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: textTheme.bodyMedium?.copyWith(
              color: seeAllColor ?? colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Nearby Store Banner Card ──────────────────────────────────────────────────
class _NearbyStoreCard extends StatelessWidget {
  final Map<String, dynamic> store; // ✅ typed
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _NearbyStoreCard({
    required this.store,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: store['image'] as String? ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: colorScheme.surfaceContainerHighest),
              ),
            ),

            // ── Fix 3: withOpacity → withValues ──────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65), // ✅ fixed
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55), // ✅ fixed
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      store['date'] as String? ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        store['location'] as String? ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.star,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        store['rating'] as String? ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store['name'] as String? ?? '',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Other Store List Tile ─────────────────────────────────────────────────────
class _OtherStoreTile extends StatelessWidget {
  final Map<String, dynamic> store; // ✅ typed
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _OtherStoreTile({
    required this.store,
    required this.textTheme,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: store['image'] as String? ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.store, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (store['promo'] == true)
                    Text(
                      'PROMO',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    store['name'] as String? ?? '',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(store['time'] as String? ?? '',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 10),
                      Text(store['distance'] as String? ?? '',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 10),
                      const Icon(Icons.star,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(store['rating'] as String? ?? '',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: colorScheme.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}
