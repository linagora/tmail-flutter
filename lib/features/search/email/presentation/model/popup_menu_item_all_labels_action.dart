import 'package:core/presentation/resources/image_paths.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';

class PopupMenuItemAllLabelsAction
    extends PopupMenuItemActionRequiredSelectedIcon<Label?> {
  final ImagePaths imagePaths;
  final String allLabelsName;

  PopupMenuItemAllLabelsAction(
    Label? selectedLabel,
    this.imagePaths,
    this.allLabelsName,
  ) : super(null, selectedLabel);

  @override
  String get actionName => allLabelsName;

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
