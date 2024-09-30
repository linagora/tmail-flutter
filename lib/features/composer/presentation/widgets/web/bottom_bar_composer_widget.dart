import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/key_values/composer_key_values.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/bottom_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class BottomBarComposerWidget extends StatelessWidget {

  final bool isCodeViewEnabled;
  final bool isFormattingOptionsEnabled;
  final bool hasReadReceipt;
  final VoidCallback openRichToolbarAction;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final VoidCallback showCodeViewAction;
  final VoidCallback deleteComposerAction;
  final VoidCallback saveToDraftAction;
  final VoidCallback sendMessageAction;
  final VoidCallback requestReadReceiptAction;

  final _imagePaths = Get.find<ImagePaths>();

  BottomBarComposerWidget({
    super.key,
    required this.isCodeViewEnabled,
    required this.isFormattingOptionsEnabled,
    required this.hasReadReceipt,
    required this.openRichToolbarAction,
    required this.attachFileAction,
    required this.insertImageAction,
    required this.showCodeViewAction,
    required this.deleteComposerAction,
    required this.saveToDraftAction,
    required this.sendMessageAction,
    required this.requestReadReceiptAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BottomBarComposerWidgetStyle.padding,
      height: BottomBarComposerWidgetStyle.height,
      color: BottomBarComposerWidgetStyle.backgroundColor,
      child: Row(
        children: [
          Semantics(
            container: true,
            identifier: ComposerKeyValues.openTextFormattingMenuButton,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icRichToolbar,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              padding: BottomBarComposerWidgetStyle.richTextIconPadding,
              backgroundColor: isFormattingOptionsEnabled
                ? BottomBarComposerWidgetStyle.selectedBackgroundColor
                : Colors.transparent,
              iconSize: BottomBarComposerWidgetStyle.richTextIconSize,
              iconColor: isFormattingOptionsEnabled
                ? BottomBarComposerWidgetStyle.selectedIconColor
                : BottomBarComposerWidgetStyle.iconColor,
              tooltipMessage: AppLocalizations.of(context).formattingOptions,
              onTapActionCallback: openRichToolbarAction,
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          Semantics(
            container: true,
            identifier: ComposerKeyValues.pickAttachmentButton,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icAttachFile,
              iconColor: BottomBarComposerWidgetStyle.iconColor,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              backgroundColor: Colors.transparent,
              padding: BottomBarComposerWidgetStyle.iconPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).attach_file,
              onTapActionCallback: attachFileAction,
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          AbsorbPointer(
            absorbing: isCodeViewEnabled,
            child: Semantics(
              container: true,
              identifier: ComposerKeyValues.pickInlineImageButton,
              child: TMailButtonWidget.fromIcon(
                icon: _imagePaths.icInsertImage,
                iconColor: BottomBarComposerWidgetStyle.iconColor,
                borderRadius: BottomBarComposerWidgetStyle.iconRadius,
                backgroundColor: Colors.transparent,
                padding: BottomBarComposerWidgetStyle.iconPadding,
                iconSize: BottomBarComposerWidgetStyle.iconSize,
                tooltipMessage: AppLocalizations.of(context).insertImage,
                onTapActionCallback: insertImageAction,
              ),
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          Semantics(
            container: true,
            identifier: ComposerKeyValues.toggleCodeViewButton,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icStyleCodeView,
              iconColor: isCodeViewEnabled
                ? BottomBarComposerWidgetStyle.selectedIconColor
                : BottomBarComposerWidgetStyle.iconColor,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              backgroundColor: isCodeViewEnabled
                ? BottomBarComposerWidgetStyle.selectedBackgroundColor
                : Colors.transparent,
              padding: BottomBarComposerWidgetStyle.iconPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).embedCode,
              onTapActionCallback: showCodeViewAction,
            ),
          ),
          const Spacer(),
          Semantics(
            container: true,
            identifier: ComposerKeyValues.deleteComposedEmailButton,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icDeleteMailbox,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              padding: BottomBarComposerWidgetStyle.iconPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).delete,
              onTapActionCallback: deleteComposerAction,
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          Semantics(
            container: true,
            identifier: ComposerKeyValues.toggleReadRecipientsButton,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icReadReceipt,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              padding: BottomBarComposerWidgetStyle.iconPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              iconColor: hasReadReceipt
                ? BottomBarComposerWidgetStyle.selectedIconColor
                : BottomBarComposerWidgetStyle.iconColor,
              tooltipMessage: hasReadReceipt
                ? AppLocalizations.of(context).turnOffRequestReadReceipt
                : AppLocalizations.of(context).turnOnRequestReadReceipt,
              onTapActionCallback: requestReadReceiptAction,
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.space),
          Semantics(
            container: true,
            identifier: ComposerKeyValues.saveAsDraftButton,
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icSaveToDraft,
              borderRadius: BottomBarComposerWidgetStyle.iconRadius,
              padding: BottomBarComposerWidgetStyle.iconPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              tooltipMessage: AppLocalizations.of(context).saveAsDraft,
              onTapActionCallback: saveToDraftAction,
            ),
          ),
          const SizedBox(width: BottomBarComposerWidgetStyle.sendButtonSpace),
          Semantics(
            identifier: ComposerKeyValues.composerSendButton,
            child: TMailButtonWidget(
              text: AppLocalizations.of(context).send,
              icon: _imagePaths.icSend,
              iconAlignment: TextDirection.rtl,
              padding: BottomBarComposerWidgetStyle.sendButtonPadding,
              iconSize: BottomBarComposerWidgetStyle.iconSize,
              iconSpace: BottomBarComposerWidgetStyle.sendButtonIconSpace,
              textStyle: BottomBarComposerWidgetStyle.sendButtonTextStyle,
              backgroundColor: BottomBarComposerWidgetStyle.sendButtonBackgroundColor,
              borderRadius: BottomBarComposerWidgetStyle.sendButtonRadius,
              onTapActionCallback: sendMessageAction,
            ),
          )
        ]
      ),
    );
  }
}