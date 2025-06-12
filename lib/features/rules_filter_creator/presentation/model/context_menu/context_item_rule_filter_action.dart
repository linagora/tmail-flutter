import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemRuleFilterAction
    extends ContextMenuItemActionRequiredSelectedIcon<EmailRuleFilterAction> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemRuleFilterAction(
    super.action,
    super.selectedAction,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionName => action.getTitle(appLocalizations);

  @override
  String get selectedIcon => imagePaths.icFilterSelected;
}
