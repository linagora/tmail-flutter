import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PopupMenuItemEmailAddressActionType
    extends PopupMenuItemActionRequiredIcon<EmailAddressActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  PopupMenuItemEmailAddressActionType(
    super.action,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getContextMenuIcon(imagePaths);

  @override
  String get actionName => action.getContextMenuTitle(appLocalizations);
}
