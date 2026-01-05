import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/animation.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

class ContextItemLabelTypeAction
    extends ContextMenuItemActionRequiredSelectedIcon<Label> {
  final ImagePaths imagePaths;

  ContextItemLabelTypeAction(
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
