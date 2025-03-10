import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/highlight_svg_icon_on_hover.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/bottom_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class BottomBarComposerWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool isCodeViewEnabled;
  final bool isEmailChanged;
  final bool isFormattingOptionsEnabled;
  final bool hasReadReceipt;
  final bool isMarkAsImportant;
  final CustomPopupMenuController menuMoreOptionController;
  final VoidCallback openRichToolbarAction;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final VoidCallback deleteComposerAction;
  final VoidCallback saveToDraftAction;
  final VoidCallback sendMessageAction;
  final VoidCallback toggleCodeViewAction;
  final VoidCallback toggleRequestReadReceiptAction;
  final VoidCallback printDraftAction;
  final VoidCallback toggleMarkAsImportantAction;

  const BottomBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.isCodeViewEnabled,
    required this.isEmailChanged,
    required this.isFormattingOptionsEnabled,
    required this.hasReadReceipt,
    required this.isMarkAsImportant,
    required this.menuMoreOptionController,
    required this.openRichToolbarAction,
    required this.attachFileAction,
    required this.insertImageAction,
    required this.deleteComposerAction,
    required this.saveToDraftAction,
    required this.sendMessageAction,
    required this.toggleCodeViewAction,
    required this.toggleRequestReadReceiptAction,
    required this.printDraftAction,
    required this.toggleMarkAsImportantAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BottomBarComposerWidgetStyle.padding,
      height: BottomBarComposerWidgetStyle.height,
      color: BottomBarComposerWidgetStyle.backgroundColor,
      child: Row(
        children: [
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icRichToolbar,
            borderRadius: BottomBarComposerWidgetStyle.iconRadius,
            padding: BottomBarComposerWidgetStyle.iconPadding,
            backgroundColor: Colors.transparent,
            iconSize: BottomBarComposerWidgetStyle.iconSize,
            iconColor: isFormattingOptionsEnabled
              ? BottomBarComposerWidgetStyle.selectedIconColor
              : BottomBarComposerWidgetStyle.iconColor,
            tooltipMessage: AppLocalizations.of(context).formattingOptions,
            onTapActionCallback: openRichToolbarAction,
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icAttachFile,
            iconColor: BottomBarComposerWidgetStyle.iconColor,
            borderRadius: BottomBarComposerWidgetStyle.iconRadius,
            backgroundColor: Colors.transparent,
            padding: BottomBarComposerWidgetStyle.iconPadding,
            iconSize: BottomBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).attach_file,
            onTapActionCallback: attachFileAction,
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          AbsorbPointer(
            absorbing: isCodeViewEnabled,
            child: TMailButtonWidget.fromIcon(
              icon: imagePaths.icInsertImage,
              iconColor: isCodeViewEnabled
                ? BottomBarComposerWidgetStyle.disabledIconColor
                : BottomBarComposerWidgetStyle.iconColor,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              backgroundColor: Colors.transparent,
              padding: BottomBarComposerWidgetStyle.iconPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).insertImage,
              onTapActionCallback: insertImageAction,
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          PopupMenuOverlayWidget(
            controller: menuMoreOptionController,
            iconButton: HighlightSVGIconOnHover(
              icon: imagePaths.icMore,
              size: BottomBarComposerWidgetStyle.iconSize,
              iconColor: BottomBarComposerWidgetStyle.iconColor,
              tooltipMessage: AppLocalizations.of(context).more,
            ),
            listButtonAction: [
              PopupItemWidget(
                iconAction: imagePaths.icMarkAsImportant,
                nameAction: AppLocalizations.of(context).markAsImportant,
                styleName: BottomBarComposerWidgetStyle.popupItemTextStyle,
                padding: BottomBarComposerWidgetStyle.popupItemPadding,
                colorIcon: BottomBarComposerWidgetStyle.iconColor,
                selectedIcon: imagePaths.icFilterSelected,
                isSelected: isMarkAsImportant,
                onCallbackAction: () {
                  menuMoreOptionController.hideMenu();
                  toggleMarkAsImportantAction();
                },
              ),
              PopupItemWidget(
                iconAction: imagePaths.icStyleCodeView,
                nameAction: AppLocalizations.of(context).embedCode,
                styleName: BottomBarComposerWidgetStyle.popupItemTextStyle,
                colorIcon: BottomBarComposerWidgetStyle.iconColor,
                padding: BottomBarComposerWidgetStyle.popupItemPadding,
                selectedIcon: imagePaths.icFilterSelected,
                isSelected: isCodeViewEnabled,
                onCallbackAction: () {
                  menuMoreOptionController.hideMenu();
                  toggleCodeViewAction();
                },
              ),
              PopupItemWidget(
                iconAction: imagePaths.icReadReceipt,
                nameAction: AppLocalizations.of(context).requestReadReceipt,
                styleName: BottomBarComposerWidgetStyle.popupItemTextStyle,
                padding: BottomBarComposerWidgetStyle.popupItemPadding,
                colorIcon: BottomBarComposerWidgetStyle.iconColor,
                selectedIcon: imagePaths.icFilterSelected,
                isSelected: hasReadReceipt,
                onCallbackAction: () {
                  menuMoreOptionController.hideMenu();
                  toggleRequestReadReceiptAction();
                },
              ),
              if (_isPrintEnabled)
                PopupItemWidget(
                  iconAction: imagePaths.icPrinter,
                  nameAction: AppLocalizations.of(context).print,
                  colorIcon: BottomBarComposerWidgetStyle.iconColor,
                  styleName: BottomBarComposerWidgetStyle.popupItemTextStyle,
                  padding: BottomBarComposerWidgetStyle.popupItemPadding,
                  onCallbackAction: () {
                    menuMoreOptionController.hideMenu();
                    printDraftAction();
                  },
                ),
            ],
            arrangeAsList: true,
            position: null,
          ),
          const Spacer(),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icDeleteMailbox,
            borderRadius: BottomBarComposerWidgetStyle.iconRadius,
            padding: BottomBarComposerWidgetStyle.iconPadding,
            iconSize: BottomBarComposerWidgetStyle.iconSize,
            iconColor: BottomBarComposerWidgetStyle.iconColor,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).delete,
            onTapActionCallback: deleteComposerAction,
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icSaveToDraft,
            borderRadius: BottomBarComposerWidgetStyle.iconRadius,
            padding: BottomBarComposerWidgetStyle.iconPadding,
            iconSize: BottomBarComposerWidgetStyle.iconSize,
            backgroundColor: Colors.transparent,
            iconColor: BottomBarComposerWidgetStyle.iconColor,
            tooltipMessage: AppLocalizations.of(context).saveAsDraft,
            onTapActionCallback: saveToDraftAction,
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.sendButtonSpace),
          TMailButtonWidget(
            text: AppLocalizations.of(context).send,
            icon: imagePaths.icSend,
            iconAlignment: TextDirection.rtl,
            padding: BottomBarComposerWidgetStyle.sendButtonPadding,
            iconSize: BottomBarComposerWidgetStyle.iconSize,
            iconSpace: BottomBarComposerWidgetStyle.sendButtonIconSpace,
            textStyle: BottomBarComposerWidgetStyle.sendButtonTextStyle,
            backgroundColor: BottomBarComposerWidgetStyle.sendButtonBackgroundColor,
            borderRadius: BottomBarComposerWidgetStyle.sendButtonRadius,
            onTapActionCallback: sendMessageAction,
          )
        ]
      ),
    );
  }

  bool get _isPrintEnabled =>
      isEmailChanged && PlatformInfo.isWeb && PlatformInfo.isCanvasKit;
}