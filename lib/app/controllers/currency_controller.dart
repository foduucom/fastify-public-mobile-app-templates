import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';

/// The app supports a single currency, served by `GET /api/currency` as
/// `{name, code, symbol, ...}`. There is no switcher and no exchange rate.
class CurrencyController extends GetxController {
  static const _cacheKey = 'app_currency';

  final box = GetStorage();

  /// `{name, code, symbol, exchange_rate: 1}`; empty until first load.
  var selectedCurrency = <dynamic, dynamic>{}.obs;
  var isLoading = false.obs;

  String get symbol {
    final s = selectedCurrency['symbol']?.toString();
    if (s != null && s.isNotEmpty && s != '₹') return s;
    return r'$';
  }

  String get code {
    final c = selectedCurrency['code']?.toString();
    if (c != null && c.isNotEmpty && c != 'INR') return c;
    return 'USD';
  }

  bool get isLoaded => symbol.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _dropLegacyKeys();
    _loadCached();
  }

  // Older builds persisted a user-picked currency (e.g. INR) under these keys.
  void _dropLegacyKeys() {
    box.remove('selected_currency');
    box.remove('backend_default_code');
    final saved = box.read(_cacheKey);
    if (saved is Map && (saved['code'] == 'INR' || saved['symbol'] == '₹')) {
      box.remove(_cacheKey);
    }
  }

  void _loadCached() {
    final saved = box.read(_cacheKey);
    if (saved is Map && saved['symbol'] != '₹' && saved['code'] != 'INR') {
      _apply(saved);
    } else {
      _apply({'name': 'US Dollar', 'code': 'USD', 'symbol': r'$'});
    }
  }

  void _apply(Map data) {
    selectedCurrency.value = {
      'name': data['name'],
      'code': data['code'],
      'symbol': data['symbol'],
      'exchange_rate': 1.0,
    };
  }

  /// Fetches the currency. Returns true when one is available (fresh or
  /// cached), false when the caller should show a retry state.
  Future<bool> fetchCurrency() async {
    isLoading.value = true;
    try {
      final response = await BasicProvider("currency").getRequest();
      if (response is Map && response['symbol'] != null) {
        _apply(response);
        box.write(_cacheKey, Map<String, dynamic>.from(selectedCurrency));
      }
    } catch (e) {
      print('Error loading currency: $e');
    } finally {
      isLoading.value = false;
    }
    return isLoaded;
  }

  double convertPrice(dynamic basePrice) {
    if (basePrice == null) return 0.0;
    if (basePrice is num) return basePrice.toDouble();
    return double.tryParse(basePrice.toString()) ?? 0.0;
  }

  String formatPrice(dynamic basePrice) {
    return '$symbol${convertPrice(basePrice).toStringAsFixed(2)}';
  }
}
