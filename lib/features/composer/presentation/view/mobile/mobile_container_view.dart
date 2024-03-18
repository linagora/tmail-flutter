import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:rich_text_composer/rich_text_composer.dart' as rich_composer;
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/mobile_container_view_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnInsertImageAction = Function(BoxConstraints constraints);

class MobileContainerView extends StatelessWidget {

  final Widget Function(BuildContext context) childBuilder;
  final rich_composer.RichTextController keyboardRichTextController;
  final VoidCallback onCloseViewAction;
  final VoidCallback? onAttachFileAction;
  final OnInsertImageAction? onInsertImageAction;
  final VoidCallback? onClearFocusAction;
  final Color? backgroundColor;

  const MobileContainerView({
    super.key,
    required this.childBuilder,
    required this.keyboardRichTextController,
    required this.onCloseViewAction,
    this.onAttachFileAction,
    this.onInsertImageAction,
    this.onClearFocusAction,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) => !didPop ? onCloseViewAction : null,
      canPop: false,
      child: GestureDetector(
        onTap: onClearFocusAction,
        child: Scaffold(
          backgroundColor: backgroundColor ?? MobileContainerViewStyle.outSideBackgroundColor,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(builder: (context, constraints) {
              return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                return rich_composer.KeyboardRichText(
                  richTextController: keyboardRichTextController,
                  keyBroadToolbar: RichTextKeyboardToolBar(
                    rootContext: context,
                    backgroundKeyboardToolBarColor: MobileContainerViewStyle.keyboardToolbarBackgroundColor,
                    insertAttachment: onAttachFileAction,
                    insertImage: () => onInsertImageAction != null
                      ? onInsertImageAction!(constraints)
                      : null,
                    richTextController: keyboardRichTextController,
                    quickStyleLabel: AppLocalizations.of(context).titleQuickStyles,
                    backgroundLabel: AppLocalizations.of(context).titleBackground,
                    foregroundLabel: AppLocalizations.of(context).titleForeground,
                    formatLabel: AppLocalizations.of(context).titleFormat,
                    titleBack: AppLocalizations.of(context).format,
                  ),
                  child: Padding(
                    padding: isKeyboardVisible
                      ? MobileContainerViewStyle.keyboardToolbarPadding
                      : EdgeInsets.zero,
                    child: childBuilder(context),
                  ),
                );
              });
            }),
          )
        ),
      )
    );
  }
}