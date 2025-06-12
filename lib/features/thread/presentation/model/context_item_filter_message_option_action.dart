import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemFilterMessageOptionAction
    extends ContextMenuItemActionRequiredFull<FilterMessageOption> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemFilterMessageOptionAction(
    super.action,
    super.selectedAction,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getContextMenuIcon(imagePaths);

  @override
  String get actionName => action.getName(appLocalizations);

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
