import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/sidebar_config.dart';

void main() {
  group('SidebarConfig test', () {
    test('should create SidebarConfig with default expanded state', () {
      // arrange & act
      final config = SidebarConfig();

      // assert
      expect(config.isExpanded, true);
    });

    test('should create SidebarConfig with collapsed state', () {
      // arrange & act
      final config = SidebarConfig(isExpanded: false);

      // assert
      expect(config.isExpanded, false);
    });

    test('should create initial SidebarConfig with expanded state', () {
      // arrange & act
      final config = SidebarConfig.initial();

      // assert
      expect(config.isExpanded, true);
    });

    test('should serialize to JSON correctly when expanded', () {
      // arrange
      final config = SidebarConfig(isExpanded: true);

      // act
      final json = config.toJson();

      // assert
      expect(json, {'isExpanded': true});
    });

    test('should serialize to JSON correctly when collapsed', () {
      // arrange
      final config = SidebarConfig(isExpanded: false);

      // act
      final json = config.toJson();

      // assert
      expect(json, {'isExpanded': false});
    });

    test('should deserialize from JSON correctly when expanded', () {
      // arrange
      final json = {'isExpanded': true};

      // act
      final config = SidebarConfig.fromJson(json);

      // assert
      expect(config.isExpanded, true);
    });

    test('should deserialize from JSON correctly when collapsed', () {
      // arrange
      final json = {'isExpanded': false};

      // act
      final config = SidebarConfig.fromJson(json);

      // assert
      expect(config.isExpanded, false);
    });

    test('should default to expanded when JSON has missing isExpanded field', () {
      // arrange
      final json = <String, dynamic>{};

      // act
      final config = SidebarConfig.fromJson(json);

      // assert
      expect(config.isExpanded, true);
    });

    test('should default to expanded when JSON has null isExpanded', () {
      // arrange
      final json = {'isExpanded': null};

      // act
      final config = SidebarConfig.fromJson(json);

      // assert
      expect(config.isExpanded, true);
    });

    test('copyWith should create new instance with updated isExpanded', () {
      // arrange
      final original = SidebarConfig(isExpanded: true);

      // act
      final updated = original.copyWith(isExpanded: false);

      // assert
      expect(original.isExpanded, true);
      expect(updated.isExpanded, false);
    });

    test('copyWith should keep original value when not provided', () {
      // arrange
      final original = SidebarConfig(isExpanded: false);

      // act
      final updated = original.copyWith();

      // assert
      expect(updated.isExpanded, false);
    });

    test('props should contain isExpanded', () {
      // arrange
      final config = SidebarConfig(isExpanded: true);

      // act
      final props = config.props;

      // assert
      expect(props, contains(true));
    });

    test('two SidebarConfigs with same state should be equal', () {
      // arrange
      final config1 = SidebarConfig(isExpanded: true);
      final config2 = SidebarConfig(isExpanded: true);

      // assert
      expect(config1, equals(config2));
    });

    test('two SidebarConfigs with different state should not be equal', () {
      // arrange
      final config1 = SidebarConfig(isExpanded: true);
      final config2 = SidebarConfig(isExpanded: false);

      // assert
      expect(config1, isNot(equals(config2)));
    });
  });
}
