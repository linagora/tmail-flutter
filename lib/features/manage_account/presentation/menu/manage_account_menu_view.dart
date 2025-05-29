
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/account_menu_item_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class ManageAccountMenuView extends GetWidget<ManageAccountMenuController> {

  const ManageAccountMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: controller.responsiveUtils.isWebDesktop(context)
           ? AppColor.colorBgDesktop
           : Colors.white,
       body: SafeArea(right: false, bottom: false,
           child: Column(
               children: [
                 if (!controller.responsiveUtils.isWebDesktop(context))
                   Padding(
                       padding: const EdgeInsetsDirectional.only(top: 16, bottom: 16, start: 16),
                       child: Row(children: [
                         ApplicationLogoWidthTextWidget(),
                         const ApplicationVersionWidget(
                           padding: EdgeInsets.only(top: 8),
                         ),
                       ])
                   ),
                 if (!controller.responsiveUtils.isWebDesktop(context))
                   const Divider(color: AppColor.colorDividerMailbox, height: 1),
                 Expanded(child: Container(
                   color: controller.responsiveUtils.isWebDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Padding(
                         padding: const EdgeInsetsDirectional.only(start: 20, top: 24),
                         child: TMailButtonWidget(
                           key: const Key('back_to_dashboard_button'),
                           text: AppLocalizations.of(context).back,
                           icon: DirectionUtils.isDirectionRTLByLanguage(context)
                             ? controller.imagePaths.icArrowRight
                             : controller.imagePaths.icBack,
                           borderRadius: 10,
                           backgroundColor: AppColor.colorBgMailboxSelected,
                           iconColor: AppColor.colorTextButton,
                           maxWidth: 100,
                           padding: DirectionUtils.isDirectionRTLByLanguage(context)
                             ? const EdgeInsets.symmetric(vertical: 5)
                             : const EdgeInsets.symmetric(vertical: 10),
                           iconSize: DirectionUtils.isDirectionRTLByLanguage(context) ? null : 16,
                           textStyle: const TextStyle(
                             fontSize: 15,
                             color: AppColor.colorTextButton,
                             fontWeight: FontWeight.normal
                           ),
                           onTapActionCallback: () => controller.backToMailboxDashBoard(context),
                         ),
                       ),
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
                       Flexible(
                         child: Obx(() {
                           if (controller.listAccountMenuItem.isNotEmpty) {
                             return ListView.builder(
                               key: const Key('list_manage_account_menu_item'),
                               padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                               shrinkWrap: true,
                               itemCount: controller.listAccountMenuItem.length,
                               itemBuilder: (context, index) => Obx(() {
                                 final menuItem = controller.listAccountMenuItem[index];
                                 return AccountMenuItemTileBuilder(
                                   imagePaths: controller.imagePaths,
                                   responsiveUtils: controller.responsiveUtils,
                                   menuItem: menuItem,
                                   menuItemSelected: controller.dashBoardController.accountMenuItemSelected.value,
                                   onSelectAccountMenuItemAction: controller.selectAccountMenuItem
                                 );
                               })
                             );
                           } else {
                             return const SizedBox.shrink();
                           }
                         }),
                       ),
                       const Padding(
                           padding: EdgeInsets.symmetric(vertical: 16),
                           child: Divider()),
                       Obx(() {
                         final accountId = controller
                           .dashBoardController
                           .accountId
                           .value;

                         if (accountId == null) return const SizedBox.shrink();

                         final contactSupportCapability = controller
                           .dashBoardController
                           .sessionCurrent
                           ?.getContactSupportCapability(accountId);

                         if (contactSupportCapability?.isAvailable != true) return const SizedBox.shrink();

                         return AccountMenuItemTileBuilder(
                           imagePaths: controller.imagePaths,
                           responsiveUtils: controller.responsiveUtils,
                           menuItem: AccountMenuItem.contactSupport,
                           padding: const EdgeInsetsDirectional.only(start: 16, end: 8, bottom: 6),
                           onSelectAccountMenuItemAction: (_) {
                             controller.onGetHelpOrReportBug(
                               contactSupportCapability!,
                               route: AppRoutes.settings,
                             );
                           },
                         );
                       }),
                       AccountMenuItemTileBuilder(
                         imagePaths: controller.imagePaths,
                         responsiveUtils: controller.responsiveUtils,
                         menuItem: AccountMenuItem.signOut,
                         padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                         onSelectAccountMenuItemAction: (_) {
                           controller.dashBoardController.logout(
                             context,
                             controller.dashBoardController.sessionCurrent,
                             controller.dashBoardController.accountId.value,
                           );
                         }
                       ),
                     ]
                   ),
                 )),
                 Container(
                   color: AppColor.colorBgDesktop,
                   width: double.infinity,
                   alignment: controller.responsiveUtils.isDesktop(context)
                     ? AlignmentDirectional.centerStart
                     : AlignmentDirectional.center,
                   padding: const EdgeInsets.all(16),
                   child: ApplicationVersionWidget(
                     title: '${AppLocalizations.of(context).version.toLowerCase()} ',
                   ),
                 ),
               ]
           )
       ),
     );
  }
}