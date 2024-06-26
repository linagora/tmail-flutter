import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recover_deleted_message_loading_banner_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/top_bar_thread_selection.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_delete_all_spam_emails_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_empty_trash_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_delete_all_spam_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_empty_trash_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_web_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.hideMailboxMenuWhenScreenSizeChange(context);

    return Portal(
      child: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: controller.responsiveUtils,
            desktop: Scaffold(
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  color: AppColor.colorBgDesktop,
                  child: Column(children: [
                    Obx(() => NavigationBarWidget(
                      userProfile: controller.userProfile.value,
                      searchForm: SearchInputFormWidget(),
                      appGridController: controller.appGridDashboardController,
                      onShowAppDashboardAction: controller.showAppDashboardAction,
                      onTapApplicationLogoAction: controller.redirectToInboxAction,
                      onTapAvatarAction: (position) => controller.handleClickAvatarAction(context, position),
                    )),
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
                        QuotasBannerWidget(
                          margin: const EdgeInsetsDirectional.only(end: 16, top: 8),
                        ),
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
                        Obx(() => RecoverDeletedMessageLoadingBannerWidget(
                            isLoading: controller.isRecoveringDeletedMessage.value,
                            horizontalLoadingWidget: horizontalLoadingWidget,
                            responsiveUtils: controller.responsiveUtils,
                        )),
                        _buildListButtonQuickSearchFilter(context),
                        _buildMarkAsMailboxReadLoading(context),
                        Expanded(child: Obx(() {
                          switch(controller.dashboardRoute.value) {
                            case DashboardRoutes.thread:
                              return _buildThreadViewForWebDesktop(context);
                            case DashboardRoutes.emailDetailed:
                              return const EmailView();
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
                      ? const EmailView()
                      : _buildScaffoldHaveDrawer(
                        body: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: ResponsiveUtils.defaultSizeLeftMenuMobile,
                                  child: ThreadView()),
                              const VerticalDivider(width: 1),
                              const Expanded(child: EmailView()),
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
                        const VerticalDivider(width: 1),
                        const Expanded(child: EmailView()),
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
                  return const EmailView();
                case DashboardRoutes.searchEmail:
                  return SearchEmailView();
                default:
                  return _buildScaffoldHaveDrawer(body: ThreadView());
              }
            }),
        ),
        Obx(() => controller.composerOverlayState.value == ComposerOverlayState.active
            ? const ComposerView()
            : const SizedBox.shrink()
        ),
        Obx(() => controller.searchMailboxActivated.value == true && !controller.responsiveUtils.isWebDesktop(context)
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
        responsiveUtils: controller.responsiveUtils,
        mobile: SizedBox(width: ResponsiveUtils.defaultSizeDrawer, child: MailboxView()),
        tabletLarge: SizedBox(width: ResponsiveUtils.defaultSizeLeftMenuMobile, child: MailboxView()),
        desktop: const SizedBox.shrink()
      ),
      body: body,
    );
  }

  Widget _buildThreadViewForWebDesktop(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 16, top: 8, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
        color: Colors.white),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Column(children: [
          Obx(() {
            final listEmailSelected = controller.listEmailSelected;
            if (controller.isSelectionEnabled() && listEmailSelected.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 16),
                child: TopBarThreadSelection(
                  listEmailSelected,
                  controller.mapMailboxById,
                  onCancelSelection: () =>
                    controller.dispatchAction(CancelSelectionAllEmailAction()),
                  onEmailActionTypeAction: (listEmails, actionType) =>
                    controller.dispatchAction(HandleEmailActionTypeAction(
                      context,
                      listEmails,
                      actionType
                    )),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: _buildListButtonTopBar(context),
              );
            }
          }),
          const Divider(),
          Expanded(child: ThreadView())
        ]),
      ),
    );
  }

  Widget _buildListButtonTopBar(BuildContext context) {
    return Row(children: [
      Obx(() {
        return controller.refreshingMailboxState.value.fold(
          (failure) {
            return TMailButtonWidget.fromIcon(
              key: const Key('refresh_mailbox_button'),
              icon: controller.imagePaths.icRefresh,
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
                icon: controller.imagePaths.icRefresh,
                borderRadius: 10,
                iconSize: 16,
                onTapActionCallback: controller.refreshMailboxAction,
              );
            }
          }
        );
      }),
      const SizedBox(width: 16),
      Tooltip(
        message: AppLocalizations.of(context).selectAllMessagesOfThisPage,
        child: ElevatedButton.icon(
          onPressed: controller.selectAllEmailAction,
          icon: SvgPicture.asset(
            controller.imagePaths.icSelectAll,
            width: 16,
            height: 16,
            fit: BoxFit.fill,
          ),
          label: Text(
            AppLocalizations.of(context).selectAllMessagesOfThisPage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.colorButtonHeaderThread,
            shadowColor: Colors.transparent,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            elevation: 0.0,
            foregroundColor: AppColor.colorTextButtonHeaderThread,
            maximumSize: const Size.fromWidth(250),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      if (controller.isAbleMarkAllAsRead())
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: TMailButtonWidget(
            key: const Key('mark_as_read_emails_button'),
            text: AppLocalizations.of(context).mark_all_as_read,
            icon: controller.imagePaths.icSelectAll,
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
        icon: controller.filterMessageOption.value.getIconSelected(controller.imagePaths),
        borderRadius: 10,
        iconSize: 16,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: controller.filterMessageOption.value.getBackgroundColor(),
        textStyle: controller.filterMessageOption.value.getTextStyle(),
        trailingIcon: controller.imagePaths.icArrowDown,
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
      Obx(() {
        final mailboxSelected = controller.selectedMailbox.value;
        if (mailboxSelected != null && mailboxSelected.role == PresentationMailbox.roleTrash) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: TMailButtonWidget.fromIcon(
              key: const Key('recover_deleted_messages_button'),
              icon: controller.imagePaths.icRecoverDeletedMessages,
              borderRadius: 10,
              iconSize: 16,
              onTapActionCallback: () => controller.gotoEmailRecovery(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      })
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
                      top: controller.responsiveUtils.isDesktop(context) ? 16 : 0,
                      left: 16,
                      right: 16,
                      bottom: controller.responsiveUtils.isDesktop(context) ? 0 : 16),
                  child: horizontalLoadingWidget);
            } else if (success is UpdatingMarkAsMailboxReadState) {
              final percent = success.countRead / success.totalUnread;
              return Padding(
                  padding: EdgeInsets.only(
                      top: controller.responsiveUtils.isDesktop(context) ? 16 : 0,
                      left: 16,
                      right: 16,
                      bottom: controller.responsiveUtils.isDesktop(context) ? 0 : 16),
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
            if (!filter.isTapOpenPopupMenu()) {
              controller.selectQuickSearchFilterAction(filter);
            }
          },
          onTapDown: (detail) {
            final screenSize = MediaQuery.of(context).size;
            final offset = detail.globalPosition;
            final position = RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              screenSize.width - offset.dx,
              screenSize.height - offset.dy,
            );

            switch(filter) {
              case QuickSearchFilter.last7Days:
                _openPopupMenuDateFilter(context, position);
                break;
              case QuickSearchFilter.sortBy:
                _openPopupMenuSortFilter(context, position);
                break;
              default:
                break;
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
                    filter.getIcon(controller.imagePaths, isFilterSelected: isFilterSelected),
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filter == QuickSearchFilter.fromMe
                    ? _getQuickSearchFilterFromTitle(context)
                    :  filter.getTitle(
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
                if (filter == QuickSearchFilter.last7Days || filter == QuickSearchFilter.fromMe)
                  ... [
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                        controller.imagePaths.icChevronDown,
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
          svgIconSelected: controller.imagePaths.icFilterSelected,
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
          svgIconSelected: controller.imagePaths.icFilterSelected,
          maxWidth: 332,
          isSelected: sortOrderSelected == sortType,
          onCallbackAction: () => onCallBack?.call(sortType),
        )))
      .toList();
  }

  void _openPopupMenuDateFilter(BuildContext context, RelativeRect position) {
    controller.openPopupMenuAction(
      context,
      position,
      popupMenuEmailReceiveTimeType(
        context,
        controller.searchController.receiveTimeFiltered,
        onCallBack: (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(
          context,
          receiveTime
        )
      )
    );
  }

  void _openPopupMenuSortFilter(BuildContext context, RelativeRect position) {
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
        icon: controller.imagePaths.icComposeWeb,
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

  String _getQuickSearchFilterFromTitle(BuildContext context) {
    final searchEmailFilterFromFiled = controller.searchController.searchEmailFilter.value.from;
    if (searchEmailFilterFromFiled.length == 1) {
      if (searchEmailFilterFromFiled.first == controller.userProfile.value?.email) {
        return QuickSearchFilter.fromMe.getTitle(context);
      } else {
        return '${AppLocalizations.of(context).from_email_address_prefix} ${searchEmailFilterFromFiled.first}';
      }
    } else {
      return AppLocalizations.of(context).from_email_address_prefix;
    }
  }
}