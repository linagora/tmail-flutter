import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemSortOrderTypeAction
    extends ContextMenuItemActionRequiredSelectedIcon<EmailSortOrderType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemSortOrderTypeAction(
    super.action,
    super.selectedAction,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionName => action.getTitleByAppLocalizations(appLocalizations);

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
