import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/highlight_svg_icon_on_hover.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MoreOptionsMenuComposerWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final CustomPopupMenuController menuController;
  // Actions that did not fit in the app bar, shown above the fixed options.
  final List<Widget> overflowMenuItems;
  final bool isCodeViewEnabled;
  final bool hasRequestReadReceipt;
  final bool isMarkAsImportant;
  final bool isEmailChanged;
  final VoidCallback toggleCodeViewAction;
  final VoidCallback toggleRequestReadReceiptAction;
  final VoidCallback printDraftAction;
  final VoidCallback saveToDraftsAction;
  final VoidCallback saveToTemplateAction;
  final VoidCallback deleteComposerAction;
  final VoidCallback toggleMarkAsImportantAction;

  const MoreOptionsMenuComposerWidget({
    super.key,
    required this.imagePaths,
    required this.menuController,
    required this.overflowMenuItems,
    required this.isCodeViewEnabled,
    required this.hasRequestReadReceipt,
    required this.isMarkAsImportant,
    required this.isEmailChanged,
    required this.toggleCodeViewAction,
    required this.toggleRequestReadReceiptAction,
    required this.printDraftAction,
    required this.saveToDraftsAction,
    required this.saveToTemplateAction,
    required this.deleteComposerAction,
    required this.toggleMarkAsImportantAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return PopupMenuOverlayWidget(
      controller: menuController,
      iconButton: HighlightSVGIconOnHover(
        icon: imagePaths.icMore,
        size: MobileAppBarComposerWidgetStyle.iconSize,
        iconColor: MobileAppBarComposerWidgetStyle.iconColor,
        tooltipMessage: appLocalizations.more,
      ),
      listButtonAction: [
        ...overflowMenuItems,
        if (overflowMenuItems.isNotEmpty) const Divider(height: 1),
        _item(
          icon: imagePaths.icMarkAsImportant,
          label: appLocalizations.markAsImportant,
          isSelected: isMarkAsImportant,
          onTap: toggleMarkAsImportantAction,
        ),
        _item(
          icon: imagePaths.icStyleCodeView,
          label: appLocalizations.embedCode,
          isSelected: isCodeViewEnabled,
          onTap: toggleCodeViewAction,
        ),
        _item(
          icon: imagePaths.icReadReceipt,
          label: appLocalizations.requestReadReceipt,
          isSelected: hasRequestReadReceipt,
          onTap: toggleRequestReadReceiptAction,
        ),
        if (_isPrintEnabled)
          _item(
            icon: imagePaths.icPrinter,
            label: appLocalizations.print,
            onTap: printDraftAction,
          ),
        _item(
          key: const Key(UiKeys.saveDraftPopupItem),
          icon: imagePaths.icSaveToDraft,
          label: appLocalizations.saveAsDraft,
          onTap: saveToDraftsAction,
        ),
        _item(
          key: const Key(UiKeys.saveTemplatePopupItem),
          icon: imagePaths.icSaveToDraft,
          label: appLocalizations.saveAsTemplate,
          onTap: saveToTemplateAction,
        ),
        _item(
          icon: imagePaths.icDeleteMailbox,
          label: appLocalizations.delete,
          color: AppColor.redFF3347,
          onTap: deleteComposerAction,
        ),
      ],
      arrangeAsList: true,
      position: null,
    );
  }

  Widget _item({
    Key? key,
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool? isSelected,
    Color color = MobileAppBarComposerWidgetStyle.popupItemIconColor,
  }) {
    return PopupItemWidget(
      key: key,
      iconAction: icon,
      nameAction: label,
      colorIcon: color,
      styleName: color == AppColor.redFF3347
          ? MobileAppBarComposerWidgetStyle.popupItemTextStyle.copyWith(color: color)
          : MobileAppBarComposerWidgetStyle.popupItemTextStyle,
      padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
      selectedIcon: isSelected == null ? null : imagePaths.icFilterSelected,
      isSelected: isSelected,
      onCallbackAction: () {
        menuController.hideMenu();
        onTap();
      },
    );
  }

  bool get _isPrintEnabled =>
      isEmailChanged && PlatformInfo.isWeb && PlatformInfo.isCanvasKit;
}
