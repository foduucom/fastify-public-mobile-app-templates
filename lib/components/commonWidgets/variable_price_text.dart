import 'package:flutter/material.dart';

class VariablePriceText extends StatelessWidget {
  final num lowestPrice;
  final num highestPrice;
  final TextStyle? style;
  final String currencySymbol;
  final String separator;

  const VariablePriceText({
    super.key,
    required this.lowestPrice,
    required this.highestPrice,
    this.style,
    this.currencySymbol = '₹',
    this.separator = ' - ',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final effectiveStyle = style ??
        textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        );

    return Text(
      '$currencySymbol$lowestPrice$separator$currencySymbol$highestPrice',
      style: effectiveStyle,
    );
  }
}
