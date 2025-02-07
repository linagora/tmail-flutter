import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/tablet_bottom_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TabletBottomBarComposerWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool hasReadReceipt;
  final bool isMarkAsImportant;
  final VoidCallback deleteComposerAction;
  final VoidCallback saveToDraftAction;
  final VoidCallback sendMessageAction;
  final VoidCallback requestReadReceiptAction;
  final VoidCallback toggleMarkAsImportantAction;

  const TabletBottomBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.hasReadReceipt,
    required this.isMarkAsImportant,
    required this.deleteComposerAction,
    required this.saveToDraftAction,
    required this.sendMessageAction,
    required this.requestReadReceiptAction,
    required this.toggleMarkAsImportantAction,
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
            icon: imagePaths.icDeleteMailbox,
            borderRadius: TabletBottomBarComposerWidgetStyle.iconRadius,
            padding: TabletBottomBarComposerWidgetStyle.iconPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).delete,
            onTapActionCallback: deleteComposerAction,
          ),
          const SizedBox(width: TabletBottomBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icMarkAsImportant,
            borderRadius: TabletBottomBarComposerWidgetStyle.iconRadius,
            padding: TabletBottomBarComposerWidgetStyle.iconPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            iconColor: isMarkAsImportant
                ? TabletBottomBarComposerWidgetStyle.selectedIconColor
                : TabletBottomBarComposerWidgetStyle.iconColor,
            tooltipMessage: isMarkAsImportant
                ? AppLocalizations.of(context).turnOffMarkAsImportant
                : AppLocalizations.of(context).turnOnMarkAsImportant,
            onTapActionCallback: toggleMarkAsImportantAction,
          ),
          const SizedBox(width: TabletBottomBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icReadReceipt,
            borderRadius: TabletBottomBarComposerWidgetStyle.iconRadius,
            padding: TabletBottomBarComposerWidgetStyle.iconPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            iconColor: hasReadReceipt
              ? TabletBottomBarComposerWidgetStyle.selectedIconColor
              : TabletBottomBarComposerWidgetStyle.iconColor,
            tooltipMessage: hasReadReceipt
              ? AppLocalizations.of(context).turnOffRequestReadReceipt
              : AppLocalizations.of(context).turnOnRequestReadReceipt,
            onTapActionCallback: requestReadReceiptAction,
          ),
          const SizedBox(width: TabletBottomBarComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icSaveToDraft,
            borderRadius: TabletBottomBarComposerWidgetStyle.iconRadius,
            padding: TabletBottomBarComposerWidgetStyle.iconPadding,
            iconSize: TabletBottomBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).saveAsDraft,
            onTapActionCallback: saveToDraftAction,
          ),
          const SizedBox(width: TabletBottomBarComposerWidgetStyle.sendButtonSpace),
          TMailButtonWidget(
            text: AppLocalizations.of(context).send,
            icon: imagePaths.icSend,
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