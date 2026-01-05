
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/bottom_popup/cupertino_action_sheet_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_view.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin PopupContextMenuActionMixin {
  Future<void> openContextMenuAction(
    BuildContext context,
    List<Widget> actionTiles,
  ) async {
    return await (CupertinoActionSheetBuilder(context)
          ..addTiles(actionTiles)
          ..addCancelButton(buildCancelButton(context)))
        .show();
  }

  Future<void> openBottomSheetContextMenuAction({
    required BuildContext context,
    required List<ContextMenuItemAction> itemActions,
    required OnContextMenuActionClick onContextMenuActionClick,
    Key? key,
    bool useGroupedActions = false,
    double? maxHeight,
  }) async {
    return await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? double.infinity,
      ),
      builder: (_) {
        return PointerInterceptor(
          child: Container(
            key: key,
            color: Colors.white,
            padding: const EdgeInsetsDirectional.only(bottom: 24),
            child: ContextMenuDialogView(
              actions: itemActions,
              onContextMenuActionClick: onContextMenuActionClick,
              useGroupedActions: useGroupedActions,
            ),
          ),
        );
      },
    );
  }

  Future<void> openPopupMenuAction(
    BuildContext context,
    RelativeRect position,
    List<PopupMenuEntry> popupMenuItems,
    {double? maxHeight}
  ) async {
    return await showMenu(
      context: context,
      position: position,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      menuPadding: const EdgeInsets.symmetric(vertical: 8),
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      constraints: BoxConstraints(
        maxWidth: 300,
        minWidth: 178,
        maxHeight: maxHeight ?? double.infinity,
      ),
      items: popupMenuItems,
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return MouseRegion(
      cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
      child: CupertinoActionSheetAction(
        child: Text(
          AppLocalizations.of(context).cancel,
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: AppColor.colorTextButton,
          ),
        ),
        onPressed: () => popBack(),
      ),
    );
  }
}