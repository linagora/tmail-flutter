import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/create_new_identity_button_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/identity_list_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/identity_loading_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class IdentitiesView extends GetWidget<IdentitiesController> {

  const IdentitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = controller.responsiveUtils.isDesktop(context);

    return SettingDetailViewBuilder(
      responsiveUtils: controller.responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(
          context,
          controller.responsiveUtils,
        ),
        decoration: SettingsUtils.getBoxDecorationForContent(
          context,
          controller.responsiveUtils,
        ),
        width: double.infinity,
        padding: isDesktop
            ? const EdgeInsetsDirectional.only(
                start: 30,
                end: 30,
                top: 22,
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SettingHeaderWidget(
                      menuItem: AccountMenuItem.profiles,
                      textStyle: ThemeUtils.textStyleInter600().copyWith(
                        color: Colors.black.withOpacity(0.9),
                      ),
                      padding: const EdgeInsetsDirectional.only(end: 16),
                    ),
                  ),
                  CreateNewIdentityButtonWidget(
                    imagePaths: controller.imagePaths,
                    onCreateNewIdentityAction: () =>
                        controller.goToCreateNewIdentity(context),
                  ),
                ],
              )
            else
              const SettingExplanationWidget(
                menuItem: AccountMenuItem.profiles,
                padding: EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 16,
                ),
                isCenter: true,
              ),
            const SizedBox(height: 14),
            Obx(() => IdentityLoadingWidget(
              identityViewState: controller.identitiesViewState.value,
            )),
            Expanded(
              child: Obx(() => ListView.separated(
                shrinkWrap: true,
                itemCount: controller.listAllIdentities.length + 1,
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 24,
                ),
                itemBuilder: (context, index) {
                  if (index == controller.listAllIdentities.length) {
                    return const SizedBox.shrink();
                  }

                  final identity = controller.listAllIdentities[index];
                  final isSelected = identity == controller.identitySelected.value;
                  return Obx(() => IdentityListTileBuilder(
                    imagePaths: controller.imagePaths,
                    identity: controller.listAllIdentities[index],
                    isSelected: isSelected,
                    mapIdentitySignatures: controller.mapIdentitySignatures,
                    signatureViewState: controller.signatureViewState.value,
                    isDesktop: isDesktop,
                    onEditIdentityAction: (identitySelected) =>
                        controller.goToEditIdentity(context, identitySelected),
                    onDeleteIdentityAction: (identitySelected) =>
                      controller.openConfirmationDialogDeleteIdentityAction(
                        context,
                        identitySelected,
                      ),
                  ));
                },
                separatorBuilder: (_, index) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.black.withOpacity(.08)),
                  ),
              )),
            ),
          ]
        ),
      )
    );
  }
}