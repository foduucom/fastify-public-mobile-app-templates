import 'package:flutter_test/flutter_test.dart';
import 'package:foddu/main.dart';

void main() {
  test('MyApp is created with its required startup route', () {
    const app = MyApp(initialRoute: '/splash');

    expect(app.initialRoute, '/splash');
  });
}
