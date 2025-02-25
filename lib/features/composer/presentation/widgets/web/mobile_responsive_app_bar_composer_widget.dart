import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/highlight_svg_icon_on_hover.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileResponsiveAppBarComposerWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool isCodeViewEnabled;
  final bool isSendButtonEnabled;
  final bool isFormattingOptionsEnabled;
  final bool hasRequestReadReceipt;
  final bool isEmailChanged;
  final CustomPopupMenuController menuMoreOptionController;
  final VoidCallback onCloseViewAction;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final VoidCallback sendMessageAction;
  final VoidCallback openRichToolbarAction;
  final VoidCallback toggleCodeViewAction;
  final VoidCallback toggleRequestReadReceiptAction;
  final VoidCallback printDraftAction;
  final VoidCallback saveToDraftsAction;
  final VoidCallback deleteComposerAction;

  const MobileResponsiveAppBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.isCodeViewEnabled,
    required this.isFormattingOptionsEnabled,
    required this.isSendButtonEnabled,
    required this.hasRequestReadReceipt,
    required this.isEmailChanged,
    required this.menuMoreOptionController,
    required this.openRichToolbarAction,
    required this.onCloseViewAction,
    required this.attachFileAction,
    required this.insertImageAction,
    required this.sendMessageAction,
    required this.toggleCodeViewAction,
    required this.toggleRequestReadReceiptAction,
    required this.printDraftAction,
    required this.saveToDraftsAction,
    required this.deleteComposerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MobileAppBarComposerWidgetStyle.height,
      color: MobileAppBarComposerWidgetStyle.backgroundColor,
      padding: MobileAppBarComposerWidgetStyle.padding,
      child: Row(
        children: [
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icCancel,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).saveAndClose,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            onTapActionCallback: onCloseViewAction
          ),
          const Spacer(),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icRichToolbar,
            padding: MobileAppBarComposerWidgetStyle.richTextIconPadding,
            backgroundColor: isFormattingOptionsEnabled
              ? MobileAppBarComposerWidgetStyle.selectedBackgroundColor
              : Colors.transparent,
            iconSize: MobileAppBarComposerWidgetStyle.richTextIconSize,
            iconColor: isFormattingOptionsEnabled
              ? MobileAppBarComposerWidgetStyle.selectedIconColor
              : MobileAppBarComposerWidgetStyle.iconColor,
            tooltipMessage: AppLocalizations.of(context).formattingOptions,
            onTapActionCallback: openRichToolbarAction,
          ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icAttachFile,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            backgroundColor: Colors.transparent,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).attach_file,
            onTapActionCallback: attachFileAction,
          ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          if (!isCodeViewEnabled)
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icInsertImage,
              iconColor: MobileAppBarComposerWidgetStyle.iconColor,
              backgroundColor: Colors.transparent,
              iconSize: MobileAppBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).insertImage,
              onTapActionCallback: insertImageAction,
            ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: isSendButtonEnabled
              ? imagePaths.icSendMobile
              : imagePaths.icSendDisable,
            backgroundColor: Colors.transparent,
            padding: MobileAppBarComposerWidgetStyle.iconPadding,
            iconSize: MobileAppBarComposerWidgetStyle.sendButtonIconSize,
            tooltipMessage: AppLocalizations.of(context).send,
            onTapActionCallback: sendMessageAction,
          ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          PopupMenuOverlayWidget(
            controller: menuMoreOptionController,
            iconButton: HighlightSVGIconOnHover(
              icon: imagePaths.icMore,
              size: MobileAppBarComposerWidgetStyle.iconSize,
              iconColor: MobileAppBarComposerWidgetStyle.iconColor,
              tooltipMessage: AppLocalizations.of(context).more,
            ),
            listButtonAction: [
              PopupItemWidget(
                  iconAction: imagePaths.icStyleCodeView,
                  nameAction: AppLocalizations.of(context).embedCode,
                  styleName: MobileAppBarComposerWidgetStyle.popupItemTextStyle,
                  colorIcon: MobileAppBarComposerWidgetStyle.iconColor,
                  padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
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
                  styleName: MobileAppBarComposerWidgetStyle.popupItemTextStyle,
                  padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
                  colorIcon: MobileAppBarComposerWidgetStyle.popupItemIconColor,
                  selectedIcon: imagePaths.icFilterSelected,
                  isSelected: hasRequestReadReceipt,
                  onCallbackAction: () {
                    menuMoreOptionController.hideMenu();
                    toggleRequestReadReceiptAction();
                  },
              ),
              if (_isPrintEnabled)
                PopupItemWidget(
                  iconAction: imagePaths.icPrinter,
                  nameAction: AppLocalizations.of(context).print,
                  colorIcon: MobileAppBarComposerWidgetStyle.popupItemIconColor,
                  styleName: MobileAppBarComposerWidgetStyle.popupItemTextStyle,
                  padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
                  onCallbackAction: () {
                    menuMoreOptionController.hideMenu();
                    printDraftAction();
                  },
                ),
              PopupItemWidget(
                  iconAction: imagePaths.icSaveToDraft,
                  nameAction: AppLocalizations.of(context).saveAsDraft,
                  colorIcon: MobileAppBarComposerWidgetStyle.popupItemIconColor,
                  styleName: MobileAppBarComposerWidgetStyle.popupItemTextStyle,
                  padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
                  onCallbackAction: () {
                    menuMoreOptionController.hideMenu();
                    saveToDraftsAction();
                  },
              ),
              PopupItemWidget(
                iconAction: imagePaths.icDeleteMailbox,
                nameAction: AppLocalizations.of(context).delete,
                colorIcon: MobileAppBarComposerWidgetStyle.popupItemIconColor,
                styleName: MobileAppBarComposerWidgetStyle.popupItemTextStyle,
                padding: MobileAppBarComposerWidgetStyle.popupItemPadding,
                onCallbackAction: () {
                  menuMoreOptionController.hideMenu();
                  deleteComposerAction();
                },
              ),
            ],
            arrangeAsList: true,
            position: null,
          ),
        ],
      ),
    );
  }

  bool get _isPrintEnabled =>
      isEmailChanged && PlatformInfo.isWeb && PlatformInfo.isCanvasKit;
}