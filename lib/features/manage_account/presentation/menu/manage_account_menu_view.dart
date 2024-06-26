
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/account_menu_item_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ManageAccountMenuView extends GetWidget<ManageAccountMenuController> {

  const ManageAccountMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       body: SafeArea(
         right: false,
         bottom: false,
         child: Container(
           color: AppColor.colorBgDesktop,
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
                   child: Divider()),
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
                         SvgPicture.asset(controller.imagePaths.icSignOut, fit: BoxFit.fill),
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
             ]
           ),
         )
       ),
     );
  }
}