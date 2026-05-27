import 'dart:convert';

import 'package:model/upload/file_info.dart';

import '../mobile/mobile_common_robot.dart';

class WebCommonRobot extends MobileCommonRobot {
  @override
  Future<FileInfo> prepareTxtFile(String content) async {
    final bytes = utf8.encode(content);
    return FileInfo(fileName: 'test.txt', fileSize: bytes.length, bytes: bytes);
  }
}