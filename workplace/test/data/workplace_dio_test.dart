import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/workplace_dio.dart';

void main() {
  group('WorkplaceDio', () {
    late Dio originalInstance;

    setUp(() {
      originalInstance = WorkplaceDio.instance;
    });

    tearDown(() {
      // Restore the original instance after each test
      WorkplaceDio.setInstance(originalInstance);
    });

    test('instance returns a Dio object by default', () {
      expect(WorkplaceDio.instance, isA<Dio>());
    });

    test('instance returns the same object on repeated calls', () {
      final first = WorkplaceDio.instance;
      final second = WorkplaceDio.instance;
      expect(identical(first, second), isTrue);
    });

    test('setInstance replaces the singleton', () {
      final mockDio = Dio();
      WorkplaceDio.setInstance(mockDio);
      expect(identical(WorkplaceDio.instance, mockDio), isTrue);
    });

    test('setInstance with a new Dio replaces the previous one', () {
      final first = Dio();
      final second = Dio();
      WorkplaceDio.setInstance(first);
      WorkplaceDio.setInstance(second);
      expect(identical(WorkplaceDio.instance, second), isTrue);
    });
  });
}