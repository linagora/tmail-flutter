
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
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
       body: SafeArea(
         right: false,
         bottom: false,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             if (!controller.responsiveUtils.isWebDesktop(context))
               ...[
                 Padding(
                   padding: const EdgeInsetsDirectional.only(
                     top: 16,
                     bottom: 16,
                     start: 16,
                   ),
                   child: Row(
                     children: [
                       ApplicationLogoWidthTextWidget(),
                       const ApplicationVersionWidget(
                         padding: EdgeInsets.only(top: 8),
                       ),
                     ],
                   ),
                 ),
                 const Divider(
                   color: AppColor.colorDividerMailbox,
                   height: 1,
                 ),
               ],
             Expanded(
               child: Padding(
                 padding: const EdgeInsetsDirectional.only(
                   start: 9,
                   end: 8,
                   top: 16,
                   bottom: 16,
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Padding(
                        padding: const EdgeInsets.all(8),
                        child: TMailButtonWidget(
                          key: const Key('back_to_dashboard_button'),
                          text: AppLocalizations.of(context).back,
                          icon: DirectionUtils.isDirectionRTLByLanguage(context)
                              ? controller.imagePaths.icArrowRight
                              : controller.imagePaths.icBack,
                          borderRadius: 8,
                          mainAxisSize: MainAxisSize.min,
                          backgroundColor: AppColor.lightGrayEAEDF2,
                          iconColor: AppColor.primaryLinShare,
                          minWidth: 79,
                          iconSize:
                              DirectionUtils.isDirectionRTLByLanguage(context)
                                  ? null
                                  : 9,
                          padding: const EdgeInsetsDirectional.only(
                            start: 19,
                            end: 12,
                            top: 8,
                            bottom: 8,
                          ),
                          textStyle:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColor.blue900,
                                  ),
                          onTapActionCallback: () =>
                              controller.backToMailboxDashBoard(context),
                        ),
                      ),
                      Padding(
                       padding: const EdgeInsets.all(8),
                       child: Text(
                         AppLocalizations.of(context).manage_account,
                         style: ThemeUtils.textStyleHeadingHeadingSmall(
                           fontWeight: FontWeight.bold,
                         ),
                       )
                     ),
                     Flexible(
                       child: Obx(() {
                         if (controller.listAccountMenuItem.isNotEmpty) {
                           return ListView.builder(
                             key: const Key('list_manage_account_menu_item'),
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 8,
                            ),
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
                       padding: EdgeInsets.only(top: 20, bottom: 12),
                       child: Divider(color: Colors.black12),
                     ),
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
                         padding: const EdgeInsetsDirectional.symmetric(
                           horizontal: 8,
                         ),
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
                       padding: const EdgeInsetsDirectional.only(
                         start: 8,
                         end: 8,
                         top: 4,
                       ),
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
               ),
             ),
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
           ],
         ),
       ),
     );
  }
}