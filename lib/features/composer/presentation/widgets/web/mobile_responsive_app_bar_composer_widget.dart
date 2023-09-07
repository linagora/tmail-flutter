import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileResponsiveAppBarComposerWidget extends StatelessWidget {

  final bool isCodeViewEnabled;
  final bool isSendButtonEnabled;
  final bool isFormattingOptionsEnabled;
  final VoidCallback onCloseViewAction;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final VoidCallback sendMessageAction;
  final VoidCallback openContextMenuAction;
  final VoidCallback openRichToolbarAction;

  final _imagePaths = Get.find<ImagePaths>();

  MobileResponsiveAppBarComposerWidget({
    super.key,
    required this.isCodeViewEnabled,
    required this.isFormattingOptionsEnabled,
    required this.isSendButtonEnabled,
    required this.openRichToolbarAction,
    required this.onCloseViewAction,
    required this.attachFileAction,
    required this.insertImageAction,
    required this.sendMessageAction,
    required this.openContextMenuAction,
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
            icon: _imagePaths.icCancel,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).saveAndClose,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            padding: MobileAppBarComposerWidgetStyle.iconPadding,
            onTapActionCallback: onCloseViewAction
          ),
          const Spacer(),
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icRichToolbar,
            borderRadius: MobileAppBarComposerWidgetStyle.iconRadius,
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
            icon: _imagePaths.icAttachFile,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            borderRadius: MobileAppBarComposerWidgetStyle.iconRadius,
            backgroundColor: Colors.transparent,
            padding: MobileAppBarComposerWidgetStyle.iconPadding,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).attach_file,
            onTapActionCallback: attachFileAction,
          ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          AbsorbPointer(
            absorbing: isCodeViewEnabled,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icInsertImage,
              iconColor: MobileAppBarComposerWidgetStyle.iconColor,
              borderRadius: MobileAppBarComposerWidgetStyle.iconRadius,
              backgroundColor: Colors.transparent,
              padding: MobileAppBarComposerWidgetStyle.iconPadding,
              iconSize: MobileAppBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).insertImage,
              onTapActionCallback: insertImageAction,
            ),
          ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: isSendButtonEnabled
              ? _imagePaths.icSendMobile
              : _imagePaths.icSendDisable,
            backgroundColor: Colors.transparent,
            padding: MobileAppBarComposerWidgetStyle.iconPadding,
            iconSize: MobileAppBarComposerWidgetStyle.sendButtonIconSize,
            tooltipMessage: AppLocalizations.of(context).send,
            onTapActionCallback: sendMessageAction,
          ),
          const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icMore,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            borderRadius: MobileAppBarComposerWidgetStyle.iconRadius,
            backgroundColor: Colors.transparent,
            padding: MobileAppBarComposerWidgetStyle.iconPadding,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).more,
            onTapActionCallback: openContextMenuAction,
          ),
        ],
      ),
    );
  }
}