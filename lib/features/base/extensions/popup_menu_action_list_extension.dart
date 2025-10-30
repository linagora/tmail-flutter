import 'package:core/presentation/extensions/iterable_extension.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';

extension PopupMenuActionListExtension on List<PopupMenuItemAction> {
  Map<int, List<PopupMenuItemAction>> groupByCategory() {
    return groupBy<int>((action) => action.category, sortKeys: true);
  }
}
