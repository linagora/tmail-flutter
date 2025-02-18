import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/extensions/username_extension.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_no_icon_widget.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/filter_message_button_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mailbox_dashboard_view_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/download/download_task_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/mark_mailbox_as_read_loading_banner.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/loading/delete_all_permanently_emails_loading_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/loading/mark_all_as_unread_selection_all_emails_loading_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/loading/mark_mailbox_as_read_loading_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/loading/move_all_selection_all_emails_loading_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recover_deleted_message_loading_banner_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/filter_message_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/top_bar_thread_selection.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/styles/vacation_notification_message_widget_style.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_delete_all_spam_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_empty_trash_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_web_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
                    Obx(() {
                      final accountId = controller.accountId.value;
                      if (accountId == null) {
                        return const SizedBox.shrink();
                      } else {
                        return NavigationBarWidget(
                          imagePaths: controller.imagePaths,
                          avatarUserName: controller.sessionCurrent?.username.firstCharacter ?? '',
                          contactSupportCapability: controller.sessionCurrent?.getContactSupportCapability(accountId),
                          searchForm: SearchInputFormWidget(),
                          appGridController: controller.appGridDashboardController,
                          onTapApplicationLogoAction: controller.redirectToInboxAction,
                          onTapAvatarAction: (position) => controller.handleClickAvatarAction(context, position),
                          onTapContactSupportAction: (contactSupport) =>
                            controller.onGetHelpOrReportBug(contactSupport),
                        );
                      }
                    }),
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
                        const SizedBox(height: 16),
                        Obx(() => RecoverDeletedMessageLoadingBannerWidget(
                          isLoading: controller.isRecoveringDeletedMessage.value,
                          horizontalLoadingWidget: horizontalLoadingWidget,
                          responsiveUtils: controller.responsiveUtils,
                        )),
                        Obx(() => MarkMailboxAsReadLoadingBanner(
                          viewState: controller.viewStateMailboxActionProgress.value,
                        )),
                        const SpamReportBannerWebWidget(),
                        QuotasBannerWidget(),
                        _buildVacationNotificationMessage(context),
                        Obx(() {
                          final presentationMailbox = controller.selectedMailbox.value;
                          if (controller.isEmptyTrashBannerEnabledOnWeb(context, presentationMailbox)) {
                            return BannerEmptyTrashWidget(
                              onTapAction: controller.emptyTrashAction
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        Obx(() {
                          final presentationMailbox = controller.selectedMailbox.value;
                          if (controller.isEmptySpamBannerEnabledOnWeb(context, presentationMailbox)) {
                            return BannerDeleteAllSpamEmailsWidget(
                              onTapAction: () => controller.openDialogEmptySpamFolder(context)
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        _buildListButtonQuickSearchFilter(context),
                        Obx(() => MarkMailboxAsReadLoadingWidget(
                          viewState: controller.viewStateMailboxActionProgress.value,
                        )),
                        Obx(() => MarkAllAsUnreadSelectionAllEmailsLoadingWidget(
                          viewState: controller.viewStateSelectionActionProgress.value,
                        )),
                        Obx(() => MoveAllSelectionAllEmailsLoadingWidget(viewState: controller.moveAllSelectionAllEmailsViewState.value)),
                        Obx(() => DeleteAllPermanentlyEmailsLoadingWidget(viewState: controller.deleteAllPermanentlyEmailsViewState.value)),
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
        _buildDownloadTaskStateWidget(AppLocalizations.of(context)),
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
      margin: const EdgeInsetsDirectional.only(end: 16, bottom: 16),
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
                  listEmail: listEmailSelected,
                  mapMailbox: controller.mapMailboxById,
                  isSelectAllEmailsEnabled: controller.isSelectAllEmailsEnabled.value,
                  selectedMailbox: controller.selectedMailbox.value,
                  onCancelSelection: () =>
                    controller.dispatchAction(CancelSelectionAllEmailAction()),
                  onEmailActionTypeAction: (listEmails, actionType) =>
                    controller.dispatchAction(HandleEmailActionTypeAction(
                      listEmails,
                      actionType
                    )),
                  onMoreSelectedEmailAction: (position) => controller.dispatchAction(MoreSelectedEmailAction(context, position)),
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
        if (controller.isRefreshingAllMailboxAndEmail) {
          return TMailContainerWidget(
            borderRadius: 10,
            backgroundColor: AppColor.colorFilterMessageButton.withOpacity(0.6),
            padding: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8.5),
            child: const CupertinoLoadingWidget(size: 16));
        } else {
          return TMailButtonWidget.fromIcon(
            key: const Key('refresh_all_mailbox_and_email_button'),
            icon: controller.imagePaths.icRefresh,
            borderRadius: 10,
            iconSize: 16,
            backgroundColor: AppColor.colorFilterMessageButton.withOpacity(0.6),
            onTapActionCallback: controller.refreshMailboxAction,
          );
        }
      }),
      Obx(() {
        if (controller.emailsInCurrentMailbox.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Tooltip(
              message: AppLocalizations.of(context).selectAllMessagesOfThisPage,
              child: ElevatedButton.icon(
                onPressed: controller.selectAllEmailAction,
                icon: SvgPicture.asset(
                  controller.imagePaths.icSelectAll,
                  width: 16,
                  height: 16,
                  fit: BoxFit.fill,
                  colorFilter: AppColor.colorFilterMessageIcon.asFilter(),
                ),
                label: Text(
                  AppLocalizations.of(context).selectAllMessagesOfThisPage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.colorFilterMessageButton.withOpacity(0.6),
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 0.0,
                  foregroundColor: AppColor.colorTextButtonHeaderThread,
                  maximumSize: const Size.fromWidth(250),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColor.colorFilterMessageTitle
                  ),
                ),
              ),
            ),
          );
        }
      }),
      Obx(() {
        if (controller.isAbleMarkAllAsRead()) {
          return TMailButtonWidget(
            key: const Key('mark_as_read_emails_button'),
            text: AppLocalizations.of(context).mark_all_as_read,
            icon: controller.imagePaths.icSelectAll,
            iconColor: AppColor.colorFilterMessageIcon,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppColor.colorFilterMessageTitle),
            borderRadius: 10,
            margin: const EdgeInsetsDirectional.only(start: 16),
            iconSize: 16,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            onTapActionCallback: () => controller.markAsReadMailboxAction(context),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      Obx(() {
        final filterMessageCurrent = controller.filterMessageOption.value;

        if (controller.validateNoEmailsInTrashAndSpamFolder()) {
          return const SizedBox.shrink();
        } else {
          return Padding(
            padding: FilterMessageButtonStyle.buttonMargin,
            child: FilterMessageButton(
              filterMessageOption: filterMessageCurrent,
              imagePaths: controller.imagePaths,
              isSelected: filterMessageCurrent != FilterMessageOption.all,
              onSelectFilterMessageOptionAction: _onSelectFilterMessageOptionAction,
              onDeleteFilterMessageOptionAction: (_) => _onDeleteFilterMessageOptionAction(),
            ),
          );
        }
      }),
      Obx(() {
        if (controller.selectedMailbox.value?.isTrash == true) {
          return TMailButtonWidget.fromIcon(
            key: const Key('recover_deleted_messages_button'),
            icon: controller.imagePaths.icRecoverDeletedMessages,
            borderRadius: 10,
            iconSize: 16,
            backgroundColor: AppColor.colorFilterMessageButton.withOpacity(0.6),
            margin: const EdgeInsetsDirectional.only(start: 16),
            onTapActionCallback: () => controller.gotoEmailRecovery(),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      const Spacer(),
      Obx(() {
        if (controller.searchController.isSearchEmailRunning &&
            controller.dashboardRoute.value == DashboardRoutes.thread) {
          return _buildQuickSearchFilterButton(context, QuickSearchFilter.sortBy);
        } else {
          return const SizedBox.shrink();
        }
      })
    ]);
  }

  void _onSelectFilterMessageOptionAction(
    BuildContext context,
    FilterMessageOption filterMessageCurrent,
    RelativeRect buttonPosition
  ) {
    controller.openPopupMenuAction(
      context,
      buttonPosition,
      popupMenuFilterEmailActionTile(
        context,
        filterMessageCurrent,
        (filterMessageSelected) {
          controller.dispatchAction(FilterMessageAction(filterMessageSelected));
        },
        isSearchEmailRunning: controller.searchController.isSearchEmailRunning
      )
    );
  }

  void _onDeleteFilterMessageOptionAction() {
    controller.dispatchAction(FilterMessageAction(FilterMessageOption.all));
  }

  Widget _buildDownloadTaskStateWidget(AppLocalizations appLocalizations) {
    return Obx(() {
      final listDownloadTasks = controller.downloadController.listDownloadTaskState;
      final hideDownloadTaskbar = controller.downloadController.hideDownloadTaskbar;
      if (listDownloadTasks.isNotEmpty && !hideDownloadTaskbar.value) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: AppColor.colorBackgroundSnackBar,
            height: 60,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: listDownloadTasks.length,
                      separatorBuilder: (context, index) =>
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: VerticalDivider(
                            color: Colors.grey,
                            width: 2.5,
                            thickness: 0.2),
                        ),
                      itemBuilder: (context, index) =>
                          DownloadTaskItemWidget(listDownloadTasks[index])
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TMailButtonWidget.fromText(
                    text: appLocalizations.hide,
                    backgroundColor: Colors.transparent,
                    textStyle: const TextStyle(
                      color: AppColor.colorCancelButton,
                    ),
                    onTapActionCallback: () {
                      controller.downloadController.hideDownloadTaskbar.value = true;
                    },
                  ),
                ),
              ],
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
          margin: VacationNotificationMessageWidgetStyle.bannerMargin,
          vacationResponse: controller.vacationResponse.value!,
          actionGotoVacationSetting: controller.goToVacationSetting,
          actionEndNow: controller.disableVacationResponder);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildListButtonQuickSearchFilter(BuildContext context) {
    return Obx(() {
      if (controller.searchController.isSearchEmailRunning &&
          controller.dashboardRoute.value == DashboardRoutes.thread) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SizedBox(
                  height: 45,
                  child: ScrollbarListView(
                    scrollBehavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad
                      },
                      scrollbars: false
                    ),
                    scrollController: controller.listSearchFilterScrollController!,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: const EdgeInsetsDirectional.only(bottom: 10),
                      controller: controller.listSearchFilterScrollController!,
                      children: [
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.folder),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.from),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.to),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.dateTime),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.hasAttachment),
                      ],
                    ),
                  ),
                )
              ),
              if (controller.isSearchFilterHasApplied)
                TMailButtonWidget.fromText(
                  text: AppLocalizations.of(context).clearFilter,
                  backgroundColor: Colors.transparent,
                  margin: const EdgeInsetsDirectional.only(start: 8),
                  borderRadius: 10,
                  textStyle: const TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                  onTapActionCallback: controller.clearAllSearchFilterApplied)
              else
                TMailButtonWidget.fromText(
                  text: AppLocalizations.of(context).advancedSearch,
                  backgroundColor: Colors.transparent,
                  margin: const EdgeInsetsDirectional.only(start: 8),
                  borderRadius: 10,
                  textStyle: const TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                  onTapActionCallback: controller.openAdvancedSearchView)
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
    QuickSearchFilter searchFilter,
  ) {
    return Obx(() {
      final searchEmailFilter = controller.searchController.searchEmailFilter.value;
      final sortOrderType = controller.searchController.sortOrderFiltered;
      final listAddressOfFrom = controller.searchController.listAddressOfFromFiltered;
      final currentUserEmail = controller.sessionCurrent?.getOwnEmailAddress();
      final startDate = controller.searchController.startDateFiltered;
      final endDate = controller.searchController.endDateFiltered;
      final receiveTimeType = controller.searchController.receiveTimeFiltered;
      final mailbox = controller.searchController.mailboxFiltered;
      final listAddressOfTo = controller.searchController.listAddressOfToFiltered;

      final isSelected = searchFilter.isSelected(
        context,
        searchEmailFilter,
        sortOrderType,
        currentUserEmail);

      EdgeInsetsGeometry? buttonPadding;
      if (searchFilter != QuickSearchFilter.sortBy) {
        buttonPadding = MailboxDashboardViewWebStyle.getSearchFilterButtonPadding(isSelected);
      }

      return SearchFilterButton(
        key: Key('${searchFilter.name}_search_filter_button'),
        searchFilter: searchFilter,
        imagePaths: controller.imagePaths,
        responsiveUtils: controller.responsiveUtils,
        isSelected: isSelected,
        receiveTimeType: receiveTimeType,
        startDate: startDate,
        endDate: endDate,
        sortOrderType: sortOrderType,
        listAddressOfFrom: listAddressOfFrom,
        listAddressOfTo: listAddressOfTo,
        mailbox: mailbox,
        buttonPadding: buttonPadding,
        onSelectSearchFilterAction: _onSelectSearchFilterAction,
        onDeleteSearchFilterAction: controller.onDeleteSearchFilterAction,
      );
    });
  }

  Future<void> _onSelectSearchFilterAction(
    BuildContext context,
    QuickSearchFilter searchFilter,
    {RelativeRect? buttonPosition}
  ) async {
    switch(searchFilter) {
      case QuickSearchFilter.dateTime:
        if (buttonPosition != null) {
          _openPopupMenuDateFilter(context, buttonPosition);
        }
        break;
      case QuickSearchFilter.sortBy:
        if (buttonPosition != null) {
          _openPopupMenuSortFilter(context, buttonPosition);
        }
        break;
      case QuickSearchFilter.from:
        controller.selectFromSearchFilter(
          appLocalizations: AppLocalizations.of(context)
        );
        break;
      case QuickSearchFilter.hasAttachment:
        controller.selectHasAttachmentSearchFilter();
        break;
      case QuickSearchFilter.to:
        controller.selectToSearchFilter(
          appLocalizations: AppLocalizations.of(context)
        );
        break;
      case QuickSearchFilter.folder:
        controller.selectFolderSearchFilter();
        break;
      default:
        break;
    }
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
        controller.searchController.sortOrderFiltered,
        onCallBack: controller.selectSortOrderQuickSearchFilter
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
}