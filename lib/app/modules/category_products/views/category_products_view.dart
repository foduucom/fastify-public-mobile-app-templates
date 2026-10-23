import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/components/category_product_card.dart';
import 'package:zouhi/constants/theme_ext.dart';

import '../controllers/category_products_controller.dart';

class CategoryProductsView extends StatefulWidget {
  const CategoryProductsView({super.key});

  @override
  State<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<CategoryProductsView>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<CategoryProductsController>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (controller.tabs.length > 1) {
      _tabController =
          TabController(length: controller.tabs.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = controller.tabs;
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.title.value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColor),
            )),
        elevation: 0,
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: context.themePrimaryColor,
                unselectedLabelColor: context.themeTextColor,
                indicatorColor: context.themePrimaryColor,
                labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                tabs: [
                  for (final t in tabs) Tab(text: t.name.toUpperCase()),
                ],
              ),
      ),
      body: tabs.isEmpty
          ? const _Message(text: 'No category selected')
          : _tabController == null
              ? _TabGrid(categoryId: tabs.first.id)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    for (final t in tabs) _TabGrid(categoryId: t.id),
                  ],
                ),
    );
  }
}

class _TabGrid extends StatefulWidget {
  final String categoryId;
  const _TabGrid({required this.categoryId});

  @override
  State<_TabGrid> createState() => _TabGridState();
}

class _TabGridState extends State<_TabGrid>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.find<CategoryProductsController>();
  late final TabProducts state = controller.stateFor(widget.categoryId);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller.ensureLoaded(widget.categoryId);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.extentAfter < 600) {
      controller.loadMore(widget.categoryId);
    }
    return false;
  }

  int _columns(double width) => width >= 900 ? 4 : (width >= 600 ? 3 : 2);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final loading = state.isLoading.value;
      final items = state.items;

      if (loading && items.isEmpty) return const _GridShimmer();
      if (state.hasError.value && items.isEmpty) {
        return _Message(
          text: 'Could not load products.',
          actionLabel: 'Retry',
          onAction: () => controller.refreshTab(widget.categoryId),
        );
      }
      if (items.isEmpty) {
        return _Message(
          text: 'No products found in this category.',
          actionLabel: 'Refresh',
          onAction: () => controller.refreshTab(widget.categoryId),
        );
      }

      final width = MediaQuery.of(context).size.width;
      final columns = _columns(width);
      const gap = 12.0;
      final showFooter = state.isLoadingMore.value || state.hasNext.value;

      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(widget.categoryId),
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) =>
                      CategoryProductCard(product: items[i], index: i),
                ),
              ),
              if (showFooter)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _Message({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                  fontFamily: 'Poppins', color: context.themeSecondrytext)),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
