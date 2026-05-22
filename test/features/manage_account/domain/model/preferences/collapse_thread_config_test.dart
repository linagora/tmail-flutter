import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';

void main() {
  group('CollapseThreadConfig', () {
    test('initial defaults to disabled', () {
      final config = CollapseThreadConfig.initial();
      expect(config.isEnabled, isFalse);
    });

    test('copyWith returns new instance with updated value', () {
      final original = CollapseThreadConfig(isEnabled: false);
      final updated = original.copyWith(isEnabled: true);

      expect(updated.isEnabled, isTrue);
      expect(original.isEnabled, isFalse);
    });

    test('copyWith preserves existing value when no argument is passed', () {
      final config = CollapseThreadConfig(isEnabled: true);
      final copy = config.copyWith();

      expect(copy.isEnabled, isTrue);
    });

    test('fromJson round-trips through toJson', () {
      final config = CollapseThreadConfig(isEnabled: true);
      final json = config.toJson();
      final restored = CollapseThreadConfig.fromJson(json);

      expect(restored, config);
    });

    test('equality is value-based', () {
      expect(
        CollapseThreadConfig(isEnabled: true),
        equals(CollapseThreadConfig(isEnabled: true)),
      );
      expect(
        CollapseThreadConfig(isEnabled: true),
        isNot(equals(CollapseThreadConfig(isEnabled: false))),
      );
    });
  });
}
