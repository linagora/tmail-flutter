import 'dart:developer';
import 'dart:io';
import 'package:core/domain/exceptions/download_file_exception.dart';
import 'package:core/utils/build_utils.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {

  static Future<String> _getInternalStorageDirPath(
    String nameFile,
    {
      String? folderPath,
      String? extensionFile
    }
  ) async {
    if (!BuildUtils.isWeb) {
      String fileDirectory = (await getApplicationDocumentsDirectory()).absolute.path;


      if (folderPath != null) {
        fileDirectory = '$fileDirectory.$folderPath';
      }

      fileDirectory = '$fileDirectory.$nameFile';

      if (extensionFile != null) {
        fileDirectory = '$fileDirectory.$extensionFile';
      }
      return fileDirectory;
    } else {
      throw DeviceNotSupportedException();
    }
  }

  static Future<File> saveToFile(
    String nameFile,
    String content,
    {
      String? folderPath,
      String? extensionFile
    }) async {

    final internalStorageDirPath = await _getInternalStorageDirPath(
      nameFile,
      folderPath: folderPath,
      extensionFile: extensionFile
    );

    final file = File('$internalStorageDirPath.txt');
    log("FileUtils()::saveToFile: $file");

    return await file.writeAsString(content, mode: FileMode.append);
  }

  static Future<String> getFromFile(
    String nameFile,
    {
      String? folderPath,
      String? extensionFile
    }
  ) async {
    String emailContent = '';

    final internalStorageDirPath = await _getInternalStorageDirPath(
      nameFile,
      folderPath: folderPath,
      extensionFile: extensionFile
    );

    final file = File('$internalStorageDirPath.txt');
    emailContent = await file.readAsString();

    log("FileUtils()::getFromFile: $emailContent");

    return emailContent;
  }
}