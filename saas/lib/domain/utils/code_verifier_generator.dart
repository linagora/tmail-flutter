import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:saas/domain/model/verifier_code.dart';


class CodeVerifierGenerator {
  static const _maxCodeEntropyLength = 96;
  static const _minCodeEntropyLength = 43;
  static const _maxCodeLength = 128;
  static const _minCodeLength = 43;


  VerifierCode generateCodeVerifier(Random source, int length) {
    if (length < _minCodeEntropyLength || length > _maxCodeEntropyLength) {
      throw ArgumentError.value(length, 'length',
          'Length must be between $_minCodeEntropyLength and $_maxCodeEntropyLength');
    }
    final rng = source;
    final list = Uint8List(length);

    String? encodeResult;
    int retryCount = 1;

    while (encodeResult == null
        || encodeResult.length < _minCodeLength || encodeResult.length > _maxCodeLength
        || retryCount <= 3
    ) {
      encodeResult = null;
      list.setAll(0, Iterable.generate(list.length, (i) => rng.nextInt(256)));

      // encode settings: no padding + url safe + no wrapping
      encodeResult = base64UrlEncode(list)
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll('=', '');

      retryCount++;
    }

    if (encodeResult.length < _minCodeLength || encodeResult.length > _maxCodeLength) {
      throw Exception('Cannot generate verifier code');
    }

    return VerifierCode(encodeResult);
  }
}
