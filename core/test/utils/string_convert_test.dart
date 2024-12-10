import 'dart:convert';

import 'package:core/domain/exceptions/string_exception.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('string convert test:', () {
    const testText = 'Hello';
    test(
      'should use utf8 decoder '
      'when isHtml is true',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: null, isHtml: true);
      
      // assert
      expect(result, testText);
    });

    test(
      'should use utf8 decoder '
      'when charset contains utf-8',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: 'utf-8');
      
      // assert
      expect(result, testText);
    });

    test(
      'should use latin1 decoder '
      'when charset contains latin-1',
    () {
      // arrange
      final bytes = latin1.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: 'latin-1');
      
      // assert
      expect(result, testText);
    });

    test(
      'should use ascii decoder '
      'when charset contains ascii',
    () {
      // arrange
      final bytes = ascii.encode(testText);
      
      // act
      final result = StringConvert.decodeFromBytes(bytes, charset: 'ascii');
      
      // assert
      expect(result, testText);
    });

    test(
      'should throw NullCharsetException '
      'when charset is null',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // assert
      expect(
        () => StringConvert.decodeFromBytes(bytes, charset: null),
        throwsA(isA<NullCharsetException>()),
      );
    });

    test(
      'should throw UnsupportedCharsetException '
      'when charset is unsupported',
    () {
      // arrange
      final bytes = utf8.encode(testText);
      
      // assert
      expect(
        () => StringConvert.decodeFromBytes(bytes, charset: 'unsupported'),
        throwsA(isA<UnsupportedCharsetException>()),
      );
    });
  });
}