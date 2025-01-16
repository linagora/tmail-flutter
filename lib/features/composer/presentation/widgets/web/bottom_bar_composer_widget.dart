import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/bottom_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/mobile_responsive_app_bar_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class BottomBarComposerWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool isCodeViewEnabled;
  final bool isPrintDraftEnabled;
  final bool isFormattingOptionsEnabled;
  final bool hasReadReceipt;
  final VoidCallback openRichToolbarAction;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final VoidCallback deleteComposerAction;
  final VoidCallback saveToDraftAction;
  final VoidCallback sendMessageAction;
  final OnOpenContextMenuAction openContextMenuAction;

  const BottomBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.isCodeViewEnabled,
    required this.isPrintDraftEnabled,
    required this.isFormattingOptionsEnabled,
    required this.hasReadReceipt,
    required this.openRichToolbarAction,
    required this.attachFileAction,
    required this.insertImageAction,
    required this.deleteComposerAction,
    required this.saveToDraftAction,
    required this.sendMessageAction,
    required this.openContextMenuAction,
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
            padding: BottomBarComposerWidgetStyle.richTextIconPadding,
            backgroundColor: Colors.transparent,
            iconSize: BottomBarComposerWidgetStyle.richTextIconSize,
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
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icMore,
            iconColor: BottomBarComposerWidgetStyle.iconColor,
            backgroundColor: Colors.transparent,
            iconSize: BottomBarComposerWidgetStyle.iconSize,
            tooltipMessage: AppLocalizations.of(context).more,
            onTapActionAtPositionCallback: openContextMenuAction,
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
}