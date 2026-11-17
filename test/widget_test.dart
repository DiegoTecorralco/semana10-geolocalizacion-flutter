import 'package:flutter_test/flutter_test.dart';
import 'package:semana10_osm/main.dart';

void main() {
  test('GeoApp se puede construir', () {
    const app = GeoApp();
    expect(app, isNotNull);
  });
}
