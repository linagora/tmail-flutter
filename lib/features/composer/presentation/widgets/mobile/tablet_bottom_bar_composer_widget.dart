import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/tablet_bottom_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TabletBottomBarComposerWidget extends StatelessWidget {

  final VoidCallback deleteComposerAction;
  final VoidCallback saveToDraftAction;
  final VoidCallback sendMessageAction;

  final _imagePaths = Get.find<ImagePaths>();

  TabletBottomBarComposerWidget({
    super.key,
    required this.deleteComposerAction,
    required this.saveToDraftAction,
    required this.sendMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: TabletBottomBarComposerWidgetStyle.padding,
      color: TabletBottomBarComposerWidgetStyle.backgroundColor,
      child: Row(
        children: [
          const Spacer(),
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icDeleteMailbox,
            borderRadius: TabletBottomBarComposerWidgetStyle.iconRadius,
            padding: TabletBottomBarComposerWidgetStyle.iconPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).delete,
            onTapActionCallback: deleteComposerAction,
          ),
          const SizedBox(width: TabletBottomBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icSaveToDraft,
            borderRadius: TabletBottomBarComposerWidgetStyle.iconRadius,
            padding: TabletBottomBarComposerWidgetStyle.iconPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).save_to_drafts,
            onTapActionCallback: saveToDraftAction,
          ),
          const SizedBox(width: TabletBottomBarComposerWidgetStyle.sendButtonSpace),
          TMailButtonWidget(
            text: AppLocalizations.of(context).send,
            icon: _imagePaths.icSend,
            iconAlignment: TextDirection.rtl,
            padding: TabletBottomBarComposerWidgetStyle.sendButtonPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            iconSpace: TabletBottomBarComposerWidgetStyle.sendButtonIconSpace,
            textStyle: TabletBottomBarComposerWidgetStyle.sendButtonTextStyle,
            backgroundColor: TabletBottomBarComposerWidgetStyle.sendButtonBackgroundColor,
            borderRadius: TabletBottomBarComposerWidgetStyle.sendButtonRadius,
            onTapActionCallback: sendMessageAction,
          )
        ]
      ),
    );
  }
}