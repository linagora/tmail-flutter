import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_app_bar_widget.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_creator_form_bottom_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorFormMobileBuilder extends StatelessWidget {
  final IdentityCreatorController controller;
  final Widget formView;

  const IdentityCreatorFormMobileBuilder({
    super.key,
    required this.controller,
    required this.formView,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => controller.clearFocusEditor(context),
        child: SafeArea(
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final actionType = controller.actionType.value;
                  return DefaultAppBarWidget(
                    title: actionType.getTitle(appLocalizations),
                    imagePaths: controller.imagePaths,
                    responsiveUtils: controller.responsiveUtils,
                    onBackAction: () => controller.closeView(context),
                  );
                }),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: formView),
                        IdentityCreatorFormBottomView(controller: controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
