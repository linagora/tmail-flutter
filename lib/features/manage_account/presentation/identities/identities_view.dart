import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/list/no_stretch_scroll_behavior.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_default_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/change_identity_as_default_extension.dart';
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
              ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SettingHeaderWidget(
                        menuItem: AccountMenuItem.profiles,
                        textStyle: ThemeUtils.textStyleInter600().copyWith(
                          color: Colors.black.withValues(alpha: 0.9),
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
                ),
                const SizedBox(height: 14),
              ]
            else
              ...[
                const SettingExplanationWidget(
                  menuItem: AccountMenuItem.profiles,
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
                  isCenter: true,
                  textAlign: TextAlign.center,
                ),
                Center(
                  child: CreateNewIdentityButtonWidget(
                    imagePaths: controller.imagePaths,
                    margin: const EdgeInsets.only(top: 24, bottom: 16),
                    onCreateNewIdentityAction: () =>
                        controller.goToCreateNewIdentity(context),
                  ),
                ),
              ],
            Obx(() => IdentityLoadingWidget(
              identityViewState: controller.identitiesViewState.value,
            )),
            Expanded(
              child: Obx(() {
                final identities = controller.listAllIdentities;
                final isDefaultIdentitySupported = controller.isDefaultIdentitySupported;
                final identitySelected = controller.identitySelected.value;

                final Widget listView = ListView.separated(
                  shrinkWrap: true,
                  itemCount: identities.length + 1,
                  controller: controller.listIdentityScrollController,
                  padding: EdgeInsetsDirectional.only(
                    start: isDefaultIdentitySupported ? 12 : 24,
                    end: 24,
                    bottom: 24,
                  ),
                  itemBuilder: (context, index) {
                    if (index == identities.length) {
                      return const SizedBox.shrink();
                    }

                    final identity = identities[index];
                    final isSelected = identity == identitySelected;

                    return Obx(() {
                      final loadingState = controller.viewState.value
                          .foldSuccessWithResult<EditDefaultIdentityLoading>();

                      bool isItemLoading =
                          loadingState is EditDefaultIdentityLoading &&
                              loadingState.isSetAsDefault;

                      return IdentityListTileBuilder(
                        imagePaths: controller.imagePaths,
                        identity: identity,
                        isSelected: isSelected,
                        isDefaultIdentitySupported: isDefaultIdentitySupported,
                        mapIdentitySignatures: controller.mapIdentitySignatures,
                        signatureViewState: controller.signatureViewState.value,
                        isDesktop: isDesktop,
                        isItemLoading: isItemLoading,
                        scrollController: controller.listIdentityScrollController,
                        onEditIdentityAction: (identitySelected) =>
                            controller.goToEditIdentity(context, identitySelected),
                        onDeleteIdentityAction: (identitySelected) =>
                            controller.openConfirmationDialogDeleteIdentityAction(
                              context,
                              identitySelected,
                            ),
                        onChangeIdentityAsDefaultAction: controller.changeIdentityAsDefault,
                      );
                    });
                  },
                  separatorBuilder: (_, index) => Padding(
                    padding: isDefaultIdentitySupported
                        ? const EdgeInsets.only(top: 24, bottom: 12)
                        : const EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                );

                if (PlatformInfo.isMobile) {
                  return ScrollConfiguration(
                    behavior: NoStretchScrollBehavior(),
                    child: listView,
                  );
                } else {
                  return listView;
                }
              }),
            ),
          ]
        ),
      )
    );
  }
}