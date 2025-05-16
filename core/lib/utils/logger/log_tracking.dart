import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:core/domain/exceptions/download_file_exception.dart';
import 'package:core/domain/exceptions/file_exception.dart';
import 'package:core/utils/logger/trace_log.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
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

  Future<TraceLog> getTraceLog() async {
    final folderPath = await _getInternalStorageDirPath(folderPath: logFolder);
    final directory = Directory(folderPath);
    if (directory.existsSync()) {
      final directoryInfo = await getDirInfo(directory);
      return TraceLog(
        path: folderPath,
        size: directoryInfo.$1,
        listFilePaths: directoryInfo.$2,
      );
    } else {
      throw Exception('Trace folder not exist');
    }
  }

  Future<(int, List<String>)> getDirInfo(Directory dir) async {
    var files = await dir.list(recursive: true).toList();
    var dirSize = files.fold(0, (int sum, file) => sum + file.statSync().size);
    var listPath = files.map((file) => file.path).toList();
    return (dirSize, listPath);
  }

  static Future<String> getExternalDocumentPath({String? folderPath}) async {
    Directory directory = Directory('');
    if (Platform.isAndroid) {
      if (folderPath?.isNotEmpty == true) {
        directory = Directory('/storage/emulated/0/Download/$folderPath');
      } else {
        directory = Directory('/storage/emulated/0/Download');
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
      if (folderPath?.isNotEmpty == true) {
        directory = Directory('${directory.absolute.path}/$folderPath');
      }
    }

    final exPath = directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> copyInternalFilesToDownloadExternal(List<String> listFilePaths) async {
    final externalPath = await getExternalDocumentPath();

    List<String> externalListPaths = [];
    for (var filePath in listFilePaths) {
      final file = File(filePath);
      final fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
      final externalFile = File('$externalPath/$fileName');
      await externalFile.writeAsBytes(file.readAsBytesSync());
      externalListPaths.add(externalFile.path);
    }

    if (externalListPaths.isNotEmpty) {
      return externalPath;
    } else {
      throw NotFoundFileInFolderException();
    }
  }

  Future<String> exportTraceLog(TraceLog traceLog) async {
    if (PlatformInfo.isIOS) {
      final savePath = getExternalDocumentPath(folderPath: logFolder);
      return savePath;
    } else {
      final savePath = await compute(
        copyInternalFilesToDownloadExternal,
        traceLog.listFilePaths,
      );
      return savePath;
    }
  }
}