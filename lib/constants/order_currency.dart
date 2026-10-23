import 'package:zouhi/constants/constants.dart';

/// `order.currency` is either a Map `{symbol, exchange_rate, ...}` or a plain
/// symbol string such as "\$". These helpers accept both shapes.
String orderCurrencySymbol(dynamic currencyField) {
  if (currencyField is Map) {
    final symbol = currencyField['symbol']?.toString();
    if (symbol != null && symbol.isNotEmpty && symbol != '₹') return symbol;
  } else if (currencyField is String && currencyField.trim().isNotEmpty && currencyField.trim() != '₹') {
    return currencyField.trim();
  }
  final cur = currency;
  if (cur.isNotEmpty && cur != '₹') return cur;
  return r'$';
}

double orderExchangeRate(dynamic currencyField) {
  if (currencyField is Map) {
    return double.tryParse(currencyField['exchange_rate']?.toString() ?? '') ??
        1.0;
  }
  return 1.0;
}
