import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/quoted_content_config.dart';

void main() {
  group('QuotedContentConfig test', () {
    test('should create QuotedContentConfig with default hidden state', () {
      // arrange & act
      final config = QuotedContentConfig();

      // assert
      expect(config.isHiddenByDefault, true);
    });

    test('should create QuotedContentConfig with visible state', () {
      // arrange & act
      final config = QuotedContentConfig(isHiddenByDefault: false);

      // assert
      expect(config.isHiddenByDefault, false);
    });

    test('should create initial QuotedContentConfig with hidden state', () {
      // arrange & act
      final config = QuotedContentConfig.initial();

      // assert
      expect(config.isHiddenByDefault, true);
    });

    test('should serialize to JSON correctly when hidden', () {
      // arrange
      final config = QuotedContentConfig(isHiddenByDefault: true);

      // act
      final json = config.toJson();

      // assert
      expect(json, {'isHiddenByDefault': true});
    });

    test('should serialize to JSON correctly when visible', () {
      // arrange
      final config = QuotedContentConfig(isHiddenByDefault: false);

      // act
      final json = config.toJson();

      // assert
      expect(json, {'isHiddenByDefault': false});
    });

    test('should deserialize from JSON correctly when hidden', () {
      // arrange
      final json = {'isHiddenByDefault': true};

      // act
      final config = QuotedContentConfig.fromJson(json);

      // assert
      expect(config.isHiddenByDefault, true);
    });

    test('should deserialize from JSON correctly when visible', () {
      // arrange
      final json = {'isHiddenByDefault': false};

      // act
      final config = QuotedContentConfig.fromJson(json);

      // assert
      expect(config.isHiddenByDefault, false);
    });

    test('should default to hidden when JSON has missing isHiddenByDefault field', () {
      // arrange
      final json = <String, dynamic>{};

      // act
      final config = QuotedContentConfig.fromJson(json);

      // assert
      expect(config.isHiddenByDefault, true);
    });

    test('should default to hidden when JSON has null isHiddenByDefault', () {
      // arrange
      final json = {'isHiddenByDefault': null};

      // act
      final config = QuotedContentConfig.fromJson(json);

      // assert
      expect(config.isHiddenByDefault, true);
    });

    test('copyWith should create new instance with updated isHiddenByDefault', () {
      // arrange
      final original = QuotedContentConfig(isHiddenByDefault: true);

      // act
      final updated = original.copyWith(isHiddenByDefault: false);

      // assert
      expect(original.isHiddenByDefault, true);
      expect(updated.isHiddenByDefault, false);
    });

    test('copyWith should keep original value when not provided', () {
      // arrange
      final original = QuotedContentConfig(isHiddenByDefault: false);

      // act
      final updated = original.copyWith();

      // assert
      expect(updated.isHiddenByDefault, false);
    });

    test('props should contain isHiddenByDefault', () {
      // arrange
      final config = QuotedContentConfig(isHiddenByDefault: true);

      // act
      final props = config.props;

      // assert
      expect(props, contains(true));
    });

    test('two QuotedContentConfigs with same state should be equal', () {
      // arrange
      final config1 = QuotedContentConfig(isHiddenByDefault: true);
      final config2 = QuotedContentConfig(isHiddenByDefault: true);

      // assert
      expect(config1, equals(config2));
    });

    test('two QuotedContentConfigs with different state should not be equal', () {
      // arrange
      final config1 = QuotedContentConfig(isHiddenByDefault: true);
      final config2 = QuotedContentConfig(isHiddenByDefault: false);

      // assert
      expect(config1, isNot(equals(config2)));
    });
  });
}
