import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenContextMenuAction = Function(RelativeRect position);

class AppBarComposerWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool isSendButtonEnabled;
  final bool isNetworkConnectionAvailable;
  final VoidCallback onCloseViewAction;
  final VoidCallback sendMessageAction;
  final VoidCallback? attachFileAction;
  final VoidCallback? insertImageAction;
  final VoidCallback openRichToolbarAction;
  final OnOpenContextMenuAction openContextMenuAction;

  const AppBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.isSendButtonEnabled,
    required this.onCloseViewAction,
    required this.sendMessageAction,
    required this.openContextMenuAction,
    required this.openRichToolbarAction,
    this.isNetworkConnectionAvailable = false,
    this.attachFileAction,
    this.insertImageAction,
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
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            backgroundColor: Colors.transparent,
            iconSize: MobileAppBarComposerWidgetStyle.richTextIconSize,
            padding: MobileAppBarComposerWidgetStyle.richTextIconPadding,
            tooltipMessage: AppLocalizations.of(context).formattingOptions,
            onTapActionCallback: openRichToolbarAction,
          ),
          if (isNetworkConnectionAvailable)
            ...[
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
              TMailButtonWidget.fromIcon(
                icon: imagePaths.icInsertImage,
                iconColor: MobileAppBarComposerWidgetStyle.iconColor,
                backgroundColor: Colors.transparent,
                iconSize: MobileAppBarComposerWidgetStyle.iconSize,
                tooltipMessage: AppLocalizations.of(context).insertImage,
                onTapActionCallback: insertImageAction,
              ),
              const SizedBox(width: MobileAppBarComposerWidgetStyle.space),
            ],
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
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icMore,
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            backgroundColor: Colors.transparent,
            padding: MobileAppBarComposerWidgetStyle.iconPadding,
            iconSize: MobileAppBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).more,
            onTapActionAtPositionCallback: openContextMenuAction,
          ),
        ],
      ),
    );
  }
}