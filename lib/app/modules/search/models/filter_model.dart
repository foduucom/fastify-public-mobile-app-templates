class FilterModel {
  final double? minPrice;
  final double? maxPrice;
  final bool featured;
  final bool hot;
  final bool trending;
  final bool recommended;
  final List<String> categories;
  final List<String> parentCategories;
  final List<String> specific;
  final List<String> brands;
  final String? sortBy;
  final String? sortOrder;

  const FilterModel({
    this.minPrice,
    this.maxPrice,
    this.featured = false,
    this.hot = false,
    this.trending = false,
    this.recommended = false,
    this.categories = const [],
    this.parentCategories = const [],
    this.specific = const [],
    this.brands = const [],
    this.sortBy,
    this.sortOrder,
  });

  const FilterModel.empty()
      : minPrice = null,
        maxPrice = null,
        featured = false,
        hot = false,
        trending = false,
        recommended = false,
        categories = const [],
        parentCategories = const [],
        specific = const [],
        brands = const [],
        sortBy = null,
        sortOrder = null;

  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      featured ||
      hot ||
      trending ||
      recommended ||
      categories.isNotEmpty ||
      parentCategories.isNotEmpty ||
      specific.isNotEmpty ||
      brands.isNotEmpty ||
      sortBy != null;

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (featured || hot || trending || recommended) count++;
    if (categories.isNotEmpty) count++;
    if (parentCategories.isNotEmpty) count++;
    if (specific.isNotEmpty) count++;
    if (brands.isNotEmpty) count++;
    if (sortBy != null) count++;
    return count;
  }

  /// Returns a map compatible with [Uri.replace(queryParameters:)].
  /// Values are either [String] or [List<String>].
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (minPrice != null) params['min_price'] = minPrice!.toStringAsFixed(2);
    if (maxPrice != null) params['max_price'] = maxPrice!.toStringAsFixed(2);
    if (featured) params['featured'] = 'true';
    if (hot) params['hot'] = 'true';
    if (trending) params['trending'] = 'true';
    if (recommended) params['recommended'] = 'true';
    if (categories.isNotEmpty) params['category'] = categories;
    if (parentCategories.isNotEmpty) {
      params['parentCategory'] = parentCategories;
    }
    if (specific.isNotEmpty) params['specific'] = specific;
    if (brands.isNotEmpty) params['brand'] = brands;
    if (sortBy != null) params['sort_by'] = sortBy!;
    if (sortOrder != null) params['sort_order'] = sortOrder!;

    return params;
  }

  FilterModel copyWith({
    double? minPrice,
    double? maxPrice,
    bool? featured,
    bool? hot,
    bool? trending,
    bool? recommended,
    List<String>? categories,
    List<String>? parentCategories,
    List<String>? specific,
    List<String>? brands,
    String? sortBy,
    String? sortOrder,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearSortBy = false,
    bool clearSortOrder = false,
  }) {
    return FilterModel(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      featured: featured ?? this.featured,
      hot: hot ?? this.hot,
      trending: trending ?? this.trending,
      recommended: recommended ?? this.recommended,
      categories: categories ?? this.categories,
      parentCategories: parentCategories ?? this.parentCategories,
      specific: specific ?? this.specific,
      brands: brands ?? this.brands,
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      sortOrder: clearSortOrder ? null : (sortOrder ?? this.sortOrder),
    );
  }
}
