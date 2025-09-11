import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rich_text_composer/views/keyboard_rich_text.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/pop_back_barrier_widget.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_bottom_view.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_title_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorFormDesktopBuilder extends StatelessWidget {
  final IdentityCreatorController controller;
  final Widget formView;
  final bool enableRichTextKeyboard;

  const IdentityCreatorFormDesktopBuilder({
    super.key,
    required this.controller,
    required this.formView,
    this.enableRichTextKeyboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    Widget bodyWidget = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 2,
          ),
        ],
      ),
      width: min(
        controller.responsiveUtils.getSizeScreenWidth(context) - 48,
        784,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final actionType = controller.actionType.value;
                return IdentityCreatorFormTitleWidget(
                  title: actionType.getTitle(appLocalizations),
                );
              }),
              Flexible(child: formView),
              const SizedBox(height: 24),
              IdentityCreatorFormBottomView(controller: controller),
            ],
          ),
          DefaultCloseButtonWidget(
            iconClose: controller.imagePaths.icCloseDialog,
            onTapActionCallback: () => controller.closeView(context),
          ),
        ],
      ),
    );

    if (enableRichTextKeyboard) {
      final richTextController = controller
          .richTextMobileTabletController
          !.richTextController;

      bodyWidget = KeyboardRichText(
        keyBroadToolbar: RichTextKeyboardToolBar(
          rootContext: context,
          titleBack: appLocalizations.titleFormat,
          backgroundKeyboardToolBarColor: PlatformInfo.isIOS
              ? AppColor.colorBackgroundKeyboard
              : AppColor.colorBackgroundKeyboardAndroid,
          richTextController: richTextController,
          quickStyleLabel: appLocalizations.titleQuickStyles,
          backgroundLabel: appLocalizations.titleBackground,
          foregroundLabel: appLocalizations.titleForeground,
          formatLabel: appLocalizations.titleFormat,
          insertImage: () => controller.pickImage(context),
        ),
        richTextController: richTextController,
        child: bodyWidget,
      );
    }

    if (PlatformInfo.isMobile) {
      bodyWidget = SafeArea(child: bodyWidget);
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      body: PopBackBarrierWidget(
        child: Center(
          child: GestureDetector(
            onTap: () => controller.clearFocusEditor(context),
            child: bodyWidget,
          ),
        ),
      ),
    );
  }
}
