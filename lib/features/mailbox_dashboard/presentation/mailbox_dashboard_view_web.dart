import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_overlay.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/icon_open_advanced_search_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/download/download_task_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/top_bar_thread_selection.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_warning_banner_widget.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

import 'widgets/app_dashboard/app_grid_dashboard_overlay.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  final SearchController searchController = Get.find<SearchController>();
  final AppGridDashboardController appGridDashboardController = Get.find<AppGridDashboardController>();
  final mailBoxDashboardController = Get.find<MailboxDashBoardController>();

  @override
  Widget build(BuildContext context) {
    if (controller.isDrawerOpen && responsiveUtils.isDesktop(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.closeMailboxMenuDrawer();
      });
    }

    return Portal(
      child: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: responsiveUtils,
            desktop: Scaffold(
              body: Container(
                color: AppColor.colorBgDesktop,
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: responsiveUtils.defaultSizeMenu,
                      color: Colors.white,
                      padding: const EdgeInsets.only(left: 28),
                      alignment: Alignment.center,
                      height: 80,
                      child: Row(children: [
                        (SloganBuilder(arrangedByHorizontal: true)
                            ..setSloganText(AppLocalizations.of(context).app_name)
                            ..setSloganTextAlign(TextAlign.center)
                            ..setSloganTextStyle(const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))
                            ..setSizeLogo(24)
                            ..setLogo(imagePaths.icLogoTMail))
                          .build(),
                        Obx(() {
                          if (controller.appInformation.value != null) {
                            return Padding(padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'v.${controller.appInformation.value!.version}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColor.colorContentEmail,
                                  fontWeight: FontWeight.w500),
                              ));
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                      ])
                    ),
                    Expanded(child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(right: 10),
                      height: 80,
                      child: _buildRightHeader(context)))
                  ]),
                  Expanded(child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(child: MailboxView(), width: responsiveUtils.defaultSizeMenu),
                      Expanded(child: Column(children: [
                        _buildEmptyTrashButton(context),
                        const QuotasWarningBannerWidget(
                          margin: EdgeInsets.only(right: 16, top: 8),
                        ),
                        _buildVacationNotificationMessage(context),
                        _buildListButtonQuickSearchFilter(context),
                        _buildMarkAsMailboxReadLoading(context),
                        Expanded(child: Obx(() {
                          switch(controller.dashboardRoute.value) {
                            case DashboardRoutes.thread:
                              return _buildThreadViewForWebDesktop(context);
                            case DashboardRoutes.emailDetailed:
                              return EmailView();
                            default:
                              return const SizedBox.shrink();
                          }
                        }))
                      ]))
                    ],
                  ))
                ]),
              ),
            ),
            tabletLarge: Obx(() {
              switch(controller.dashboardRoute.value) {
                case DashboardRoutes.searchEmail:
                  return SearchEmailView();
                case DashboardRoutes.emailDetailed:
                  return controller.searchController.isSearchEmailRunning
                      ? EmailView()
                      : _buildScaffoldHaveDrawer(
                        body: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: ResponsiveUtils.defaultSizeLeftMenuMobile,
                                  child: ThreadView()),
                              Expanded(child: EmailView()),
                            ],
                          ),
                      );
                default:
                  return _buildScaffoldHaveDrawer(
                    body: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: ResponsiveUtils.defaultSizeLeftMenuMobile,
                            child: ThreadView()),
                        Expanded(child: EmailView()),
                      ],
                    ),
                  );
              }
            }),
            mobile: Obx(() {
              switch(controller.dashboardRoute.value) {
                case DashboardRoutes.thread:
                  return _buildScaffoldHaveDrawer(body: ThreadView());
                case DashboardRoutes.emailDetailed:
                  return EmailView();
                case DashboardRoutes.searchEmail:
                  return SearchEmailView();
                default:
                  return _buildScaffoldHaveDrawer(body: ThreadView());
              }
            }),
        ),
        Obx(() => controller.composerOverlayState.value == ComposerOverlayState.active
            ? ComposerView()
            : const SizedBox.shrink()),
        _buildDownloadTaskStateWidget(),
      ]),
    );
  }

  Widget _buildScaffoldHaveDrawer({required Widget body}) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: SizedBox(child: MailboxView(), width: ResponsiveUtils.defaultSizeDrawer),
      tablet: SizedBox(child: MailboxView(), width: ResponsiveUtils.defaultSizeDrawer),
      tabletLarge: SizedBox(child: MailboxView(), width: ResponsiveUtils.defaultSizeLeftMenuMobile),
      desktop: const SizedBox.shrink()),
      body: body,
    );
  }

  Widget _buildThreadViewForWebDesktop(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
        color: Colors.white),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: [
          Obx(() {
            if (controller.isSelectionEnabled()) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: TopBarThreadSelection(
                  context,
                  controller.listEmailSelected,
                  controller.mapMailboxById,
                  onCancelSelection: () =>
                    controller.dispatchAction(CancelSelectionAllEmailAction()),
                  onEmailActionTypeAction: (listEmails, actionType) =>
                    controller.dispatchAction(HandleEmailActionTypeAction(
                      context,
                      listEmails,
                      actionType
                    )),
                ).build(),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildListButtonTopBar(context),
              );
            }
          }),
          const Divider(color: AppColor.colorDivider, height: 1),
          Expanded(child: ThreadView())
        ]),
      ),
    );
  }

  Widget _buildRightHeader(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Row(children: [
        Container(
          width: constraint.maxWidth / 2,
          height: 52,
          color: Colors.transparent,
          child: Obx(() {
            if (searchController.isSearchActive()) {
              return SearchInputFormWidget(
                  maxWidth: constraint.maxWidth / 2,
                  dashBoardController: controller,
                  imagePaths: imagePaths);
            } else {
              return PortalTarget(
                visible: searchController.isAdvancedSearchViewOpen.isTrue,
                portalFollower: PointerInterceptor(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => searchController.selectOpenAdvanceSearch()),
                ),
                child: PortalTarget(
                  visible: searchController.isAdvancedSearchViewOpen.isTrue,
                  anchor: const Aligned(
                    follower: Alignment.topRight,
                    target: Alignment.bottomRight,
                    widthFactor: 1,
                    backup: Aligned(
                      follower: Alignment.topRight,
                      target: Alignment.bottomRight,
                      widthFactor: 1,
                    ),
                  ),
                  portalFollower: AdvancedSearchFilterOverlay(maxWidth: constraint.maxWidth / 2),
                  child: SearchBarView(imagePaths,
                      hintTextSearch: AppLocalizations.of(context).search_emails,
                      onOpenSearchViewAction: controller.searchController.enableSearch,
                      heightSearchBar: 52,
                      radius: 12,
                      rightButton: IconOpenAdvancedSearchWidget(context)),
                ),
              );
            }
          })),
        const Spacer(),
        AppConfig.appGridDashboardAvailable
          ? Obx(() => PortalTarget(
              visible: appGridDashboardController.isAppGridDashboardOverlayOpen.isTrue,
              portalFollower: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => appGridDashboardController.toggleAppGridDashboard()),
              child: PortalTarget(
                child: InkWell(
                  onTapDown: (tapDownDetails) => controller.showAppDashboardAction(),
                  child: buildIconWeb(
                    icon: SvgPicture.asset(imagePaths.icAppDashboard, width: 28, height: 28, fit: BoxFit.fill),
                  )
                ),
                anchor: const Aligned(
                  follower: Alignment.topRight,
                  target: Alignment.bottomRight
                ),
                portalFollower: Obx(() {
                  if (appGridDashboardController.linagoraApplications.value != null) {
                    return AppDashboardOverlay(appGridDashboardController.linagoraApplications.value!);
                  }
                  return const SizedBox.shrink();
                }),
                visible: appGridDashboardController.isAppGridDashboardOverlayOpen.isTrue,
              )
            )
          )
          : const SizedBox.shrink(),
        const SizedBox(width: 24),
        Obx(() => (AvatarBuilder()
          ..text(controller.userProfile.value?.getAvatarText() ?? '')
          ..backgroundColor(Colors.white)
          ..textColor(Colors.black)
          ..context(context)
          ..addOnTapAvatarActionWithPositionClick((position) =>
              controller.openPopupMenuAction(context, position, popupMenuUserSettingActionTile(context,
                  controller.userProfile.value,
                  onLogoutAction: () {
                    popBack();
                    controller.logout(controller.sessionCurrent, controller.accountId.value);
                  },
                  onSettingAction: () {
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
    });
  }

  Widget _buildListButtonTopBar(BuildContext context) {
    return Row(children: [
      (ButtonBuilder(imagePaths.icRefresh)
          ..key(const Key('button_reload_thread'))
          ..decoration(const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.zero)
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 8, vertical: 8))
          ..onPressActionClick(() => controller.dispatchAction(RefreshAllEmailAction())))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(imagePaths.icSelectAll)
          ..key(const Key('button_select_all'))
          ..decoration(const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(SelectionAllEmailAction()))
          ..text(AppLocalizations.of(context).select_all, isVertical: false))
        .build(),
      if (mailBoxDashboardController.isAbleMarkAllAsRead())
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: (ButtonBuilder(imagePaths.icMarkAllAsRead)
            ..key(const Key('button_mark_all_as_read'))
            ..decoration(const BoxDecoration(
                borderRadius:BorderRadius.all(Radius.circular(10)),
                color: AppColor.colorButtonHeaderThread))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..size(16)
            ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
            ..radiusSplash(10)
            ..textStyle(const TextStyle(
                fontSize: 12,
                color: AppColor.colorTextButtonHeaderThread))
            ..onPressActionClick(() => controller.markAsReadMailboxAction())
            ..text(AppLocalizations.of(context).mark_all_as_read, isVertical: false))
          .build(),
        ),
      const SizedBox(width: 16),
      Obx(() => (ButtonBuilder(controller.filterMessageOption.value.getIconSelected(imagePaths))
          ..key(const Key('button_filter_messages'))
          ..context(context)
          ..decoration(BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: controller.filterMessageOption.value.getBackgroundColor()))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(controller.filterMessageOption.value.getTextStyle())
          ..addIconAction(Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SvgPicture.asset(imagePaths.icArrowDown, fit: BoxFit.fill)))
          ..addOnPressActionWithPositionClick((position) =>
              controller.openPopupMenuAction(
                context,
                position,
                popupMenuFilterEmailActionTile(
                  context,
                  controller.filterMessageOption.value,
                  (option) => controller.dispatchAction(FilterMessageAction(context, option)),
                  isSearchEmailRunning: searchController.isSearchEmailRunning
                )
              )
            )
          ..text(controller.filterMessageOption.value == FilterMessageOption.all
              ? AppLocalizations.of(context).filter_messages
              : controller.filterMessageOption.value.getTitle(context), isVertical: false))
        .build()),
    ]);
  }

  Widget _buildMarkAsMailboxReadLoading(BuildContext context) {
    return Obx(() {
      final viewState = controller.viewStateMarkAsReadMailbox.value;
      return viewState.fold(
          (failure) => const SizedBox.shrink(),
          (success) {
            if (success is MarkAsMailboxReadLoading) {
              return Padding(
                  padding: EdgeInsets.only(
                      top: responsiveUtils.isDesktop(context) ? 16 : 0,
                      left: 16,
                      right: 16,
                      bottom: responsiveUtils.isDesktop(context) ? 0 : 16),
                  child: horizontalLoadingWidget);
            } else if (success is UpdatingMarkAsMailboxReadState) {
              final percent = success.countRead / success.totalUnread;
              return Padding(
                  padding: EdgeInsets.only(
                      top: responsiveUtils.isDesktop(context) ? 16 : 0,
                      left: 16,
                      right: 16,
                      bottom: responsiveUtils.isDesktop(context) ? 0 : 16),
                  child: horizontalPercentLoadingWidget(percent));
            }
            return const SizedBox.shrink();
          });
    });
  }

  Widget _buildDownloadTaskStateWidget() {
    return Obx(() {
      if (controller.downloadController.notEmptyListDownloadTask) {
        final downloadTasks = controller.downloadController.listDownloadTaskState;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: AppColor.colorBackgroundSnackBar,
            height: 60,
            width: double.infinity,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: downloadTasks.length,
                separatorBuilder: (context, index) =>
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: VerticalDivider(
                      color: Colors.grey,
                      width: 2.5,
                      thickness: 0.2),
                  ),
                itemBuilder: (context, index) =>
                    DownloadTaskItemWidget(downloadTasks[index])
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildVacationNotificationMessage(BuildContext context) {
    return Obx(() {
      if (controller.vacationResponse.value?.vacationResponderIsValid == true) {
        return VacationNotificationMessageWidget(
            margin: const EdgeInsets.only(top: 16, right: 16),
            vacationResponse: controller.vacationResponse.value!,
            actionGotoVacationSetting: () => controller.goToVacationSetting(),
            actionEndNow: () => controller.disableVacationResponder());
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  bool supportListButtonQuickSearchFilter(BuildContext context) {
    return controller.searchController.isSearchEmailRunning
      && controller.dashboardRoute.value == DashboardRoutes.thread;
  }

  Widget _buildListButtonQuickSearchFilter(BuildContext context) {
    return Obx(() {
      if (supportListButtonQuickSearchFilter(context)) {
        return Padding(
          padding: const EdgeInsets.only(right: 16, top: 16),
          child: Row(children: QuickSearchFilter.values
            .map((filter) => _buildQuickSearchFilterButton(context, filter))
            .toList()
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildQuickSearchFilterButton(
      BuildContext context,
      QuickSearchFilter filter
  ) {
    return Obx(() {
      final quickSearchFilterSelected = controller.checkQuickSearchFilterSelected(
        quickSearchFilter: filter,
      );

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () {
            if (filter != QuickSearchFilter.last7Days) {
              controller.selectQuickSearchFilterAction(filter);
            }
          },
          onTapDown: (detail) {
            if (filter == QuickSearchFilter.last7Days) {
              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              controller.openPopupMenuAction(context, position,
                  popupMenuEmailReceiveTimeType(context,
                      controller.searchController.emailReceiveTimeType.value,
                          (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(receiveTime)));
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filter.getBackgroundColor(quickSearchFilterSelected: quickSearchFilterSelected)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filter.getIcon(
                        imagePaths,
                        quickSearchFilterSelected: quickSearchFilterSelected),
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filter.getTitle(
                      context,
                      receiveTimeType: controller.searchController.emailReceiveTimeType.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: filter.getTextStyle(
                      quickSearchFilterSelected: quickSearchFilterSelected),
                ),
                if (filter == QuickSearchFilter.last7Days)
                  ... [
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                        imagePaths.icChevronDown,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill),
                  ]
              ])),
        ),
      );
    });
  }

  List<PopupMenuEntry> popupMenuEmailReceiveTimeType(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      Function(EmailReceiveTimeType?)? onCallBack
  ) {
    return EmailReceiveTimeType.values
        .map((timeType) => PopupMenuItem(
            padding: EdgeInsets.zero,
            child: _receiveTimeTileAction(
                context,
                receiveTimeSelected,
                timeType,
                onCallBack)))
        .toList();
  }

  Widget _receiveTimeTileAction(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      EmailReceiveTimeType receiveTimeType,
      Function(EmailReceiveTimeType?)? onCallBack
  ) {
    return InkWell(
        onTap: () => onCallBack?.call(receiveTimeType == receiveTimeSelected
            ? null
            : receiveTimeType),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
              width: 320,
              child: Row(children: [
                Expanded(child: Text(
                    receiveTimeType.getTitle(context),
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.normal))),
                if (receiveTimeType == receiveTimeSelected)
                  ...[
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                        imagePaths.icFilterSelected,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fill),
                  ]
              ])
          ),
        )
    );
  }

  bool supportEmptyTrash(BuildContext context) {
    return controller.isMailboxTrash
        && !controller.searchController.isSearchActive()
        && responsiveUtils.isWebDesktop(context);
  }

  Widget _buildEmptyTrashButton(BuildContext context) {
    return Obx(() {
      if (supportEmptyTrash(context)) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              border: Border.all(color: AppColor.colorLineLeftEmailView),
              color: Colors.white),
          margin: const EdgeInsets.only(right: 16, top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(
                    imagePaths.icDeleteTrash,
                    fit: BoxFit.fill)),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context).message_delete_all_email_in_trash_button,
                              style: const TextStyle(
                                  color: AppColor.colorContentEmail,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500))),
                      TextButton(
                          onPressed: () => controller.emptyTrashAction(context),
                          child: Text(
                              AppLocalizations.of(context).empty_trash_now,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.colorTextButton)
                          )
                      )
                    ]
                )
            )
          ]),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}