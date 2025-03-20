@TestOn('vm')

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/log_tracking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'file_utils_test.dart';

void main() {
  final fileUtils =  FileUtils();

  group('log_tracking_test', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
    });

    test('app_logger::log:test', () async {
      final fileName = LogTracking().generateLogFileName(currentDate: DateTime.timestamp());

      await fileUtils.deleteFileByFolderName(
        nameFile: fileName,
        folderPath: LogTracking.logFolder);

      await Future.wait([
        log('hello 1'),
        log('hello 2'),
        log('hello 3'),
        log('hello 4'),
      ]);

      await log('hello 9');

      await Future.wait([
        log('hello 5'),
        log('hello 6'),
        log('hello 7'),
        log('hello 8'),
      ]);

      final content = await fileUtils.getContentFromFile(
        nameFile: fileName,
        folderPath: LogTracking.logFolder);

      final listMessage= content
        .split('\n')
        .map((message) => message.trim())
        .where((message) => message.isNotEmpty);

      expect(listMessage.length, equals(9));
      expect(listMessage.first, contains('hello 1'));
      expect(listMessage.last, contains('hello 8'));
    });

    test('app_logger::logError:test', () async {
      final fileName = LogTracking().generateLogFileName(currentDate: DateTime.timestamp());

      await fileUtils.deleteFileByFolderName(
        nameFile: fileName,
        folderPath: LogTracking.logFolder);

      await Future.wait([
        logError('Error 1'),
        logError('Error 2'),
        logError('Error 3'),
        logError('Error 4'),
      ]);

      await logError('Error 5');

      final content = await fileUtils.getContentFromFile(
        nameFile: fileName,
        folderPath: LogTracking.logFolder);

      final listMessage= content
        .split('\n')
        .map((message) => message.trim())
        .where((message) => message.isNotEmpty);

      expect(listMessage.length, equals(5));
      expect(listMessage.first, contains('Error 1'));
      expect(listMessage.last, contains('Error 5'));
    });
  });
}