import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarComposerWidget extends StatelessWidget {

  final bool isSendButtonEnabled;
  final bool isNetworkConnectionAvailable;
  final VoidCallback onCloseViewAction;
  final VoidCallback sendMessageAction;
  final VoidCallback? attachFileAction;
  final VoidCallback? insertImageAction;
  final VoidCallback openRichToolbarAction;
  final OnOpenContextMenuAction openContextMenuAction;

  final _imagePaths = Get.find<ImagePaths>();

  AppBarComposerWidget({
    super.key,
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
            iconColor: MobileAppBarComposerWidgetStyle.iconColor,
            backgroundColor: Colors.transparent,
            iconSize: MobileAppBarComposerWidgetStyle.richTextIconSize,
            padding: MobileAppBarComposerWidgetStyle.richTextIconPadding,
            tooltipMessage: AppLocalizations.of(context).formattingOptions,
            onTapActionCallback: openRichToolbarAction,
          ),
          if (isNetworkConnectionAvailable)
            ...[
              const SizedBox(width: 4),
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icAttachFile,
                iconColor: MobileAppBarComposerWidgetStyle.iconColor,
                backgroundColor: Colors.transparent,
                iconSize: MobileAppBarComposerWidgetStyle.iconSize,
                tooltipMessage: AppLocalizations.of(context).attach_file,
                onTapActionCallback: attachFileAction,
              ),
              const SizedBox(width: 4),
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icInsertImage,
                iconColor: MobileAppBarComposerWidgetStyle.iconColor,
                backgroundColor: Colors.transparent,
                iconSize: MobileAppBarComposerWidgetStyle.iconSize,
                tooltipMessage: AppLocalizations.of(context).insertImage,
                onTapActionCallback: insertImageAction,
              ),
              const SizedBox(width: 4),
            ],
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
            onTapActionAtPositionCallback: openContextMenuAction,
          ),
        ],
      ),
    );
  }
}