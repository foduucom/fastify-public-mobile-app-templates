import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/shop/controllers/shop_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/theme_ext.dart';

class EmptyProductState extends StatelessWidget {
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;

  const EmptyProductState({
    super.key,
    required this.onClearFilters,
    this.hasActiveFilters = false,
  });

  // Top parent site categories for quick discovery
  static const List<Map<String, String>> _quickCategories = [
    {'name': 'Cable Assemblies', 'slug': 'cable-assemblies'},
    {'name': 'Fiber Patch Cables', 'slug': 'fiber-patch-cables'},
    {'name': 'Connectors & Adapters', 'slug': 'fibre-optic-connectors-and-adap'},
    {'name': 'MTP Solutions', 'slug': 'mtp-solution'},
    {'name': 'Cleaning & Tooling', 'slug': 'cleaning-tooling-and-consumabl'},
    {'name': 'Patch Leads', 'slug': 'patch-lead'},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Layered Icon Composition
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.themePrimaryLight,
                border: Border.all(
                  color: context.themePrimaryColor.withOpacity(0.12),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  hasActiveFilters
                      ? Icons.filter_alt_off_rounded
                      : Icons.inventory_2_outlined,
                  size: 46,
                  color: context.themePrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Headline
            Text(
              hasActiveFilters
                  ? 'No Matching Products'
                  : 'No Products Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: context.themetitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                hasActiveFilters
                    ? "We couldn't find items matching your selected criteria. Try adjusting or clearing your filters."
                    : "No products are currently available in this section. Browse our top categories below.",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: context.themeSecondrytext,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Primary CTA: Clear Filters / Reset
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onClearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themePrimaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  hasActiveFilters ? 'Clear Filters' : 'Reset & View All',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Category Shortcuts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: 40,
                      color: context.themeBorderColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Browse Popular Categories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 40,
                      color: context.themeBorderColor,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _quickCategories.map((cat) {
                    return ActionChip(
                      onPressed: () {
                        if (cat['slug'] == 'cable-assemblies') {
                          Get.toNamed(Routes.CABLE_ASSEMBLIES);
                          return;
                        }
                        if (cat['slug'] == 'mtp-solution') {
                          Get.toNamed(Routes.MTP_SOLUTION);
                          return;
                        }
                        if (Get.isRegistered<ShopController>()) {
                          final shopCtrl = Get.find<ShopController>();
                          shopCtrl.clearAllFilters();
                          shopCtrl.applyArguments({
                            'source': 'category',
                            'category': cat['slug'],
                            'name': cat['name'],
                          }, refresh: true);
                        }
                      },
                      label: Text(
                        cat['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: context.themePrimaryColor,
                        ),
                      ),
                      backgroundColor: context.themeWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: context.themePrimaryColor.withOpacity(0.25),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
