
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('datetime test', () {

    test('daysBetween should return 1 day2 when day2 > day1', () async {
      DateTime date1 = DateTime.parse("2021-10-20 12:59:12.000");
      DateTime date2 = DateTime.parse("2021-10-21 10:29:03.000");

      expect(date2.daysBetween(date1), 1);
    });

    test('daysBetween should return 1 days when day1 > day2', () async {
      DateTime date1 = DateTime.parse("2021-10-22 12:59:12.000");
      DateTime date2 = DateTime.parse("2021-10-21 10:29:03.000");

      expect(date2.daysBetween(date1), 1);
    });

    test('daysBetween should return 0 day when day1 = day2', () async {
      DateTime date1 = DateTime.parse("2021-10-22 12:59:12.000");
      DateTime date2 = DateTime.parse("2021-10-22 10:29:03.000");

      expect(date2.daysBetween(date1), 0);
    });
  });
}