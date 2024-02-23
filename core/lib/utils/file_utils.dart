import 'dart:convert';
import 'dart:io';

import 'package:core/domain/exceptions/download_file_exception.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static const String DEFAULT_CHARSET = 'UTF-8';
  static const String TEXT_PLAIN_MIME_TYPE = 'text/plain';

  Future<String> _getInternalStorageDirPath({
    required String nameFile,
    String? folderPath,
    String? extensionFile
  }) async {
    if (!PlatformInfo.isWeb) {

      String fileDirectory = (await getApplicationDocumentsDirectory()).absolute.path;

      if (folderPath != null) {
        fileDirectory = '$fileDirectory/$folderPath';
      }

      Directory directory = Directory(fileDirectory);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      fileDirectory = '$fileDirectory/$nameFile';

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
    String? extensionFile
  }) async {
    final internalStorageDirPath = await _getInternalStorageDirPath(
      nameFile: nameFile,
      folderPath: folderPath,
      extensionFile: extensionFile
    );

    final file = File(internalStorageDirPath);
    log("FileUtils()::saveToFile: $file");

    return await file.writeAsString(content, mode: FileMode.write);
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      log("FileUtils()::deleteFile: $file");
    } else {
      log("FileUtils()::deleteFile: File does not exist");
    }
  }

  Future<String> getContentFromFile({
    required String nameFile,
    String? folderPath,
    String? extensionFile
  }) async {
    final internalStorageDirPath = await _getInternalStorageDirPath(
      nameFile: nameFile,
      folderPath: folderPath,
      extensionFile: extensionFile
    );

    final file = File(internalStorageDirPath);
    final emailContent = await file.readAsString();

    log("FileUtils()::getFromFile: $emailContent");

    return emailContent;
  }

  Future<bool> isFileExisted({
    required String nameFile,
    String? folderPath,
    String? extensionFile
  }) async {
    final internalStorageDirPath = await _getInternalStorageDirPath(
      nameFile: nameFile,
      folderPath: folderPath,
      extensionFile: extensionFile
    );

    return File(internalStorageDirPath).exists();
  }

  Future<void> removeFolder(String folderName) async {
    try {
      String folderPath = (await getApplicationDocumentsDirectory()).absolute.path;
      folderPath = '$folderPath/$folderName';
      log('FileUtils::removeFolder():folderPath: $folderPath');
      final dir = Directory(folderPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      logError('FileUtils::removeFolder():EXCEPTION: $e');
    }
  }

  Future<String> convertImageAssetToBase64(String assetImage) async {
    ByteData bytes = await rootBundle.load(assetImage);
    final buffer = bytes.buffer;
    final base64Data = base64Encode(Uint8List.view(buffer));
    return base64Data;
  }

  Future<String> getFileCharset(String filePath) async {
    try {
      final file = File(filePath);
      final decodingResult = await CharsetDetector.autoDecode(file.readAsBytesSync());
      logError('FileUtils::getFileCharset: FILE_CHARSET = ${decodingResult.charset}');
      return decodingResult.charset;
    } catch (e) {
      logError('FileUtils::getFileCharset: Exception: $e');
      return DEFAULT_CHARSET;
    }
  }
}