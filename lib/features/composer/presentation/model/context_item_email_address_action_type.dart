import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemEmailAddressActionType
    extends ContextMenuItemActionRequiredIcon<EmailAddressActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemEmailAddressActionType(
    super.action,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getContextMenuIcon(imagePaths);

  @override
  String get actionName => action.getContextMenuTitle(appLocalizations);
}
