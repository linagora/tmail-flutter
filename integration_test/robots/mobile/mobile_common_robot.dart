import 'dart:io';

import 'package:model/upload/file_info.dart';
import 'package:path_provider/path_provider.dart';

import '../../extensions/patrol_file_extensions.dart';
import '../abstract/abstract_common_robot.dart';

class MobileCommonRobot extends AbstractCommonRobot {
  @override
  Future<FileInfo> prepareTxtFile(String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test.txt');
    await file.writeAsString(content);
    return file.toFileInfo();
  }
}