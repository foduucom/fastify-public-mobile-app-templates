import 'package:flutter_test/flutter_test.dart';
import 'package:zouhi/app/modules/shop/controllers/productdetial_controller.dart';

void main() {
  test('builds the public web product URL from a slug', () {
    expect(
      ProductdetialController.productShareUrl('fire-rated-cable'),
      'https://vision.vbought.com/product/fire-rated-cable',
    );
  });

  test('trims and encodes unsafe slug characters', () {
    expect(
      ProductdetialController.productShareUrl(' cable 2/5 '),
      'https://vision.vbought.com/product/cable%202%2F5',
    );
  });
}
