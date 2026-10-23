import 'package:flutter_test/flutter_test.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';

Map<String, dynamic> _product(String id, {dynamic price, dynamic sale}) => {
      '_id': id,
      'name': 'Product $id',
      'slug': 'product-$id',
      'content': 'No description provided',
      'featured_image': null,
      'gallery': [],
      'external_image_url': null,
      'average_rating': null,
      'rating_count': null,
      'price': price ?? {'\$numberDecimal': '155.77'},
      'sale_price': sale,
      // heavy field that must never be read
      'owner_id': {'email': 'x@y.z', 'remember_tokens': [{'token': 'secret'}]},
    };

void main() {
  test('parses unwrapped page with pagination (2-page sample shape)', () {
    final page = CategoryProductsPage.fromResponse({
      'data': [_product('a'), _product('b')],
      'total': 34,
      'pagination': {
        'current_page': 1,
        'last_page': 2,
        'per_page': 20,
        'total': 34,
        'has_next': true,
      },
    });
    expect(page.items.length, 2);
    expect(page.pageInfo.hasNext, isTrue);
    expect(page.pageInfo.lastPage, 2);
    expect(page.pageInfo.total, 34);
  });

  test('parses single-page sample, null image/rating, numberDecimal price', () {
    final page = CategoryProductsPage.fromResponse({
      'status': 'success',
      'data': {
        'data': [_product('6a992a807aa8cea57b69ff01')],
        'pagination': {'current_page': 1, 'last_page': 1, 'has_next': false},
      },
    });
    final p = page.items.single;
    expect(page.pageInfo.hasNext, isFalse);
    expect(p.price, 155.77);
    expect(p.image, isNull);
    expect(p.hasRating, isFalse);
    expect(p.hasDiscount, isFalse);
    expect(p.description, 'No description provided');
  });

  test('sale price only counts when lower than price', () {
    final cheaper = CategoryProduct.fromJson(
        _product('c', price: 100, sale: {'\$numberDecimal': '80'}));
    expect(cheaper.effectivePrice, 80);
    expect(cheaper.hasDiscount, isTrue);
    final bogus = CategoryProduct.fromJson(_product('d', price: 100, sale: 150));
    expect(bogus.effectivePrice, 100);
  });

  test('falls back to current_page < last_page when has_next missing', () {
    final page = CategoryProductsPage.fromResponse({
      'data': [_product('a')],
      'current_page': 1,
      'last_page': 3,
    });
    expect(page.pageInfo.hasNext, isTrue);
  });

  test('tolerates garbage', () {
    expect(CategoryProductsPage.fromResponse(null).items, isEmpty);
    expect(CategoryProductsPage.fromResponse('oops').items, isEmpty);
  });
}
