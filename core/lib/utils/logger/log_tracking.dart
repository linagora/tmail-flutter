import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:core/domain/exceptions/download_file_exception.dart';
import 'package:core/utils/platform_info.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LogTracking {
  static const String logFolder = 'TraceLogs';
  static const String logFileNameDatePattern = 'yyyy-MM-dd';
  static const String logMessageDatePattern = 'yyyy-MM-dd, HH:mm:ss';

  LogTracking._();

  factory LogTracking() => _instance ??= LogTracking._();

  static LogTracking? _instance;

  final Queue<String> _messagesQueue = Queue();
  bool _isScheduled = false;

  Future<void> addLog({required String message}) async {
    try {
      _messagesQueue.add(message);

      if (!_isScheduled) {
        _isScheduled = true;
        await _executeTraceLog();
      }
    } catch (_) {
      _messagesQueue.remove(message);
      _isScheduled = false;
    }
  }

  Future _executeTraceLog() async {
    while (true) {
      try {
        if (_messagesQueue.isEmpty) {
          _isScheduled = false;
          return;
        }

        final message = _messagesQueue.removeFirst();
        await saveLog(message: message);
      } catch (_) {}
    }
  }

  Future<void> saveLog({required String message}) async {
    try {
      final currentDate = DateTime.timestamp();

      final logFileName = generateLogFileName(currentDate: currentDate);

      final messageSanitized = sanitizeMessage(
        message: message,
        currentDate: currentDate,
      );

      await saveToFile(
        nameFile: logFileName,
        folderPath: logFolder,
        content: messageSanitized,
      );
    } catch (_) {}
  }

  String sanitizeMessage({
    required String message,
    required DateTime currentDate,
  }) {
    final dateFormat = getDateFormatAsString(
      pattern: logMessageDatePattern,
      currentDate: currentDate,
    );

    return '($dateFormat): $message \n';
  }

  String getDateFormatAsString({
    required String pattern,
    required DateTime currentDate,
  }) {
    final dateFormat = DateFormat(pattern);
    return dateFormat.format(currentDate);
  }

  String generateLogFileName({required DateTime currentDate}) {
    final dateFormat = getDateFormatAsString(
      pattern: logFileNameDatePattern,
      currentDate: currentDate,
    );

    return '${dateFormat}_log';
  }

  Future<String> _getInternalStorageDirPath({
    String? nameFile,
    String? folderPath,
    String? extensionFile,
  }) async {
    if (PlatformInfo.isMobile) {
      String fileDirectory =
          (await getApplicationDocumentsDirectory()).absolute.path;

      if (folderPath != null) {
        fileDirectory = '$fileDirectory/$folderPath';
      }

      Directory directory = Directory(fileDirectory);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (nameFile != null) {
        fileDirectory = '$fileDirectory/$nameFile';
      }

      if (extensionFile != null) {
        fileDirectory = '$fileDirectory.$extensionFile';
      }

      return fileDirectory;
    } else {
      throw DeviceNotSupportedException();
    }
  }

  Future<File> saveToFile({
    required String nameFile,
    required String content,
    String? folderPath,
    String? extensionFile,
    FileMode fileMode = FileMode.append,
  }) async {
    final internalStorageDirPath = await _getInternalStorageDirPath(
      nameFile: nameFile,
      folderPath: folderPath,
      extensionFile: extensionFile,
    );

    final file = File(internalStorageDirPath);

    return await file.writeAsString(content, mode: fileMode);
  }
}
