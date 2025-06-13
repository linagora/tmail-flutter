import 'package:core/presentation/resources/image_paths.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContextItemConditionCombinerAction
    extends ContextMenuItemActionRequiredSelectedIcon<ConditionCombiner> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  ContextItemConditionCombinerAction(
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
