import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/animation.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';

class PopupMenuItemLabelTypeAction
    extends PopupMenuItemActionRequiredSelectedIcon<Label> {
  final ImagePaths imagePaths;

  PopupMenuItemLabelTypeAction(
    super.action,
    super.selectedAction,
    this.imagePaths,
  );

  bool get isSelected => action.id == selectedAction?.id;

  @override
  String get actionName => action.safeDisplayName;

  @override
  String get selectedIcon => isSelected
      ? imagePaths.icCheckboxSelected
      : imagePaths.icCheckboxUnselected;

  @override
  Color get selectedIconColor => isSelected
      ? AppColor.primaryMain
      : AppColor.gray424244.withValues(alpha: 0.72);

  @override
  bool get isArrangeRTL => false;
}
