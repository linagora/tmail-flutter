import 'dart:io';

import 'package:model/upload/file_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_item.dart';

import '../../extensions/patrol_file_extensions.dart';
import '../abstract/abstract_common_robot.dart';

class MobileCommonRobot extends AbstractCommonRobot {
  MobileCommonRobot(super.$);

  @override
  Future<FileInfo> prepareTxtFile(String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test.txt');
    await file.writeAsString(content);
    return file.toFileInfo();
  }
  
  @override
  Future<void> selectContextMenuItemByName(String name) async {
    final item = $(ContextMenuDialogItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.tap();
  }
}