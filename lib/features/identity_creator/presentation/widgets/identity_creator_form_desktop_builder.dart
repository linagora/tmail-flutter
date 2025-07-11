import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_close_button_widget.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_bottom_view.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_title_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorFormDesktopBuilder extends StatelessWidget {
  final IdentityCreatorController controller;
  final Widget formView;

  const IdentityCreatorFormDesktopBuilder({
    super.key,
    required this.controller,
    required this.formView,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: GestureDetector(
        onTap: () => controller.clearFocusEditor(context),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
          ),
        ),
      ),
    );
  }
}
