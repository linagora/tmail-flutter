import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/mobile_container_view_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnInsertImageAction = Function(BoxConstraints constraints);

class MobileContainerView extends StatelessWidget {

  final Widget Function(BuildContext context) childBuilder;
  final RichTextController keyboardRichTextController;
  final VoidCallback onCloseViewAction;
  final VoidCallback? onAttachFileAction;
  final OnInsertImageAction? onInsertImageAction;
  final VoidCallback? onClearFocusAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  MobileContainerView({
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
    return WillPopScope(
      onWillPop: () async {
        onCloseViewAction.call();
        return true;
      },
      child: GestureDetector(
        onTap: onClearFocusAction,
        child: Scaffold(
          backgroundColor: MobileContainerViewStyle.outSideBackgroundColor,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(builder: (context, constraints) {
            return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              return KeyboardRichText(
                richTextController: keyboardRichTextController,
                keyBroadToolbar: RichTextKeyboardToolBar(
                  backgroundKeyboardToolBarColor: MobileContainerViewStyle.keyboardToolbarBackgroundColor,
                  isLandScapeMode: _responsiveUtils.isLandscapeMobile(context),
                  insertAttachment: onAttachFileAction,
                  insertImage: () => onInsertImageAction != null
                    ? onInsertImageAction!(constraints)
                    : null,
                  richTextController: keyboardRichTextController,
                  titleQuickStyleBottomSheet: AppLocalizations.of(context).titleQuickStyles,
                  titleBackgroundBottomSheet: AppLocalizations.of(context).titleBackground,
                  titleForegroundBottomSheet: AppLocalizations.of(context).titleForeground,
                  titleFormatBottomSheet: AppLocalizations.of(context).titleFormat,
                  titleBack: AppLocalizations.of(context).format,
                ),
                paddingChild: isKeyboardVisible
                  ? MobileContainerViewStyle.keyboardToolbarPadding
                  : EdgeInsets.zero,
                child: childBuilder(context),
              );
            });
          })
        ),
      )
    );
  }
}