
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/widgets/account_menu_item_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ManageAccountMenuView extends GetWidget<ManageAccountMenuController> {

  const ManageAccountMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       body: SafeArea(right: false, bottom: false,
           child: Column(
               children: [
                 if (!controller.responsiveUtils.isWebDesktop(context))
                   Container(
                       color: Colors.white,
                       padding: const EdgeInsetsDirectional.only(top: 16, bottom: 16, start: 16),
                       child: Row(children: [
                         ApplicationLogoWidthTextWidget(),
                         const ApplicationVersionWidget()
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

                         if (contactSupportCapability == null) return const SizedBox.shrink();

                         return Padding(
                           padding: const EdgeInsetsDirectional.only(start: 20, end: 10),
                           child: Material(
                             color: Colors.transparent,
                             child: InkWell(
                               onTap: () => controller.onGetHelpOrReportBug(contactSupportCapability),
                               borderRadius: const BorderRadius.all(Radius.circular(10)),
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(
                                   horizontal: 12,
                                   vertical: 6,
                                 ),
                                 child: Row(children: [
                                   SvgPicture.asset(
                                     controller.imagePaths.icHelp,
                                     width: 20,
                                     height: 20,
                                     fit: BoxFit.fill,
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Text(
                                       AppLocalizations.of(context).contactSupport,
                                       style: const TextStyle(
                                         fontWeight: FontWeight.normal,
                                         fontSize: 15,
                                         color: Colors.black,
                                       ),
                                     ),
                                   )
                                 ]),
                               )
                             ),
                           ),
                         );
                       }),
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
                                 SvgPicture.asset(controller.imagePaths.icSignOut, width: 20, height: 20, fit: BoxFit.fill),
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
                 )),
                 Container(
                   color: AppColor.colorBgMailbox,
                   width: double.infinity,
                   alignment: controller.responsiveUtils.isDesktop(context)
                     ? AlignmentDirectional.centerStart
                     : AlignmentDirectional.center,
                   padding: const EdgeInsets.all(16),
                   child: ApplicationVersionWidget(
                     padding: EdgeInsets.zero,
                     title: '${AppLocalizations.of(context).version.toLowerCase()} ',
                     textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                       fontSize: 13,
                       color: AppColor.colorTextBody,
                       fontWeight: FontWeight.normal
                     ),
                   ),
                 ),
               ]
           )
       ),
     );
  }
}