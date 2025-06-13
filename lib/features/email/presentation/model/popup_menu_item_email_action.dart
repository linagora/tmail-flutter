import 'package:core/presentation/resources/image_paths.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PopupMenuItemEmailAction
    extends PopupMenuItemActionRequiredIcon<EmailActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  PopupMenuItemEmailAction(
    super.action,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getIcon(imagePaths);

  @override
  String get actionName => action.getTitle(appLocalizations);
}
