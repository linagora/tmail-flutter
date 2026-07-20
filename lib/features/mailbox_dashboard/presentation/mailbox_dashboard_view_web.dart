import 'package:core/core.dart';
import 'package:cozy/cozy_config_manager/cozy_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/base/widget/report_message_banner.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/web/composer_overlay_view.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_empty_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/dialogs/empty_trash_confirmation_dialog.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/select_search_filter_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_date_filter_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_sort_order_type_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/compose_button_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/download/download_task_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/empty_trash_banner_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/mark_mailbox_as_read_loading_banner.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recover_deleted_message_loading_banner_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/quick_search_filter_bar.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/thread_list_action_bar.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/top_bar_thread_selection.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/quick_search_filter_action_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/styles/vacation_notification_message_widget_style.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_view.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/popup_menu_item_filter_message_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/spam_banner/spam_report_banner_web_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/empty_folder_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/riverpod_widgets/mailbox_dashboard_provider_listener_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef BuildQuickFilterMenuAction<T> = PopupMenuItemAction<T> Function(T value);
typedef OnQuickFilterValueSelected<T> = void Function(T value);

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Portal(
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
                              key: const ValueKey(UiKeys.composeEmailButton),
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

                                if (showTrashBanner && selectedMailbox != null) {
                                  return _buildEmptyTrashBanner(selectedMailbox);
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
                                  return const SizedBox.shrink(key: Key(UiKeys.cleanMessageBannerNotVisible));
                                }
                              }),
                              QuickSearchFilterBar(
                                onSelectSearchFilterAction: _onSelectSearchFilterAction,
                                onDeleteSearchFilterAction: _onDeleteSearchFilterAction,
                              ),
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
            tabletLarge: Consumer(builder: (context, ref, _) {
              final searchViewState = ref.watch(searchViewStateProvider);
              return Obx(() {
                switch (controller.dashboardRoute.value) {
                  case DashboardRoutes.searchEmail:
                    return const SearchEmailView();
                  case DashboardRoutes.threadDetailed:
                    return searchViewState.isSearchEmailRunning
                        ? const ThreadDetailView()
                        : buildResponsiveWithDrawer(
                            left: ThreadView(),
                            right: const ThreadDetailView(),
                            mobile: const ThreadDetailView(),
                          );
                  default:
                    return searchViewState.isSearchEmailRunning
                        ? const ThreadDetailView()
                        : buildResponsiveWithDrawer(
                            left: ThreadView(),
                            right: const EmailViewEmptyWidget(),
                            mobile: ThreadView(),
                          );
                }
              });
            }),
            mobile: Obx(() {
              switch(controller.dashboardRoute.value) {
                case DashboardRoutes.thread:
                  return buildScaffoldHaveDrawer(body: ThreadView());
                case DashboardRoutes.threadDetailed:
                  return const ThreadDetailView();
                case DashboardRoutes.searchEmail:
                  return const SearchEmailView();
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
    return MailboxDashboardProviderListenerWidget(
      delegateFactories: const [EmptyFolderProviderListenerDelegate.trash],
      child: child,
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
                  isLabelAvailable: controller.isLabelAvailable,
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
                child: ThreadListActionBar(
                  onSelectFilterMessageOptionAction: _onSelectFilterMessageOptionAction,
                  onDeleteFilterMessageOptionAction: (_) => _onDeleteFilterMessageOptionAction(),
                  onSelectSearchFilterAction: _onSelectSearchFilterAction,
                  onDeleteSearchFilterAction: _onDeleteSearchFilterAction,
                ),
              );
            }
          }),
          const Divider(),
          Expanded(child: ThreadView())
        ]),
      ),
    );
  }

  void _onSelectFilterMessageOptionAction(
    BuildContext context,
    FilterMessageOption filterMessageCurrent,
    RelativeRect buttonPosition
  ) {
    final popupMenuItems = [
      if (!appProviderContainer
          .read(searchViewStateProvider)
          .isSearchEmailRunning)
        FilterMessageOption.attachments,
      if (controller.selectedMailbox.value?.isActionRequired != true)
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

  Widget _buildEmptyTrashBanner(PresentationMailbox mailbox) {
    return EmptyTrashBannerWidget(
      responsiveUtils: controller.responsiveUtils,
      mailbox: mailbox,
      confirmCallback: (ctx, mailbox) => EmptyTrashConfirmationDialog.show(
        ctx,
        responsiveUtils: controller.responsiveUtils,
        onConfirm: () => controller.emptyTrashFolderAction(trashMailbox: mailbox),
      ),
      margin: const EdgeInsetsDirectional.only(bottom: 8, end: 16),
    );
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

  void _onSelectSearchFilterAction(
    BuildContext context,
    WidgetRef ref,
    QuickSearchFilter searchFilter,
    {RelativeRect? buttonPosition}
  ) {
    final notifier = ref.read(quickSearchFilterActionProvider.notifier);
    switch (searchFilter) {
      case QuickSearchFilter.dateTime:
        _openReceiveTimeQuickFilterMenu(context, ref, notifier, buttonPosition);
      case QuickSearchFilter.sortBy:
        _openSortOrderQuickFilterMenu(context, ref, notifier, buttonPosition);
      case QuickSearchFilter.from:
        controller.selectFromSearchFilter(
          appLocalizations: AppLocalizations.of(context),
          searchFilterActionNotifier: notifier,
        );
      case QuickSearchFilter.to:
        controller.selectToSearchFilter(
          appLocalizations: AppLocalizations.of(context),
          searchFilterActionNotifier: notifier,
        );
      case QuickSearchFilter.folder:
        controller.selectFolderSearchFilter(notifier);
      case QuickSearchFilter.labels:
        _openLabelsQuickFilterModal(context, ref, notifier, buttonPosition);
      case QuickSearchFilter.hasAttachment:
      case QuickSearchFilter.starred:
      case QuickSearchFilter.unread:
      case QuickSearchFilter.events:
        notifier.selectQuickSearchFilter(searchFilter);
      case QuickSearchFilter.last7Days:
      case QuickSearchFilter.fromMe:
        break;
    }
  }

  void _openReceiveTimeQuickFilterMenu(
    BuildContext context,
    WidgetRef ref,
    QuickSearchFilterActionNotifier notifier,
    RelativeRect? buttonPosition,
  ) {
    final receiveTimeFiltered =
        ref.read(searchFilterProvider).emailReceiveTimeType;
    _openQuickFilterPopupMenu<EmailReceiveTimeType>(
      context,
      buttonPosition,
      EmailReceiveTimeType.valuesForSearch,
      (value) => PopupMenuItemDateFilterAction(
        value,
        receiveTimeFiltered,
        AppLocalizations.of(context),
        controller.imagePaths,
      ),
      (value) => controller.selectReceiveTimeQuickSearchFilter(
        context,
        value,
        notifier,
      ),
    );
  }

  void _openSortOrderQuickFilterMenu(
    BuildContext context,
    WidgetRef ref,
    QuickSearchFilterActionNotifier notifier,
    RelativeRect? buttonPosition,
  ) {
    final sortOrderFiltered = ref.read(searchFilterProvider).sortOrderType;
    _openQuickFilterPopupMenu<EmailSortOrderType>(
      context,
      buttonPosition,
      EmailSortOrderType.values,
      (value) => PopupMenuItemSortOrderTypeAction(
        value,
        sortOrderFiltered,
        AppLocalizations.of(context),
        controller.imagePaths,
      ),
      (value) => controller.selectSortOrderQuickSearchFilter(value, notifier),
    );
  }

  void _openLabelsQuickFilterModal(
    BuildContext context,
    WidgetRef ref,
    QuickSearchFilterActionNotifier notifier,
    RelativeRect? buttonPosition,
  ) {
    controller.openLabelsFilterModal(
      context: context,
      position: buttonPosition,
      labels: controller.labelController.labels,
      selectedLabel: ref.read(searchFilterProvider).label,
      imagePaths: controller.imagePaths,
      onSelectLabelsActions: (newLabel) =>
          notifier.mutateAndSearch((filter) => filter.setLabel(newLabel)),
    );
  }

  void _openQuickFilterPopupMenu<T>(
    BuildContext context,
    RelativeRect? buttonPosition,
    Iterable<T> menuValues,
    BuildQuickFilterMenuAction<T> buildMenuAction,
    OnQuickFilterValueSelected<T> onSelected,
  ) {
    if (buttonPosition == null) return;

    final popupMenuItems = menuValues.map<PopupMenuEntry>((value) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: buildMenuAction(value),
          menuActionClick: (_) {
            popBack();
            onSelected(value);
          },
        ),
      );
    }).toList();

    controller.openPopupMenu(context, buttonPosition, popupMenuItems);
  }

  void _onDeleteSearchFilterAction(
    WidgetRef ref,
    QuickSearchFilter searchFilter,
  ) {
    controller.onDeleteSearchFilterAction(
      ref.read(quickSearchFilterActionProvider.notifier),
      searchFilter,
    );
  }
}
