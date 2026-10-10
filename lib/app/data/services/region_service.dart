import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/region_model.dart';

class RegionService {
  /// Throws when the request failed or there is no connectivity, so callers
  /// can show a retry state.
  static Future<RegionPage> fetchCountries({int page = 1, String search = ''}) {
    return _fetch('countries', page, search);
  }

  static Future<RegionPage> fetchStates({
    required String countrySlug,
    int page = 1,
    String search = '',
  }) {
    return _fetch('states/$countrySlug', page, search);
  }

  /// Walks every page; used only to resolve ids that arrive without a name.
  static Future<List<Region>> fetchAll(
      Future<RegionPage> Function(int page) loader) async {
    final all = <Region>[];
    var page = 1;
    while (true) {
      final result = await loader(page);
      all.addAll(result.items);
      if (!result.hasNext) break;
      page = result.nextPage;
    }
    return all;
  }

  static Future<RegionPage> _fetch(String path, int page, String search) async {
    final term = search.trim();
    final response = await BasicProvider(path).getRequest(queryParams: {
      'page': page.toString(),
      if (term.isNotEmpty) 'search': term,
    });
    if (response == null) throw Exception('Could not load $path');
    return RegionPage.fromResponse(response, page);
  }
}
