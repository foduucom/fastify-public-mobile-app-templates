/// A country or state returned by `api/countries` and `api/states/<slug>`.
class Region {
  final String id;
  final String name;
  final String slug;
  final String? countryCode;

  const Region({
    required this.id,
    required this.name,
    required this.slug,
    this.countryCode,
  });

  /// Backend names can carry stray line breaks ("Assam\r\nBihar").
  static String cleanName(dynamic raw) =>
      (raw ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();

  factory Region.fromJson(Map json) => Region(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: cleanName(json['name']),
        slug: (json['slug'] ?? '').toString(),
        countryCode: json['country_code']?.toString(),
      );
}

/// One page of the paginated regions response.
class RegionPage {
  final List<Region> items;
  final bool hasNext;
  final int nextPage;

  const RegionPage({
    required this.items,
    required this.hasNext,
    required this.nextPage,
  });

  /// [response] is what `BasicProvider` returns: the body's `data` object,
  /// i.e. `{data: [...], hasNextPage, next, ...}`.
  factory RegionPage.fromResponse(dynamic response, int requestedPage) {
    // Tolerate an un-unwrapped body: {data: {data: [...], hasNextPage, ...}}.
    if (response is Map &&
        response['data'] is Map &&
        (response['data'] as Map)['data'] is List) {
      response = response['data'];
    }
    final rawList = response is List
        ? response
        : (response is Map && response['data'] is List
            ? response['data'] as List
            : const []);
    final items = rawList
        .whereType<Map>()
        .map(Region.fromJson)
        .where((r) => r.id.isNotEmpty && r.name.isNotEmpty)
        .toList();
    final hasNext = response is Map && response['hasNextPage'] == true;
    final next = response is Map ? response['next'] : null;
    return RegionPage(
      items: items,
      hasNext: hasNext,
      nextPage: next is int ? next : requestedPage + 1,
    );
  }
}
