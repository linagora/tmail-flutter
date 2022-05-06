
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountDashBoardView extends GetWidget<ManageAccountDashBoardController> with
  UserSettingPopupMenuMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ManageAccountDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isMenuDrawerOpen && _responsiveUtils.isDesktop(context)) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        controller.closeMenuDrawer();
      });
    }

    return Scaffold(
      key: controller.menuDrawerKey,
      backgroundColor: Colors.white,
      drawer: ResponsiveWidget(
          responsiveUtils: _responsiveUtils,
          mobile: SizedBox(child: ManageAccountMenuView(), width: _responsiveUtils.defaultSizeDrawer),
          desktop: const SizedBox.shrink()
      ),
      drawerEnableOpenDragGesture: !_responsiveUtils.isDesktop(context),
      body: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: _responsiveUtils,
            desktop: Column(children: [
              Row(children: [
                Container(width: 256, color: Colors.white,
                    padding: const EdgeInsets.only(top: 25, bottom: 25, left: 32),
                    child: Row(children: [
                      (SloganBuilder(arrangedByHorizontal: true)
                        ..setSloganText(AppLocalizations.of(context).app_name)
                        ..setSloganTextAlign(TextAlign.center)
                        ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                        ..setSizeLogo(24)
                        ..addOnTapCallback(() => controller.backToMailboxDashBoard())
                        ..setLogo(_imagePaths.icLogoTMail))
                      .build(),
                      Obx(() {
                        if (controller.appInformation.value != null) {
                          return Padding(padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'v.${controller.appInformation.value!.version}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
                              ));
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ])
                ),
                Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 16, bottom: 10, left: 48),
                    child: _buildRightHeader(context)))
              ]),
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(child: ManageAccountMenuView(), width: _responsiveUtils.defaultSizeMenu),
                  Expanded(child: _viewDisplayedOfAccountMenuItem())
                ],
              ))
            ]),
            mobile: SafeArea(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context)
                            ? const EdgeInsets.only(bottom: 16, left: 4, right: 8)
                            : const EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 32),
                        child: _buildAppbar(context)),
                    (SearchBarView(_imagePaths)
                        ..hintTextSearch(AppLocalizations.of(context).search_emails)
                        ..addMargin(!BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context)
                            ? const EdgeInsets.only(left: 16, right: 16)
                            : const EdgeInsets.only(left: 32, right: 32))
                        ..addOnOpenSearchViewAction(() => {}))
                      .build(),
                    Expanded(child: Padding(
                        padding: !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context)
                            ? const EdgeInsets.only(left: 8)
                            : const EdgeInsets.only(left: 24),
                        child: _viewDisplayedOfAccountMenuItem()))
                ])
            )
        ),
      ]),
    );
  }

  Widget _buildRightHeader(BuildContext context) {
    return Row(children: [
      const Spacer(),
      (SearchBarView(_imagePaths)
        ..hintTextSearch(AppLocalizations.of(context).search_emails)
        ..maxSizeWidth(240)
        ..addOnOpenSearchViewAction(() => {}))
      .build(),
      const SizedBox(width: 16),
      Obx(() => (AvatarBuilder()
          ..text(controller.userProfile.value?.getAvatarText() ?? '')
          ..backgroundColor(Colors.white)
          ..textColor(Colors.black)
          ..context(context)
          ..addOnTapAvatarActionWithPositionClick((position) =>
              controller.openPopupMenuAction(context, position, popupMenuUserSettingActionTile(context,
                  controller.userProfile.value,
                  onLogoutAction: ()  {
                    popBack();
                    controller.logoutAction();
                  },
                  onSettingAction: ()  {
                    popBack();
                    controller.goToSettings();
                  })))
          ..addBoxShadows([const BoxShadow(
              color: AppColor.colorShadowBgContentEmail,
              spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
          ..size(48))
        .build()),
      const SizedBox(width: 16)
    ]);
  }

  Widget _buildAppbar(BuildContext context) {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icMenuDrawer, fit: BoxFit.fill),
          onTap:() => controller.openMenuDrawer()),
      const SizedBox(width: 12),
      Expanded(child: Text(
          AppLocalizations.of(context).manage_account,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _viewDisplayedOfAccountMenuItem() {
    switch(controller.accountMenuItemSelected.value) {
      case AccountMenuItem.profiles:
        return ProfilesView();
      default:
        return const SizedBox.shrink();
    }
  }
}