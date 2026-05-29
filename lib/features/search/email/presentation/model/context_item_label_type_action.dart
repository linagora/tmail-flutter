import 'package:core/presentation/resources/image_paths.dart';
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

  @override
  String get actionName => action.safeDisplayName;

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
