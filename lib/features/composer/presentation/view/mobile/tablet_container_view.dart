import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/tablet_container_view_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnInsertImageAction = Function(BoxConstraints constraints);

class TabletContainerView extends StatelessWidget {

  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;
  final RichTextController keyboardRichTextController;
  final VoidCallback onCloseViewAction;
  final VoidCallback? onAttachFileAction;
  final OnInsertImageAction? onInsertImageAction;
  final VoidCallback? onClearFocusAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  TabletContainerView({
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
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        log('TabletContainerView::build:onPopInvoked: didPop = $didPop');
        if (!didPop) {
          onCloseViewAction.call();
        }
      },
      canPop: false,
      child: Portal(
        child: GestureDetector(
          onTap: onClearFocusAction,
          child: Scaffold(
            backgroundColor: TabletContainerViewStyle.outSideBackgroundColor,
            body: SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
                return KeyboardRichText(
                  richTextController: keyboardRichTextController,
                  keyBroadToolbar: RichTextKeyboardToolBar(
                    rootContext: context,
                    backgroundKeyboardToolBarColor: TabletContainerViewStyle.keyboardToolbarBackgroundColor,
                    insertAttachment: onAttachFileAction,
                    insertImage: onInsertImageAction != null
                        ? () => onInsertImageAction!(constraints)
                      : null,
                    richTextController: keyboardRichTextController,
                    quickStyleLabel: AppLocalizations.of(context).titleQuickStyles,
                    backgroundLabel: AppLocalizations.of(context).titleBackground,
                    foregroundLabel: AppLocalizations.of(context).titleForeground,
                    formatLabel: AppLocalizations.of(context).titleFormat,
                    titleBack: AppLocalizations.of(context).format,
                  ),
                  child: Center(
                    child: Card(
                      elevation: TabletContainerViewStyle.elevation,
                      margin: TabletContainerViewStyle.getMargin(context, _responsiveUtils),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(TabletContainerViewStyle.radius))
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        color: TabletContainerViewStyle.backgroundColor,
                        width: TabletContainerViewStyle.getWidth(context, _responsiveUtils),
                        child: childBuilder.call(context, constraints)
                      ),
                    ),
                  ),
                );
              }),
            )
          ),
        ),
      )
    );
  }
}