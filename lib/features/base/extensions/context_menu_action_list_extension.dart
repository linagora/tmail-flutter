import 'package:core/presentation/extensions/iterable_extension.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

extension ContextMenuActionListExt on List<ContextMenuItemAction> {
  Map<int, List<ContextMenuItemAction>> groupByCategory() {
    return groupBy<int>((action) => action.category, sortKeys: true);
  }
}
