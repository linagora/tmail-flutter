import 'package:core/presentation/extensions/iterable_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IterableExtension', () {
    group('groupBy method', () {
      test('group by int keys without sort', () {
        final data = [1, 2, 3, 4];
        final result = data.groupBy((e) => e % 2);

        expect(result.keys.toList(), [1, 0]);
        expect(result[0], [2, 4]);
        expect(result[1], [1, 3]);
      });

      test('group by int keys with sort, -1 goes last', () {
        final data = [10, 20, 30, 40];
        final categories = [2, -1, 1, 3];
        final result = data.groupBy((e) {
          final idx = data.indexOf(e);
          return categories[idx];
        }, sortKeys: true);

        expect(result.keys.toList(), [1, 2, 3, -1]);
        expect(result[1], [30]);
        expect(result[2], [10]);
        expect(result[3], [40]);
        expect(result[-1], [20]);
      });

      test('group by string keys with sort', () {
        final words = ['apple', 'banana', 'cherry', 'avocado'];
        final result = words.groupBy((w) => w[0], sortKeys: true);

        expect(result.keys.toList(), ['a', 'b', 'c']);
        expect(result['a'], ['apple', 'avocado']);
        expect(result['b'], ['banana']);
        expect(result['c'], ['cherry']);
      });

      test('group with multiple elements in same group', () {
        final data = ['cat', 'car', 'dog', 'door'];
        final result = data.groupBy((s) => s[0]);

        expect(result['c'], ['cat', 'car']);
        expect(result['d'], ['dog', 'door']);
      });

      test('empty list returns empty map', () {
        final data = <int>[];
        final result = data.groupBy((e) => e);

        expect(result, isEmpty);
      });
    });
  });
}
