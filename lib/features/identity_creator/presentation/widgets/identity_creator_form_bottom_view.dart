import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorFormBottomView extends StatelessWidget {
  final IdentityCreatorController controller;

  const IdentityCreatorFormBottomView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final isMobile = controller.responsiveUtils.isMobile(context);

    final checkboxWidget = Obx(() {
      if (controller.isDefaultIdentitySupported.isTrue) {
        return Obx(() {
          return CustomIconLabeledCheckbox(
            label: appLocalizations.setDefaultIdentity,
            svgIconPath: controller.imagePaths.icCheckboxUnselected,
            selectedSvgIconPath: controller.imagePaths.icCheckboxSelected,
            value: controller.isDefaultIdentity.value,
            semanticsLabel: 'Set default identity checkbox',
            onChanged: (_) => controller.onCheckboxChanged(),
          );
        });
      } else {
        return const SizedBox.shrink();
      }
    });

    final cancelButtonWidget = Container(
      constraints: isMobile ? null : const BoxConstraints(minWidth: 67),
      height: 48,
      child: ConfirmDialogButton(
        label: appLocalizations.cancel,
        onTapAction: () => controller.closeView(context),
      ),
    );

    final saveButtonWidget = Container(
      constraints: isMobile ? null : const BoxConstraints(minWidth: 110),
      height: 48,
      child: Obx(() {
        final viewState = controller.viewState.value;
        final actionType = controller.actionType.value;
        final isLoading = viewState.fold(
          (failure) => false,
          (success) => success is GetAllIdentitiesLoading,
        );

        if (isLoading) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColor.primaryColor,
                strokeWidth: 2.0,
              ),
            ),
          );
        } else {
          return ConfirmDialogButton(
            key: const Key('save_identity_button'),
            label: actionType.getPositiveButtonTitle(appLocalizations),
            backgroundColor: AppColor.primaryMain,
            textColor: Colors.white,
            onTapAction: () => controller.createNewIdentity(context),
          );
        }
      }),
    );

    if (isMobile) {
      return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 17,
          end: 17,
          bottom: PlatformInfo.isMobile ? 24 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            checkboxWidget,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Row(
                children: [
                  Expanded(child: cancelButtonWidget),
                  const SizedBox(width: 8),
                  Expanded(child: saveButtonWidget),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 32,
          end: 37,
          top: 12,
          bottom: 24,
        ),
        child: Row(
          children: [
            Expanded(child: checkboxWidget),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(child: cancelButtonWidget),
                  const SizedBox(width: 8),
                  Flexible(child: saveButtonWidget),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
