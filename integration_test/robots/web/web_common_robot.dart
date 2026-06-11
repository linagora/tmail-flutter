import 'dart:convert';

import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';

import '../mobile/mobile_common_robot.dart';

class WebCommonRobot extends MobileCommonRobot {
  WebCommonRobot(super.$);

  @override
  Future<FileInfo> prepareTxtFile(String content) async {
    final bytes = utf8.encode(content);
    return FileInfo(fileName: 'test.txt', fileSize: bytes.length, bytes: bytes);
  }

  @override
  Future<void> selectContextMenuItemByName(String name) async {
    final item = $(PopupMenuItemActionWidget).$(name);
    await $.waitUntilVisible(item);
    await item.tap();
  }
}