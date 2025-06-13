import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PopupMenuItemSortOrderTypeAction
    extends PopupMenuItemActionRequiredSelectedIcon<EmailSortOrderType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  PopupMenuItemSortOrderTypeAction(
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
