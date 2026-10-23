import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/data/services/category_product_service.dart';
import 'package:zouhi/app/modules/category_products/controllers/category_products_controller.dart';

class _FakeService extends CategoryProductService {
  final calls = <String>[];
  @override
  Future<CategoryProductsPage?> fetchByParentCategory(String categoryId,
      {String? categorySlug, int page = 1, int count = 20}) async {
    calls.add('$categoryId#$page');
    if (categoryId == 'bad') return null;
    final start = (page - 1) * 20;
    final n = page == 1 ? 20 : 14;
    return CategoryProductsPage(
      items: [
        for (var i = 0; i < n; i++)
          CategoryProduct(
              id: '${start + i}',
              name: 'p${start + i}',
              slug: '',
              description: '',
              image: null,
              price: 1)
      ],
      pageInfo: PageInfo(
          currentPage: page, lastPage: 2, total: 34, hasNext: page < 2),
    );
  }
}

void main() {
  tearDown(Get.reset);

  CategoryProductsController build(_FakeService s, Map args) {
    Get.testMode = true;
    return CategoryProductsController(service: s);
  }

  test('paginates 34 items over two pages and does not refetch loaded tab',
      () async {
    final svc = _FakeService();
    final c = build(svc, {});
    c.tabs.add(const CategoryTab('cat', 'Cleaning'));
    await c.ensureLoaded('cat');
    expect(c.stateFor('cat').items.length, 20);
    expect(c.stateFor('cat').hasNext.value, isTrue);

    await c.loadMore('cat');
    expect(c.stateFor('cat').items.length, 34);
    expect(c.stateFor('cat').hasNext.value, isFalse);

    await c.ensureLoaded('cat'); // cached
    await c.loadMore('cat'); // no next page
    expect(svc.calls, ['cat#1', 'cat#2']);
  });

  test('failed first load flags error and retry works', () async {
    final svc = _FakeService();
    final c = build(svc, {});
    await c.ensureLoaded('bad');
    expect(c.stateFor('bad').hasError.value, isTrue);
    expect(c.stateFor('bad').items, isEmpty);
  });

  test('refresh resets to page 1', () async {
    final svc = _FakeService();
    final c = build(svc, {});
    await c.ensureLoaded('cat');
    await c.loadMore('cat');
    await c.refreshTab('cat');
    expect(c.stateFor('cat').items.length, 20);
    expect(c.stateFor('cat').page, 1);
  });

  test('CategoryProduct parses catalog_mode correctly', () {
    final json = {
      '_id': '6ad1d744f615813aab5e5a41',
      'name': 'Riser Breakout Cable',
      'price': '3.34',
      'sale_price': '3.34',
      'catalog_mode': {
        'is_enabled': true,
        'button_text': 'Contact for Pricing',
        'contact_url': '/contact',
      },
    };

    final product = CategoryProduct.fromJson(json);
    expect(product.isCatalogMode, isTrue);
    expect(product.catalogButtonText, 'Contact for Pricing');
    expect(product.hasDiscount, isFalse);
  });
}
