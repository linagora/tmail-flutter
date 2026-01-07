import 'package:core/core.dart';
import 'package:cozy/cozy_config_manager/cozy_config_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/base/widget/report_message_banner.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/composer_overlay_view.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_empty_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/select_search_filter_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/filter_message_button_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mailbox_dashboard_view_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/compose_button_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/download/download_task_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/mark_mailbox_as_read_loading_banner.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recover_deleted_message_loading_banner_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/filter_message_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/top_bar_thread_selection.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/styles/vacation_notification_message_widget_style.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_date_filter_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_sort_order_type_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/popup_menu_item_filter_message_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_web_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: controller.responsiveUtils,
            desktop: Scaffold(
              backgroundColor: AppColor.colorBgDesktop,
              body: Column(
                children: [
                  FutureBuilder(
                    future: CozyConfigManager().isInsideCozy,
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return const SizedBox.shrink();
                      }

                      return Obx(() {
                        final accountId = controller.accountId.value;
                        String accountDisplayName = controller.ownEmailAddress.value;
                        final contactSupportCapability = accountId != null
                          ? controller.sessionCurrent?.getContactSupportCapability(accountId)
                          : null;
                        if (accountDisplayName.trim().isEmpty) {
                          accountDisplayName = controller
                            .sessionCurrent
                            ?.getOwnEmailAddressOrUsername() ?? '';
                        }

                        return NavigationBarWidget(
                          imagePaths: controller.imagePaths,
                          accountId: accountId,
                          ownEmailAddress: accountDisplayName,
                          contactSupportCapability: contactSupportCapability,
                          searchForm: SearchInputFormWidget(),
                          appGridController:
                              controller.appGridDashboardController,
                          settingActionTypes: ProfileSettingActionType.values,
                          onTapApplicationLogoAction:
                              controller.redirectToInboxAction,
                          onTapContactSupportAction: (contactSupport) =>
                              controller.onGetHelpOrReportBug(contactSupport),
                          onProfileSettingActionTypeClick: (actionType) =>
                              controller.handleProfileSettingActionTypeClick(
                            context: context,
                            actionType: actionType,
                          ),
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            ComposeButtonWidget(
                              imagePaths: controller.imagePaths,
                              onTapAction: () =>
                                controller.openComposer(ComposerArguments()),
                            ),
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
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              FutureBuilder(
                                future: CozyConfigManager().isInsideCozy,
                                builder: (context, snapshot) {
                                  if (snapshot.data != true) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width * 0.4,
                                          height: 44,
                                          child: SearchInputFormWidget(
                                            fontSize: 15,
                                            contentPadding: const EdgeInsets.only(bottom: 4),
                                          ),
                                        ),
                                        const Spacer(),
                                        Obx(() {
                                          String accountDisplayName =
                                              controller.ownEmailAddress.value;
                                          if (accountDisplayName.trim().isEmpty) {
                                            accountDisplayName = controller
                                              .sessionCurrent
                                              ?.getOwnEmailAddressOrUsername() ?? '';
                                          }
                                          return ProfileSettingIcon(
                                            ownEmailAddress: accountDisplayName,
                                            settingActionTypes: ProfileSettingActionType.values,
                                            onProfileSettingActionTypeClick: (actionType) =>
                                              controller.handleProfileSettingActionTypeClick(
                                                context: context,
                                                actionType: actionType,
                                              ),
                                            isInsideCozy: true,
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                }
                              ),
                              Obx(() => RecoverDeletedMessageLoadingBannerWidget(
                                isLoading: controller.isRecoveringDeletedMessage.value,
                                horizontalLoadingWidget: horizontalLoadingWidget,
                                responsiveUtils: controller.responsiveUtils,
                              )),
                              Obx(() => MarkMailboxAsReadLoadingBanner(
                                viewState: controller.viewStateMailboxActionProgress.value,
                              )),
                              Obx(() {
                                final spamController = controller.spamReportController;

                                final isSpamReportDisabled = spamController.spamReportState.value == SpamReportState.disabled;

                                final isSpamFolderSelected = controller
                                    .selectedMailbox
                                    .value
                                    ?.isSpam == true;

                                final isPresentationSpamMailboxIsNull = spamController.presentationSpamMailbox.value == null;

                          final isEmailOpened = controller.dashboardRoute.value == DashboardRoutes.threadDetailed;

                          if (isSpamReportDisabled ||
                              isPresentationSpamMailboxIsNull ||
                              isSpamFolderSelected ||
                              isEmailOpened) {
                            return const SizedBox.shrink();
                          }

                                return ReportMessageBanner(
                                  imagePaths: controller.imagePaths,
                                  message: AppLocalizations
                                    .of(context)
                                    .countMessageInSpam(
                                      spamController.numberOfUnreadSpamEmails,
                                    ),
                                  positiveName: AppLocalizations.of(context).view,
                                  isDesktop: controller
                                      .responsiveUtils
                                      .isDesktop(context),
                                  margin: SpamReportBannerWebStyles.bannerMargin,
                                  onPositiveAction: spamController.openMailbox,
                                  onNegativeAction: () =>
                                      spamController.dismissSpamReportAction(context),
                                );
                              }),
                              QuotasBannerWidget(),
                              _buildVacationNotificationMessage(context),
                              Obx(() {
                                final selectedMailbox = controller
                                  .selectedMailbox
                                  .value;

                                bool showTrashBanner = controller
                                  .isEmptyTrashBannerEnabledOnWeb(
                                    context,
                                    selectedMailbox,
                                  );
                                bool showSpamBanner = controller
                                  .isEmptySpamBannerEnabledOnWeb(
                                    context,
                                    selectedMailbox,
                                  );

                                if (showTrashBanner) {
                                  return CleanMessagesBanner(
                                    responsiveUtils: controller.responsiveUtils,
                                    message: AppLocalizations
                                      .of(context)
                                      .message_delete_all_email_in_trash_button,
                                    positiveAction: AppLocalizations
                                      .of(context)
                                      .empty_trash_now,
                                    onPositiveAction: controller.emptyTrashAction,
                                    margin: const EdgeInsetsDirectional.only(
                                      bottom: 8,
                                      end: 16,
                                    ),
                                  );
                                } else if (showSpamBanner) {
                                  return CleanMessagesBanner(
                                    responsiveUtils: controller.responsiveUtils,
                                    message: AppLocalizations
                                      .of(context)
                                      .bannerDeleteAllSpamEmailsMessage,
                                    positiveAction: AppLocalizations
                                      .of(context)
                                      .deleteAllSpamEmailsNow,
                                    onPositiveAction: () =>
                                      controller.openDialogEmptySpamFolder(context),
                                    margin: const EdgeInsetsDirectional.only(
                                      bottom: 8,
                                      end: 16,
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              _buildListButtonQuickSearchFilter(context),
                              Expanded(
                                child: Obx(() {
                                  switch(controller.dashboardRoute.value) {
                                    case DashboardRoutes.thread:
                                      return _buildThreadViewForWebDesktop(context);
                                    case DashboardRoutes.threadDetailed:
                                      return const ThreadDetailView();
                                    default:
                                      return const SizedBox.shrink();
                                  }
                                }),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            tabletLarge: Obx(() {
              switch (controller.dashboardRoute.value) {
                case DashboardRoutes.searchEmail:
                  return SearchEmailView();
                case DashboardRoutes.threadDetailed:
                  return controller.searchController.isSearchEmailRunning
                      ? const ThreadDetailView()
                      : buildResponsiveWithDrawer(
                          left: ThreadView(),
                          right: const ThreadDetailView(),
                          mobile: const ThreadDetailView(),
                        );
                default:
                  return controller.searchController.isSearchEmailRunning
                      ? const ThreadDetailView()
                      : buildResponsiveWithDrawer(
                          left: ThreadView(),
                          right: const EmailViewEmptyWidget(),
                          mobile: ThreadView(),
                        );
              }
            }),
            mobile: Obx(() {
              switch(controller.dashboardRoute.value) {
                case DashboardRoutes.thread:
                  return buildScaffoldHaveDrawer(body: ThreadView());
                case DashboardRoutes.threadDetailed:
                  return const ThreadDetailView();
                case DashboardRoutes.searchEmail:
                  return SearchEmailView();
                default:
                  return buildScaffoldHaveDrawer(body: ThreadView());
              }
            }),
        ),
        Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: LayoutBuilder(
            builder: ((context, constraints) {
              log('MailboxDashBoardView::build:LayoutBuilder:Constraints = $constraints');
              final screenWidth = constraints.maxWidth;
              final composerManager = controller.composerManager;
              final isDesktopScreen = controller.responsiveUtils.isMatchedDesktopWidth(screenWidth);
              log('MailboxDashBoardView::build:ScreenWidth = $screenWidth | isDesktopScreen = $isDesktopScreen');

              if (isDesktopScreen)  {
                controller.hideMailboxMenuWhenScreenSizeChange();
              }

              if (composerManager.composers.isNotEmpty) {
                log('ComposerOverlayView::build:arrangeComposerWhenResponsiveChanged');
                composerManager.arrangeComposerWhenResponsiveChanged(screenWidth: screenWidth);
              }

              return ComposerOverlayView(
                composerManager: composerManager,
                isDesktopScreen: isDesktopScreen,
              );
            }),
          ),
        ),
        Obx(() => controller.searchMailboxActivated.value == true && !controller.responsiveUtils.isWebDesktop(context)
          ? const SearchMailboxView()
          : const SizedBox.shrink()
        ),
        _buildDownloadTaskStateWidget(AppLocalizations.of(context)),
      ]),
    );
  }

  Widget _buildThreadViewForWebDesktop(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 16, bottom: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
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
                  controller.imagePaths,
                  onCancelSelection: () =>
                    controller.dispatchAction(CancelSelectionAllEmailAction()),
                  onEmailActionTypeAction: (listEmails, actionType) =>
                    controller.dispatchAction(HandleEmailActionTypeAction(
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
        if (controller.isRefreshingAllMailboxAndEmail) {
          return TMailContainerWidget(
            borderRadius: 10,
            backgroundColor: AppColor.colorFilterMessageButton.withValues(alpha: 0.6),
            padding: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8.5),
            child: const CupertinoLoadingWidget(size: 16));
        } else {
          return TMailButtonWidget.fromIcon(
            key: const Key('refresh_all_mailbox_and_email_button'),
            icon: controller.imagePaths.icRefresh,
            borderRadius: 10,
            iconSize: 16,
            backgroundColor: AppColor.colorFilterMessageButton.withValues(alpha: 0.6),
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
                  overflow: TextOverflow.ellipsis,
                  style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColor.colorFilterMessageTitle,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.colorFilterMessageButton.withValues(alpha: 0.6),
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 0.0,
                  foregroundColor: AppColor.colorTextButtonHeaderThread,
                  maximumSize: const Size.fromWidth(250),
                  fixedSize: const Size.fromHeight(34),
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
        final filterMessageCurrent = controller.filterMessageOption.value;

        if (controller.validateNoEmailsInTrashAndSpamFolder() ||
            controller.searchController.isSearchEmailRunning) {
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
            backgroundColor: AppColor.colorFilterMessageButton.withValues(alpha: 0.6),
            margin: const EdgeInsetsDirectional.only(start: 16),
            onTapActionCallback: () => controller.gotoEmailRecovery(),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      Obx(() {
        if (controller.searchController.isSearchEmailRunning &&
            controller.dashboardRoute.value == DashboardRoutes.thread) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: _buildQuickSearchFilterButton(
              context,
              QuickSearchFilter.sortBy,
            ),
          );
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
    final popupMenuItems = [
      if (!controller.searchController.isSearchEmailRunning)
        FilterMessageOption.attachments,
      FilterMessageOption.unread,
      if (controller.selectedMailbox.value?.isFavorite != true)
        FilterMessageOption.starred,
    ].map((filterOption) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: PopupMenuItemFilterMessageAction(
            filterOption,
            filterMessageCurrent,
            AppLocalizations.of(context),
            controller.imagePaths,
          ),
          menuActionClick: (menuAction) {
            popBack();
            controller.dispatchAction(FilterMessageAction(menuAction.action));
          },
        ),
      );
    }).toList();

    controller.openPopupMenu(context, buttonPosition, popupMenuItems);
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
                    textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
      final vacation = controller.vacationResponse.value;
      if (vacation?.vacationResponderIsValid == true) {
        return VacationNotificationMessageWidget(
          margin: VacationNotificationMessageWidgetStyle.bannerMargin,
          vacationResponse: vacation!,
          actionGotoVacationSetting: controller.goToVacationSetting,
          actionEndNow: controller.disableVacationResponder,
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildListButtonQuickSearchFilter(BuildContext context) {
    return Obx(() {
      final isSearchEmailRunning =
          controller.searchController.isSearchEmailRunning;
      final isThreadRoute =
          controller.dashboardRoute.value == DashboardRoutes.thread;
      final isLabelAvailable = controller.isLabelAvailable;

      if (isSearchEmailRunning && isThreadRoute) {
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
                        if (isLabelAvailable)
                          ...[
                            _buildQuickSearchFilterButton(
                              context,
                              QuickSearchFilter.labels,
                            ),
                            MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                          ],
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.from),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.to),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.dateTime),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.hasAttachment),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.starred),
                        MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
                        _buildQuickSearchFilterButton(context, QuickSearchFilter.unread),
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
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
      final currentUserEmail = controller.sessionCurrent?.getOwnEmailAddressOrEmpty();
      final startDate = controller.searchController.startDateFiltered;
      final endDate = controller.searchController.endDateFiltered;
      final receiveTimeType = controller.searchController.receiveTimeFiltered;
      final mailbox = controller.searchController.mailboxFiltered;
      final label = controller.searchController.labelFiltered;
      final listAddressOfTo = controller.searchController.listAddressOfToFiltered;
      final listHasKeywordFiltered = controller.searchController.listHasKeywordFiltered;
      final unreadFiltered = controller.searchController.unreadFiltered;

      final isSelected = searchFilter.isSelected(
        context,
        searchEmailFilter,
        sortOrderType,
        currentUserEmail);

      EdgeInsetsGeometry? buttonPadding;
      if (searchFilter != QuickSearchFilter.sortBy) {
        buttonPadding = MailboxDashboardViewWebStyle.getSearchFilterButtonPadding(isSelected);
      }

      final isFilterApplied = listAddressOfFrom.isNotEmpty ||
          listAddressOfTo.isNotEmpty ||
          startDate != null ||
          endDate != null ||
          receiveTimeType != EmailReceiveTimeType.allTime ||
          mailbox != null ||
          listHasKeywordFiltered.contains(KeyWordIdentifier.emailFlagged.value) ||
          unreadFiltered;

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
        label: label,
        buttonPadding: buttonPadding,
        backgroundColor: searchFilter == QuickSearchFilter.sortBy
          ? isSelected
              ? AppColor.primaryColor.withValues(alpha: 0.06)
              : AppColor.colorFilterMessageButton.withValues(alpha: 0.6)
          : null,
        isContextMenuAlignEndButton:
          searchFilter != QuickSearchFilter.labels && isFilterApplied,
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
      case QuickSearchFilter.starred:
        controller.selectStarredSearchFilter();
        break;
      case QuickSearchFilter.unread:
        controller.selectUnreadSearchFilter();
        break;
      case QuickSearchFilter.labels:
        final listLabels = controller.labelController.labels;
        final selectedLabel = controller.searchController.labelFiltered;

        controller.openLabelsFilterModal(
          context: context,
          position: buttonPosition,
          labels: listLabels,
          selectedLabel: selectedLabel,
          imagePaths: controller.imagePaths,
          onSelectLabelsActions: controller.onSelectLabelFilter,
        );
        break;
      default:
        break;
    }
  }

  void _openPopupMenuDateFilter(BuildContext context, RelativeRect position) {
    final popupMenuItems = EmailReceiveTimeType.valuesForSearch.map((timeType) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: PopupMenuItemDateFilterAction(
            timeType,
            controller.searchController.receiveTimeFiltered,
            AppLocalizations.of(context),
            controller.imagePaths,
          ),
          menuActionClick: (menuAction) {
            popBack();
            controller.selectReceiveTimeQuickSearchFilter(
              context,
              menuAction.action,
            );
          },
        ),
      );
    }).toList();

    controller.openPopupMenu(context, position, popupMenuItems);
  }

  void _openPopupMenuSortFilter(BuildContext context, RelativeRect position) {
    final popupMenuItems = EmailSortOrderType.values.map((sortType) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: PopupMenuItemSortOrderTypeAction(
            sortType,
            controller.searchController.sortOrderFiltered,
            AppLocalizations.of(context),
            controller.imagePaths,
          ),
          menuActionClick: (menuAction) {
            popBack();
            controller.selectSortOrderQuickSearchFilter(menuAction.action);
          },
        ),
      );
    }).toList();

    controller.openPopupMenu(context, position, popupMenuItems);
  }
}