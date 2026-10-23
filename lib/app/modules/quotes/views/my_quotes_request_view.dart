import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import '../controllers/my_quotes_request_controller.dart';

class MyQuotesRequestView extends GetView<MyQuotesRequestController> {
  const MyQuotesRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Quote Requests',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: context.themeTextColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: context.themeTextColor, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.fetchQuoteRequests();
          },
          color: themePrimaryColor,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: themePrimaryColor,
                ),
              );
            }

            if (controller.quoteRequests.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12.0),
              itemCount: controller.quoteRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.quoteRequests[index];
                return _buildQuoteCard(context, item);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: Get.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.themegreyColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.request_quote_outlined,
                  size: 80,
                  color: context.themeSecondrytext,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Quote Requests Found',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: context.themeTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t submitted any quote requests yet.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: context.themeSecondrytext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(BuildContext context, Map<String, dynamic> item) {
    // Determine urgency chip color
    Color urgencyBgColor;
    Color urgencyTextColor = Colors.white;
    switch (item['urgency'].toString().toLowerCase()) {
      case 'urgent':
        urgencyBgColor = themeRedColor;
        break;
      case 'standard':
        urgencyBgColor = themeBlueColor;
        break;
      case 'flexible':
      default:
        urgencyBgColor = themePrimaryColor;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.themeWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.themeBorderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['productImage'] != null &&
                          item['productImage'].toString().isNotEmpty
                      ? Container(
                          width: 75,
                          height: 75,
                          color: context.themegreyColor,
                          child: CachedNetworkImage(
                          imageUrl: item['productImage'],
                          width: 75,
                          height: 75,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            width: 75,
                            height: 75,
                            color: context.themegreyColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: themePrimaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const SizedBox(
                            width: 75,
                            height: 75,
                            child: ProductImagePlaceholder(radius: 8),
                          ),
                        ))
                      : const SizedBox(
                          width: 75,
                          height: 75,
                          child: ProductImagePlaceholder(radius: 8),
                        ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['productName'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.themeTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: context.themeSecondrytext,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Meta Info (Qty & Date)
                      Row(
                        children: [
                          Text(
                            'Qty: ${item['quantity']}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: context.themeTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '|',
                            style: TextStyle(color: context.themeBorderColor),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['submittedAt'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: context.themeBorderColor, thickness: 0.6),
            ),
            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Urgency Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['urgency'].toString().toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: urgencyTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Action Buttons
                Row(
                  children: [
                    // View Button
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _showRequirementsDialog(context, item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themePrimaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'View Requirements',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Button
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: themeRedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: themeRedColor,
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            controller.confirmDeleteQuote(context, item['id']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRequirementsDialog(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: context.themeWhiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quote Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.themeTextColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 22, color: context.themeTextColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(color: context.themeBorderColor, thickness: 1),
                const SizedBox(height: 8),
                // Product Brief
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: item['productImage'] != null &&
                              item['productImage'].toString().isNotEmpty
                          ? Container(
                              width: 50,
                              height: 50,
                              color: context.themegreyColor,
                              child: CachedNetworkImage(
                                imageUrl: item['productImage'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) =>
                                    const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: ProductImagePlaceholder(radius: 6),
                                ),
                              ),
                            )
                          : const SizedBox(
                              width: 50,
                              height: 50,
                              child: ProductImagePlaceholder(radius: 6),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: context.themeTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quantity: ${item['quantity']} | Urgency: ${item['urgency']}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Additional Requirements:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                // Scrollable requirements container
                Flexible(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.themegreyColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.themeBorderColor, width: 0.6),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        item['additionalRequirements'].toString().trim().isEmpty
                            ? 'No additional requirements specified.'
                            : item['additionalRequirements'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          height: 1.4,
                          color: context.themeTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom Close Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themePrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

