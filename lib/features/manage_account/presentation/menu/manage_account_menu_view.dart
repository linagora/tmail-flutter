
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/account_menu_item_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ManageAccountMenuView extends GetWidget<ManageAccountMenuController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ManageAccountMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Drawer(
        elevation: _responsiveUtils.isDesktop(context) ? 0 : 16.0,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(right: false, bottom: false,
              child: Column(
                  children: [
                    if (!_responsiveUtils.isWebDesktop(context))
                      Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                          child: Row(children: [
                            SloganBuilder(
                              sizeLogo: 24,
                              text: AppLocalizations.of(context).app_name,
                              textAlign: TextAlign.center,
                              textStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              logo: _imagePaths.icLogoTMail
                            ),
                            Obx(() {
                              if (controller.dashBoardController.appInformation.value != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'v.${controller.dashBoardController.appInformation.value!.version}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }),
                          ])
                      ),
                    if (!_responsiveUtils.isWebDesktop(context))
                      const Divider(color: AppColor.colorDividerMailbox, height: 1),
                    Expanded(child: Container(
                      color: _responsiveUtils.isWebDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                          padding: const EdgeInsetsDirectional.only(start: 20, top: 24),
                          child: (ButtonBuilder(DirectionUtils.isDirectionRTLByLanguage(context) ? _imagePaths.icArrowRight : _imagePaths.icBack)
                            ..key(const Key('button_back'))
                            ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorBgMailboxSelected))
                            ..paddingIcon(EdgeInsets.only(
                                right: AppUtils.isDirectionRTL(context) ? 0 : 8,
                                left: AppUtils.isDirectionRTL(context) ? 8 : 0,
                            ))
                            ..iconColor(AppColor.colorTextButton)
                            ..maxWidth(100)
                            ..size(DirectionUtils.isDirectionRTLByLanguage(context) ? null : 16)
                            ..radiusSplash(10)
                            ..padding(DirectionUtils.isDirectionRTLByLanguage(context)
                                ? const EdgeInsets.symmetric(vertical: 5)
                                : const EdgeInsets.symmetric(vertical: 10))
                            ..textStyle(const TextStyle(fontSize: 15, color: AppColor.colorTextButton, fontWeight: FontWeight.normal))
                            ..onPressActionClick(() => controller.backToMailboxDashBoard(context))
                            ..text(AppLocalizations.of(context).back, isVertical: false))
                          .build()),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 32, top: 20),
                          child: Text(
                            AppLocalizations.of(context).manage_account,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17
                            )
                          )
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.listAccountMenuItem.isNotEmpty) {
                            return ListView.builder(
                              key: const Key('list_manage_account_menu_item'),
                              padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                              shrinkWrap: true,
                              itemCount: controller.listAccountMenuItem.length,
                              itemBuilder: (context, index) => Obx(() {
                                final menuItem = controller.listAccountMenuItem[index];
                                return AccountMenuItemTileBuilder(
                                  menuItem,
                                  controller.dashBoardController.accountMenuItemSelected.value,
                                  onSelectAccountMenuItemAction: controller.selectAccountMenuItem
                                );
                              })
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: AppColor.lineItemListColor, height: 1)),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 20, end: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                controller.dashBoardController.logout(
                                  controller.dashBoardController.sessionCurrent,
                                  controller.dashBoardController.accountId.value
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(children: [
                                  SvgPicture.asset(_imagePaths.icSignOut, fit: BoxFit.fill),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(
                                    AppLocalizations.of(context).sign_out,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: Colors.black
                                    )
                                  ))
                                ]),
                              )
                            ),
                          )
                        ),
                      ]),
                    )),
                  ]
              )
          ),
        )
     );
  }
}