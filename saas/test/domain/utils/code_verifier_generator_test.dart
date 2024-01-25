import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas/domain/utils/code_verifier_generator.dart';

import 'generate_random_from_defined_number.dart';

void main() {
  group('[Verify Code length]', () {
    test('generateCodeVerifier will throw when not have the good length', () {
      final generator = CodeVerifierGenerator(CryptoUtils());

      expect(() => generator.generateCodeVerifier(Random.secure(), 31), throwsArgumentError);

      expect(() => generator.generateCodeVerifier(Random.secure(), 129), throwsArgumentError);
    });

    test('generateCodeVerifier produces value unpadding', () {
      final generator = CodeVerifierGenerator(CryptoUtils());

      final verifier = generator.generateCodeVerifier(Random.secure(), 43);

      expect(verifier.value.length, lessThan(128));
      expect(verifier.value.length, greaterThan(43));
      expect(verifier.value.contains('='), equals(false));
    });

    test('generateCodeVerifier produces value no wrapping', () {
      final generator = CodeVerifierGenerator(CryptoUtils());

      final verifier = generator.generateCodeVerifier(Random.secure(), 43);

      expect(verifier.value.length, lessThan(128));
      expect(verifier.value.length, greaterThan(43));
      expect(verifier.value.contains('\n'), equals(false));
      expect(verifier.value.contains('\r'), equals(false));
    });
  });

  group('[Verify code generator logic]', () {
    test('generateCodeVerifier produces value good value in the case remove padding', () {
      final generator = CodeVerifierGenerator(CryptoUtils());

      final definedNumbers = [
        104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104
      ];
      final randomSource = GenerateRandomFromDefinedNumber(definedNumbers);

      final verifier = generator.generateCodeVerifier(randomSource, 43);

      expect(verifier.value, equals('aHVodWh1aHVodWh1aHVodWh1aHVodWh1aHVodWh1aHVodWh1aHVodWh1aA'));
    });

    test('generateCodeVerifier produces value good value in the case remove /', () {
      final generator = CodeVerifierGenerator(CryptoUtils());

      final definedNumbers = [104, 117, 104, 106, 105, 106, 105, 106, 105, 106,
        113, 105, 106, 105, 119, 106, 105, 113, 117, 104, 117, 104, 117, 104, 117,
        104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104, 117, 104,
        127, 117, 104, 85
      ];
      final randomSource = GenerateRandomFromDefinedNumber(definedNumbers);

      final verifier = generator.generateCodeVerifier(randomSource, definedNumbers.length);

      expect(verifier.value, equals('aHVoamlqaWppanFpaml3amlxdWh1aHVodWh1aHVodWh1aHVodWh1aH91aFU'));
    });
  });
}