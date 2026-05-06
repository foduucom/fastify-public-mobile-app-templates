import 'package:new_fastify_template/app/modules/search/models/filter_model.dart';

class ProductService {
  /// Builds a unified query-params map from page, search text, and filters.
  ///
  /// Returns [Map<String, dynamic>] where values are [String] or [List<String>],
  /// compatible with [Uri.replace(queryParameters:)].
  static Map<String, dynamic> buildQueryParams({
    required int page,
    String? search,
    FilterModel? filter,
  }) {
    final params = <String, dynamic>{
      'page': page.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (filter != null && filter.hasActiveFilters) {
      params.addAll(filter.toQueryParams());
    }

    return params;
  }
}
