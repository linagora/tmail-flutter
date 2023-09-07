import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarComposerWidget extends StatelessWidget {

  final bool isSendButtonEnabled;
  final VoidCallback onCloseViewAction;
  final VoidCallback sendMessageAction;
  final OnOpenContextMenuAction openContextMenuAction;

  final _imagePaths = Get.find<ImagePaths>();

  AppBarComposerWidget({
    super.key,
    required this.isSendButtonEnabled,
    required this.onCloseViewAction,
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