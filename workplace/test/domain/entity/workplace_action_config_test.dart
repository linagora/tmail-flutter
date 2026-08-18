import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';

void main() {
  group('WorkplaceActionConfig::equality::', () {
    test('two configs with the same label, maxFileSize and availableSize are equal', () {
      const a = WorkplaceActionConfig(label: 'x', maxFileSize: 100, availableSize: 100);
      const b = WorkplaceActionConfig(label: 'x', maxFileSize: 100, availableSize: 100);

      expect(a, equals(b));
    });

    test('configs differing only by maxFileSize are not equal', () {
      const a = WorkplaceActionConfig(label: 'x', maxFileSize: 100, availableSize: 100);
      const b = WorkplaceActionConfig(label: 'x', maxFileSize: 200, availableSize: 100);

      expect(a, isNot(equals(b)));
    });

    test('configs differing only by availableSize are not equal', () {
      const a = WorkplaceActionConfig(label: 'x', maxFileSize: 100, availableSize: 100);
      const b = WorkplaceActionConfig(label: 'x', maxFileSize: 100, availableSize: 200);

      expect(a, isNot(equals(b)));
    });
  });
}
