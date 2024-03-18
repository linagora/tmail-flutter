import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/tablet_container_view_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_container_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TabletContainerView extends StatelessWidget {

  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;
  final RichTextController keyboardRichTextController;
  final VoidCallback onCloseViewAction;
  final VoidCallback? onAttachFileAction;
  final OnInsertImageAction? onInsertImageAction;
  final VoidCallback? onClearFocusAction;

  const TabletContainerView({
    super.key,
    required this.childBuilder,
    required this.keyboardRichTextController,
    required this.onCloseViewAction,
    this.onAttachFileAction,
    this.onInsertImageAction,
    this.onClearFocusAction,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return PopScope(
      onPopInvoked: (didPop) => !didPop ? onCloseViewAction : null,
      canPop: false,
      child: GestureDetector(
        onTap: onClearFocusAction,
        child: Scaffold(
          backgroundColor: TabletContainerViewStyle.outSideBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(builder: (context, constraints) {
              return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                return KeyboardRichText(
                  richTextController: keyboardRichTextController,
                  keyBroadToolbar: RichTextKeyboardToolBar(
                    rootContext: context,
                    backgroundKeyboardToolBarColor: TabletContainerViewStyle.keyboardToolbarBackgroundColor,
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
                  child: Container(
                    padding: isKeyboardVisible
                      ? TabletContainerViewStyle.keyboardToolbarPadding
                      : EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: Card(
                      elevation: TabletContainerViewStyle.elevation,
                      margin: TabletContainerViewStyle.getMargin(context, responsiveUtils),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(TabletContainerViewStyle.radius))
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        color: TabletContainerViewStyle.backgroundColor,
                        width: TabletContainerViewStyle.getWidth(context, responsiveUtils),
                        child: childBuilder.call(context, constraints)
                      ),
                    ),
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