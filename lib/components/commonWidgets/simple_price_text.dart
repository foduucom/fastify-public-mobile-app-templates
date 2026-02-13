import 'package:flutter/material.dart';

class SimplePriceText extends StatelessWidget {
  final num price;
  final num? originalPrice;
  final String? discountLabel;
  final TextStyle? priceStyle;
  final TextStyle? originalPriceStyle;
  final TextStyle? discountStyle;
  final String currencySymbol;
  final double spacing;

  const SimplePriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.discountLabel,
    this.priceStyle,
    this.originalPriceStyle,
    this.discountStyle,
    this.currencySymbol = '₹',
    this.spacing = 6, // logical pixels now
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final effectivePriceStyle = priceStyle ??
        textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        );

    final effectiveOriginalStyle = originalPriceStyle ??
        textTheme.bodySmall?.copyWith(
          decoration: TextDecoration.lineThrough,
          color: colorScheme.onSurfaceVariant,
        );

    final effectiveDiscountStyle = discountStyle ??
        textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w500,
        );

    final hasDiscount = originalPrice != null &&
        discountLabel != null &&
        discountLabel!.isNotEmpty;

    return RichText(
      text: TextSpan(
        text: '$currencySymbol$price',
        style: effectivePriceStyle,
        children: [
          if (hasDiscount) ...[
            WidgetSpan(child: SizedBox(width: spacing)),
            TextSpan(
              text: '$currencySymbol$originalPrice',
              style: effectiveOriginalStyle,
            ),
            WidgetSpan(child: SizedBox(width: spacing / 2)),
            TextSpan(
              text: discountLabel!,
              style: effectiveDiscountStyle,
            ),
          ],
        ],
      ),
    );
  }
}
