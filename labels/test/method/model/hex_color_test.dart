import 'package:flutter_test/flutter_test.dart';
import 'package:labels/model/hex_color.dart';

void main() {
  group('HexColor', () {
    test('creates instance when valid #RRGGBB', () {
      final color = HexColor('#A1B2C3');
      expect(color.value, '#A1B2C3');
    });

    test('creates instance when valid #AARRGGBB', () {
      final color = HexColor('#80A1B2C3');
      expect(color.value, '#80A1B2C3');
    });

    test('throws when value is empty', () {
      expect(
        () => HexColor(''),
        throwsA(
          predicate((e) =>
              e is ArgumentError &&
              e.message == 'hex string must not be empty'),
        ),
      );
    });

    test('throws when missing leading #', () {
      expect(
        () => HexColor('A1B2C3'),
        throwsA(
          predicate((e) =>
              e is ArgumentError &&
              e.message == 'hex string must start with #'),
        ),
      );
    });

    test('throws when format #FFF (unsupported)', () {
      expect(
        () => HexColor('#FFF'),
        throwsA(
          predicate((e) =>
              e is ArgumentError &&
              e.message == 'invalid hex format: expected #RRGGBB or #AARRGGBB'),
        ),
      );
    });

    test('throws when contains invalid characters', () {
      expect(
        () => HexColor('#GGHHII'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when length is too long', () {
      expect(
        () => HexColor('#A1B2C3D4E5'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('supports value equality (Equatable)', () {
      final c1 = HexColor('#FFFFFF');
      final c2 = HexColor('#FFFFFF');

      expect(c1, equals(c2));
      expect(c1.props, equals(['#FFFFFF']));
    });
  });
}
