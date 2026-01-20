import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/open_email_in_new_window_config.dart';

void main() {
  group('OpenEmailInNewWindowConfig test', () {
    test('should create OpenEmailInNewWindowConfig with default disabled state', () {
      // arrange & act
      final config = OpenEmailInNewWindowConfig();

      // assert
      expect(config.isEnabled, false);
    });

    test('should create OpenEmailInNewWindowConfig with enabled state', () {
      // arrange & act
      final config = OpenEmailInNewWindowConfig(isEnabled: true);

      // assert
      expect(config.isEnabled, true);
    });

    test('should create initial OpenEmailInNewWindowConfig with disabled state', () {
      // arrange & act
      final config = OpenEmailInNewWindowConfig.initial();

      // assert
      expect(config.isEnabled, false);
    });

    test('should serialize to JSON correctly when enabled', () {
      // arrange
      final config = OpenEmailInNewWindowConfig(isEnabled: true);

      // act
      final json = config.toJson();

      // assert
      expect(json, {'isEnabled': true});
    });

    test('should serialize to JSON correctly when disabled', () {
      // arrange
      final config = OpenEmailInNewWindowConfig(isEnabled: false);

      // act
      final json = config.toJson();

      // assert
      expect(json, {'isEnabled': false});
    });

    test('should deserialize from JSON correctly when enabled', () {
      // arrange
      final json = {'isEnabled': true};

      // act
      final config = OpenEmailInNewWindowConfig.fromJson(json);

      // assert
      expect(config.isEnabled, true);
    });

    test('should deserialize from JSON correctly when disabled', () {
      // arrange
      final json = {'isEnabled': false};

      // act
      final config = OpenEmailInNewWindowConfig.fromJson(json);

      // assert
      expect(config.isEnabled, false);
    });

    test('should default to disabled when JSON has missing isEnabled field', () {
      // arrange
      final json = <String, dynamic>{};

      // act
      final config = OpenEmailInNewWindowConfig.fromJson(json);

      // assert
      expect(config.isEnabled, false);
    });

    test('should default to disabled when JSON has null isEnabled', () {
      // arrange
      final json = {'isEnabled': null};

      // act
      final config = OpenEmailInNewWindowConfig.fromJson(json);

      // assert
      expect(config.isEnabled, false);
    });

    test('copyWith should create new instance with updated isEnabled', () {
      // arrange
      final original = OpenEmailInNewWindowConfig(isEnabled: false);

      // act
      final updated = original.copyWith(isEnabled: true);

      // assert
      expect(original.isEnabled, false);
      expect(updated.isEnabled, true);
    });

    test('copyWith should keep original value when not provided', () {
      // arrange
      final original = OpenEmailInNewWindowConfig(isEnabled: true);

      // act
      final updated = original.copyWith();

      // assert
      expect(updated.isEnabled, true);
    });

    test('props should contain isEnabled', () {
      // arrange
      final config = OpenEmailInNewWindowConfig(isEnabled: true);

      // act
      final props = config.props;

      // assert
      expect(props, contains(true));
    });

    test('two OpenEmailInNewWindowConfigs with same state should be equal', () {
      // arrange
      final config1 = OpenEmailInNewWindowConfig(isEnabled: true);
      final config2 = OpenEmailInNewWindowConfig(isEnabled: true);

      // assert
      expect(config1, equals(config2));
    });

    test('two OpenEmailInNewWindowConfigs with different state should not be equal', () {
      // arrange
      final config1 = OpenEmailInNewWindowConfig(isEnabled: true);
      final config2 = OpenEmailInNewWindowConfig(isEnabled: false);

      // assert
      expect(config1, isNot(equals(config2)));
    });
  });
}
