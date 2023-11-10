import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_no_icon_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/download/download_task_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_delete_all_spam_emails_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_empty_trash_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_delete_all_spam_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_empty_trash_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_web_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/top_bar_thread_selection.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

import 'widgets/app_dashboard/app_grid_dashboard_overlay.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.hideMailboxMenuWhenScreenSizeChange(context);

    return Portal(
      child: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: responsiveUtils,
            desktop: Scaffold(
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  color: AppColor.colorBgDesktop,
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: ResponsiveUtils.defaultSizeMenu,
                        color: Colors.white,
                        padding: EdgeInsets.only(
                          left: AppUtils.isDirectionRTL(context) ? 0 : 28,
                          right: AppUtils.isDirectionRTL(context) ? 28 : 0,
                        ),
                        alignment: Alignment.center,
                        height: 80,
                        child: Row(children: [
                          SloganBuilder(
                            sizeLogo: 24,
                            text: AppLocalizations.of(context).app_name,
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                            logoSVG: imagePaths.icTMailLogo,
                            onTapCallback: controller.redirectToInboxAction,
                          ),
                          Obx(() {
                            if (controller.appInformation.value != null) {
                              return Padding(padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'v${controller.appInformation.value!.version}',
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
                        padding: EdgeInsets.only(
                          right: AppUtils.isDirectionRTL(context) ? 0 : 10,
                          left: AppUtils.isDirectionRTL(context) ? 10 : 0,
                        ),
                        height: 80,
                        child: _buildRightHeader(context)))
                    ]),
                    Expanded(child: Row(children: [
                      Column(children: [
                        _buildComposerButton(context),
                        Expanded(child: SizedBox(
                          width: ResponsiveUtils.defaultSizeMenu,
                          child: Obx(() {
                            if (controller.searchMailboxActivated.isTrue) {
                              return const SearchMailboxView(
                                backgroundColor: AppColor.colorBgDesktop
                              );
                            } else {
                              return MailboxView();
                            }
                          })
                        ))
                      ]),
                      Expanded(child: Column(children: [
                        const SpamReportBannerWebWidget(),
                        const QuotasBannerWidget(),
                        _buildVacationNotificationMessage(context),
                        Obx(() {
                          if (controller.isEmptyTrashBannerEnabledOnWeb(context)) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: BannerEmptyTrashStyles.webTopMargin,
                                end: BannerEmptyTrashStyles.webEndMargin
                              ),
                              child: BannerEmptyTrashWidget(
                                onTapAction: () => controller.emptyTrashAction(context)
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        Obx(() {
                          if (controller.isEmptySpamBannerEnabledOnWeb(context)) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: BannerDeleteAllSpamEmailsStyles.webTopMargin,
                                end: BannerDeleteAllSpamEmailsStyles.webEndMargin
                              ),
                              child: BannerDeleteAllSpamEmailsWidget(
                                onTapAction: () => controller.openDialogEmptySpamFolder(context)
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
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
                    ]))
                  ]),
                ),
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
                              const VerticalDivider(color: AppColor.lineItemListColor, width: 12),
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
                        const VerticalDivider(color: AppColor.lineItemListColor, width: 12),
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
            : const SizedBox.shrink()
        ),
        Obx(() => controller.searchMailboxActivated.value == true && !responsiveUtils.isWebDesktop(context)
          ? const SearchMailboxView()
          : const SizedBox.shrink()
        ),
        _buildDownloadTaskStateWidget(),
      ]),
    );
  }

  Widget _buildScaffoldHaveDrawer({required Widget body}) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ResponsiveWidget(
        responsiveUtils: responsiveUtils,
        mobile: SizedBox(width: ResponsiveUtils.defaultSizeDrawer, child: MailboxView()),
        tabletLarge: SizedBox(width: ResponsiveUtils.defaultSizeLeftMenuMobile, child: MailboxView()),
        desktop: const SizedBox.shrink()
      ),
      body: body,
    );
  }

  Widget _buildThreadViewForWebDesktop(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: AppUtils.isDirectionRTL(context) ? 0 : 16,
        left: AppUtils.isDirectionRTL(context) ? 16 : 0,
        top: 8,
        bottom: 16
      ),
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
        SizedBox(
          width: constraint.maxWidth / 2,
          height: 52,
          child: SearchInputFormWidget()
        ),
        const Spacer(),
        AppConfig.appGridDashboardAvailable
          ? Obx(() => PortalTarget(
              visible: controller.appGridDashboardController.isAppGridDashboardOverlayOpen.isTrue,
              portalFollower: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.appGridDashboardController.toggleAppGridDashboard()),
              child: PortalTarget(
                anchor: Aligned(
                  follower: AppUtils.isDirectionRTL(context)
                    ? Alignment.topLeft
                    : Alignment.topRight,
                  target: AppUtils.isDirectionRTL(context)
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight
                ),
                portalFollower: Obx(() {
                  if (controller.appGridDashboardController.linagoraApplications.value != null) {
                    return AppDashboardOverlay(controller.appGridDashboardController.linagoraApplications.value!);
                  }
                  return const SizedBox.shrink();
                }),
                visible: controller.appGridDashboardController.isAppGridDashboardOverlayOpen.isTrue,
                child: buildIconWeb(
                  onTap: controller.showAppDashboardAction,
                  splashRadius: 20,
                  icon: SvgPicture.asset(
                    imagePaths.icAppDashboard,
                    width: 28,
                    height: 28,
                    fit: BoxFit.fill
                  ),
                ),
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
      Obx(() {
        return controller.refreshingMailboxState.value.fold(
          (failure) {
            return TMailButtonWidget.fromIcon(
              key: const Key('refresh_mailbox_button'),
              icon: imagePaths.icRefresh,
              borderRadius: 10,
              iconSize: 16,
              onTapActionCallback: controller.refreshMailboxAction,
            );
          },
          (success) {
            if (success is RefreshAllEmailLoading) {
              return const TMailContainerWidget(
                borderRadius: 10,
                padding: EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8.5),
                child: CupertinoLoadingWidget(size: 16));
            } else {
              return TMailButtonWidget.fromIcon(
                key: const Key('refresh_mailbox_button'),
                icon: imagePaths.icRefresh,
                borderRadius: 10,
                iconSize: 16,
                onTapActionCallback: controller.refreshMailboxAction,
              );
            }
          }
        );
      }),
      const SizedBox(width: 16),
      TMailButtonWidget(
        key: const Key('select_all_emails_button'),
        text: AppLocalizations.of(context).select_all,
        icon: imagePaths.icSelectAll,
        borderRadius: 10,
        iconSize: 16,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        onTapActionCallback: controller.selectAllEmailAction,
      ),
      if (controller.isAbleMarkAllAsRead())
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: TMailButtonWidget(
            key: const Key('mark_as_read_emails_button'),
            text: AppLocalizations.of(context).mark_all_as_read,
            icon: imagePaths.icSelectAll,
            borderRadius: 10,
            iconSize: 16,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            onTapActionCallback: () => controller.markAsReadMailboxAction(context),
          ),
        ),
      const SizedBox(width: 16),
      Obx(() => TMailButtonWidget(
        key: const Key('filter_emails_button'),
        text: controller.filterMessageOption.value == FilterMessageOption.all
          ? AppLocalizations.of(context).filter_messages
          : controller.filterMessageOption.value.getTitle(context),
        icon: controller.filterMessageOption.value.getIconSelected(imagePaths),
        borderRadius: 10,
        iconSize: 16,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: controller.filterMessageOption.value.getBackgroundColor(),
        textStyle: controller.filterMessageOption.value.getTextStyle(),
        trailingIcon: imagePaths.icArrowDown,
        onTapActionAtPositionCallback: (position) {
          return controller.openPopupMenuAction(
            context,
            position,
            popupMenuFilterEmailActionTile(
              context,
              controller.filterMessageOption.value,
              (option) => controller.dispatchAction(FilterMessageAction(context, option)),
              isSearchEmailRunning: controller.searchController.isSearchEmailRunning
            )
          );
        },
      )),
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
            margin: EdgeInsets.only(
              top: 16,
              right: AppUtils.isDirectionRTL(context) ? 0 : 16,
              left: AppUtils.isDirectionRTL(context) ? 16 : 0,
            ),
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
          padding: const EdgeInsetsDirectional.only(end: 16, top: 8),
          child: Row(
            children: [
                ...QuickSearchFilter.values
                  .where((filter) => filter != QuickSearchFilter.sortBy)
                  .map((filter) => _buildQuickSearchFilterButton(context, filter)),
                const Spacer(),
                _buildQuickSearchFilterButton(context, QuickSearchFilter.sortBy)
              ]
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
      final isFilterSelected = filter.isSelected(
        controller.searchController.searchEmailFilter.value,
        controller.userProfile.value
      );

      return Padding(
        padding: EdgeInsets.only(
          right: AppUtils.isDirectionRTL(context) ? 0 : 8,
          left: AppUtils.isDirectionRTL(context) ? 8 : 0,
        ),
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
              controller.openPopupMenuAction(
                context,
                position,
                popupMenuEmailReceiveTimeType(
                  context,
                  controller.searchController.receiveTimeFiltered,
                  onCallBack: (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(context, receiveTime)
                )
              );
            }
            if (filter == QuickSearchFilter.sortBy) {
              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              controller.openPopupMenuAction(
                context,
                position,
                popupMenuEmailSortOrderType(
                  context,
                  controller.searchController.sortOrderFiltered.value,
                  onCallBack: (sortOrder) => controller.selectSortOrderQuickSearchFilter(context, sortOrder)
                )
              );
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filter.getBackgroundColor(isFilterSelected: isFilterSelected)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filter.getIcon(imagePaths, isFilterSelected: isFilterSelected),
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filter.getTitle(
                    context,
                    receiveTimeType: controller.searchController.receiveTimeFiltered,
                    startDate: controller.searchController.startDateFiltered,
                    endDate: controller.searchController.endDateFiltered,
                    sortOrderType: controller.searchController.sortOrderFiltered.value,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: filter.getTextStyle(isFilterSelected: isFilterSelected),
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
    {Function(EmailReceiveTimeType)? onCallBack}
  ) {
    return EmailReceiveTimeType.values
      .map((receiveTime) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemNoIconWidget(
          receiveTime.getTitle(context),
          svgIconSelected: imagePaths.icFilterSelected,
          maxWidth: 320,
          isSelected: receiveTimeSelected == receiveTime,
          onCallbackAction: () => onCallBack?.call(receiveTime),
        )))
      .toList();
  }

  List<PopupMenuEntry> popupMenuEmailSortOrderType(
    BuildContext context,
    EmailSortOrderType? sortOrderSelected,
    {Function(EmailSortOrderType)? onCallBack}
  ) {
    return EmailSortOrderType.values
      .map((sortType) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupItemNoIconWidget(
          sortType.getTitle(context),
          svgIconSelected: imagePaths.icFilterSelected,
          maxWidth: 332,
          isSelected: sortOrderSelected == sortType,
          onCallbackAction: () => onCallBack?.call(sortType),
        )))
      .toList();
  }

  Widget _buildComposerButton(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: 16,
        bottom: 8
      ),
      width: ResponsiveUtils.defaultSizeMenu,
      alignment: Alignment.centerLeft,
      child: TMailButtonWidget(
        key: const Key('compose_email_button'),
        text: AppLocalizations.of(context).compose,
        icon: imagePaths.icComposeWeb,
        borderRadius: 10,
        iconSize: 24,
        iconColor: Colors.white,
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
        backgroundColor: AppColor.colorTextButton,
        boxShadow: const [
          BoxShadow(
            blurRadius: 12.0,
            color: AppColor.colorShadowComposerButton
          )
        ],
        textStyle: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w500
        ),
        onTapActionCallback: () => controller.goToComposer(ComposerArguments()),
      ),
    );
  }
}