import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class CategoryDialog extends StatelessWidget {
  final Map<String, dynamic> category;
  final dynamic controller;

  const CategoryDialog({
    Key? key,
    required this.category,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;
    final children = category['children'] as List;

    return GetBuilder<CategoryDialogController>(
      init: CategoryDialogController(categories: children),
      builder: (dialogController) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height * 0.015),
          ),
          child: Container(
            width: width * 0.92,
            constraints: BoxConstraints(
              maxHeight: dialogController.isExpandedView.value
                  ? height * 0.9 // Larger height for expanded view
                  : height * 0.7, // Normal height for dialog view
            ),
            padding: EdgeInsets.all(width * 0.053),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                _buildHeader(context, height, dialogController),

                SizedBox(height: height * 0.02),

                // Category image
                _buildCategoryImage(context, height),

                SizedBox(height: height * 0.02),

                // Subcategories with expansion panels
                _buildContentSection(
                    context, height, children, dialogController),

                // View All / Show Less button (only if there are many categories)
                if (children.length > 3)
                  _buildViewAllToggle(context, height, dialogController),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header widget with expand/collapse toggle
  Widget _buildHeader(BuildContext context, double height,
      CategoryDialogController dialogController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            category['name'].toString(),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.02,
              fontWeight: FontWeight.w600,
              height: 1.75,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expand/Collapse toggle button
            if (!dialogController.isExpandedView.value)
              IconButton(
                onPressed: () => dialogController.toggleExpandedView(),
                icon: Icon(
                  Icons.fullscreen,
                  size: height * 0.024,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Expand view',
              ),
            SizedBox(width: 10),
            // Close button
            GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.close,
                size: height * 0.027,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Content section that adapts based on expanded view
  Widget _buildContentSection(BuildContext context, double height,
      List children, CategoryDialogController dialogController) {
    if (dialogController.isExpandedView.value) {
      // Expanded view - shows all categories without scrolling limitation
      return Expanded(
        child: _buildExpandedCategoryList(
            context, height, children, dialogController),
      );
    } else {
      // Dialog view - shows limited categories with scrolling
      return _buildLimitedCategoryList(
          context, height, children, dialogController);
    }
  }

  // Limited view for dialog (shows first few categories)
  Widget _buildLimitedCategoryList(BuildContext context, double height,
      List children, CategoryDialogController dialogController) {
    final displayedChildren = children.take(3).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subcategories',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: height * 0.018,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: height * 0.01),

        // Show first 3 categories with expansion panels
        Container(
          constraints: BoxConstraints(
            maxHeight: height * 0.3,
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: displayedChildren.length,
            itemBuilder: ((context, index) {
              return _buildCategoryExpansionPanel(
                context,
                height,
                displayedChildren[index],
                index,
                dialogController,
              );
            }),
          ),
        ),

        // Show indicator for more categories
        if (children.length > 3)
          Padding(
            padding: EdgeInsets.only(top: height * 0.01),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: height * 0.016,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8),
                Text(
                  '+ ${children.length - 3} more categories',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Expanded view that shows all categories
  Widget _buildExpandedCategoryList(BuildContext context, double height,
      List children, CategoryDialogController dialogController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Subcategories (${children.length})',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: height * 0.01),

        // Show all categories
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            physics: const BouncingScrollPhysics(),
            itemCount: children.length,
            itemBuilder: ((context, index) {
              return _buildCategoryExpansionPanel(
                context,
                height,
                children[index],
                index,
                dialogController,
              );
            }),
          ),
        ),
      ],
    );
  }

  // Category expansion panel (reusable for both views)
  Widget _buildCategoryExpansionPanel(
      BuildContext context,
      double height,
      dynamic categoryItem,
      int index,
      CategoryDialogController dialogController) {
    return ExpansionPanelList(
      animationDuration: Duration(milliseconds: 500),
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                categoryItem['name'],
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                dialogController.fetchSubcategoriesAndToggle(
                  index,
                  categoryItem['_id'] ?? '',
                  categoryItem['name'] ?? '',
                );
              },
            );
          },
          body: Obx(
            () => dialogController.isSubcategoryLoading.value &&
                    dialogController.currentLoadingIndex.value == index
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      Divider(height: 2),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: dialogController.subcategory.length,
                        itemBuilder: (context, subindex) {
                          return GestureDetector(
                            onTap: () {
                              if (dialogController.subcategory[subindex]
                                      ['name'] !=
                                  'no further category') {
                                Get.back(); // Close dialog
                                Get.toNamed(
                                  Routes.SHOPPRODUCTLISTVIEW,
                                  arguments: {
                                    'productId': dialogController
                                        .subcategory[subindex]['_id'],
                                    'categorySlug': dialogController
                                            .subcategory[subindex]['slug'] ??
                                        '',
                                    'name': dialogController
                                        .subcategory[subindex]['name'],
                                    'source': 'category'
                                  },
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    40.0,
                                    10.0,
                                    10.0,
                                    10.0,
                                  ),
                                  child: Text(
                                    dialogController.subcategory[subindex]
                                            ['name'] ??
                                        '',
                                    style: TextStyle(
                                      fontFamily: "Plus Jakarta Sans",
                                      fontSize: height * 0.016,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Divider(height: 2),
                    ],
                  ),
          ),
          isExpanded: dialogController.expandedindex.value == index,
        ),
      ],
      expansionCallback: (int panelIndex, bool isExpanded) {
        dialogController.fetchSubcategoriesAndToggle(
          index,
          categoryItem['_id'] ?? '',
          categoryItem['name'] ?? '',
        );
      },
    );
  }

  // View All / Show Less toggle button
  Widget _buildViewAllToggle(BuildContext context, double height,
      CategoryDialogController dialogController) {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.02),
      child: Center(
        child: TextButton.icon(
          onPressed: () => dialogController.toggleExpandedView(),
          icon: Icon(
            dialogController.isExpandedView.value
                ? Icons.expand_less
                : Icons.expand_more,
            size: height * 0.02,
          ),
          label: Text(
            dialogController.isExpandedView.value
                ? 'Show Less'
                : 'View All Categories',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // Category image widget
  Widget _buildCategoryImage(BuildContext context, double height) {
    return Container(
      width: double.infinity,
      height: height * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            HelperFunctions().getImage(category['featured_image']),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Updated Controller with expanded view state
class CategoryDialogController extends GetxController {
  var subcategory = [].obs;
  var expandedindex = RxInt(-1);
  var isSubcategoryLoading = false.obs;
  var currentLoadingIndex = RxInt(-1);
  var isExpandedView = false.obs; // New state for expanded view
  final List categories;

  CategoryDialogController({required this.categories});

  void toggleExpandedView() {
    isExpandedView.toggle();
    // Reset expanded state when toggling view
    expandedindex.value = -1;
    subcategory.clear();
    update();
  }

  Future<void> fetchSubcategoriesAndToggle(
      int index, String parentId, String parentName) async {
    if (expandedindex.value == index) {
      // Just collapse
      expandedindex.value = -1;
      update();
      return;
    }

    isSubcategoryLoading(true);
    currentLoadingIndex.value = index;
    subcategory.clear();
    expandedindex.value = index; // Expand immediately to show loading
    update();

    var response = await BasicProvider('category').getRequest(
      queryParams: {'childrenOfParent': parentId},
    ).catchError((error) {
      handleError(error);
      return null;
    });

    isSubcategoryLoading(false);
    currentLoadingIndex.value = -1;

    if (response == null) {
      expandedindex.value = -1;
      update();
      return;
    }

    List fetchedChildren = [];
    if (response is Map<String, dynamic> && response.containsKey('docs')) {
      fetchedChildren = response['docs'];
    } else if (response is List) {
      fetchedChildren = response;
    }

    if (fetchedChildren.isEmpty) {
      // Collapse and navigate to Shop view directly
      expandedindex.value = -1;
      Get.back();
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'productId': parentId,
        'categorySlug': '',
        'name': parentName,
        'source': 'category'
      });
    } else {
      subcategory.assignAll(fetchedChildren);
    }
    update();
  }

  void handleError(dynamic error) {
    print('Error fetching subcategories: $error');
    Get.snackbar(
      'Error',
      'Failed to load subcategories',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
