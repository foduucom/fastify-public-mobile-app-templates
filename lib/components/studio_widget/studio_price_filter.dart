import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import 'studio_common_widgets.dart';

import 'package:foduu_ecommerce/app/routes/app_pages.dart';

class PriceFilter extends StatefulWidget {
  final Map<String, dynamic> contentJson;

  const PriceFilter({super.key, required this.contentJson});

  @override
  State<PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends State<PriceFilter> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    List pricePoints = widget.contentJson['price_points'] ?? [];
    bool showSlider = widget.contentJson['show_slider'] ?? false;

    // Sort price points for slider to make sense
    if (showSlider) {
      pricePoints.sort((a, b) => a.compareTo(b));
    }

    if (pricePoints.isEmpty) return const SizedBox();

    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudioSectionHeader(
            title: widget.contentJson['heading'] ?? "Filter by Price",
            subtitle: widget.contentJson['subheading'] ?? '',
          ),
          if (showSlider)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Under ₹${pricePoints[_currentSliderValue.toInt()]}",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          const SizedBox(height: 10),
          showSlider ? _buildSlider(pricePoints) : _buildChipList(pricePoints),
        ],
      ),
    );
  }

  Widget _buildSlider(List pricePoints) {
    // Ensure current value is within valid range [0, length-1]
    if (_currentSliderValue >= pricePoints.length) {
      _currentSliderValue = 0;
    }

    return Column(
      children: [
        Slider(
          value: _currentSliderValue,
          min: 0,
          max: (pricePoints.length - 1).toDouble(),
          divisions: pricePoints.length > 1 ? pricePoints.length - 1 : 1,
          label: "₹${pricePoints[_currentSliderValue.toInt()]}",
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
            });
          },
          onChangeEnd: (double value) {
            var selectedPrice = pricePoints[value.toInt()];
            _navigateToProductList(selectedPrice);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹${pricePoints.first}"),
              Text("₹${pricePoints.last}"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildChipList(List pricePoints) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pricePoints.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text("Under ₹${pricePoints[index]}"),
            onPressed: () {
              _navigateToProductList(pricePoints[index]);
            },
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Theme.of(context).colorScheme.outline)),
          );
        },
      ),
    );
  }

  void _navigateToProductList(dynamic price) {
    Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
      'source': 'price_filter',
      'maxPrice': price,
      'name': "Under ₹$price"
    });
  }
}
