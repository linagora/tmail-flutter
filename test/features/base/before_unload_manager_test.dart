import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/before_unload_manager.dart';

void main() {
  
  group('before unload manager test:', () {
    test(
      'should finish all futures '
      'when no future fails',
    () async {
      // arrange
      List<int> result = [];
      future1Second() => Future<void>.delayed(const Duration(seconds: 1), () => result.add(1));
      future2Second() => Future<void>.delayed(const Duration(seconds: 2), () => result.add(2));
      future3Second() => Future<void>.delayed(const Duration(seconds: 3), () => result.add(3));
      final beforeUnloadManager = BeforeUnloadManager();
      beforeUnloadManager.addListener(future1Second);
      beforeUnloadManager.addListener(future2Second);
      beforeUnloadManager.addListener(future3Second);

      // act
      await beforeUnloadManager.executeBeforeUnloadListeners();

      // assert
      expect(result.length, 3);
    });

    test(
      'should finish all possible futures '
      'when one future fail',
    () async {
      // arrange
      List<int> result = [];
      final exception = Exception('error');
      future1Second() => Future<void>.delayed(const Duration(seconds: 1), () => result.add(1));
      future2Second() => Future<void>.delayed(const Duration(seconds: 2), () => throw exception);
      future3Second() => Future<void>.delayed(const Duration(seconds: 3), () => result.add(3));
      final beforeUnloadManager = BeforeUnloadManager();
      beforeUnloadManager.addListener(future1Second);
      beforeUnloadManager.addListener(future2Second);
      beforeUnloadManager.addListener(future3Second);

      // act
      await beforeUnloadManager.executeBeforeUnloadListeners();

      // assert
      expect(result.length, 2);
    });

    test(
      'should finish all possible futures '
      'when more than one future fail',
    () async {
      // arrange
      List<int> result = [];
      final exception1 = Exception('error 1');
      final exception2 = Exception('error 2');
      future1Second() => Future<void>.delayed(const Duration(seconds: 1), () => throw exception1);
      future2Second() => Future<void>.delayed(const Duration(seconds: 2), () => throw exception2);
      future3Second() => Future<void>.delayed(const Duration(seconds: 3), () => result.add(3));
      final beforeUnloadManager = BeforeUnloadManager();
      beforeUnloadManager.addListener(future1Second);
      beforeUnloadManager.addListener(future2Second);
      beforeUnloadManager.addListener(future3Second);

      // act
      await beforeUnloadManager.executeBeforeUnloadListeners();

      // assert
      expect(result.length, 1);
    });

    test(
      'should finish all possible futures '
      'when more than one future fail',
    () async {
      // arrange
      List<int> result = [];
      final exception3 = Exception('error 3');
      final exception2 = Exception('error 2');
      future1Second() => Future<void>.delayed(const Duration(seconds: 1), () => result.add(1));
      future2Second() => Future<void>.delayed(const Duration(seconds: 2), () => throw exception2);
      future3Second() => Future<void>.delayed(const Duration(seconds: 3), () => throw exception3);
      final beforeUnloadManager = BeforeUnloadManager();
      beforeUnloadManager.addListener(future1Second);
      beforeUnloadManager.addListener(future2Second);
      beforeUnloadManager.addListener(future3Second);

      // act
      await beforeUnloadManager.executeBeforeUnloadListeners();

      // assert
      expect(result.length, 1);
    });
  });
}