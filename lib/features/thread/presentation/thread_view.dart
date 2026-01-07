import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/model/label.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/base/widget/keyboard/keyboard_handler_wrapper.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_action_group_widget.dart';
import 'package:tmail_ui_user/features/base/widget/report_message_banner.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recover_deleted_message_loading_banner_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_banner_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/clean_and_get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_keyboard_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_open_context_menu_filter_email_action_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_press_email_selection_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_pull_to_refresh_list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_select_message_filter_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_shift_selection_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/scroll_to_top_button_widget_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/thread_view_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/scroll_to_top_button_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/thread_view_loading_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadView extends GetWidget<ThreadController>
  with AppLoaderMixin, PopupMenuWidgetMixin {

  ThreadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Portal(
        child: Row(children: [
          if (_supportVerticalDivider(context))
            const VerticalDivider(),
          Expanded(child: SafeArea(
              right: controller.responsiveUtils.isLandscapeMobile(context),
              left: controller.responsiveUtils.isLandscapeMobile(context),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!controller.responsiveUtils.isWebDesktop(context))
                      ... [
                        Obx(() {
                          return MobileAppBarThreadWidget(
                            responsiveUtils: controller.responsiveUtils,
                            imagePaths: controller.imagePaths,
                            mailboxSelected: controller.selectedMailbox,
                            listEmailSelected: controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected,
                            selectMode: controller.mailboxDashBoardController.currentSelectMode.value,
                            filterOption: controller.mailboxDashBoardController.filterMessageOption.value,
                            openMailboxAction: controller.openMailboxLeftMenu,
                            onCancelSelectionAction: controller.cancelSelectEmail,
                            onContextMenuFilterEmailAction: controller.responsiveUtils.isScreenWithShortestSide(context)
                              ? (filterOption) => controller.handleSelectMessageFilter(context, filterOption)
                              : null,
                            onPopupMenuFilterEmailAction: !controller.responsiveUtils.isScreenWithShortestSide(context)
                              ? (filterOption, position) => controller.handleOpenContextMenuFilterEmailAction(context, position, filterOption)
                              : null,
                            onPressEmailSelectionActionClick: (type, emails) =>
                                controller.handlePressEmailSelectionAction(
                                  context,
                                  type,
                                  emails,
                                  controller.selectedMailbox,
                                ),
                            );
                        }),
                        if (PlatformInfo.isMobile)
                          Obx(() {
                            if (!controller.networkConnectionController.isNetworkConnectionAvailable()) {
                              return NetworkConnectionBannerWidget();
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                        SearchBarView(
                          key: const Key('email_search_bar_view'),
                          imagePaths: controller.imagePaths,
                          margin: ThreadViewStyle.getBannerMargin(
                            context,
                            controller.responsiveUtils),
                          hintTextSearch: AppLocalizations.of(context).search_emails,
                          onOpenSearchViewAction: controller.goToSearchView
                        ),
                        Obx(() {
                          final spamController = controller
                              .mailboxDashBoardController
                              .spamReportController;

                          final isSpamReportDisabled = spamController.spamReportState.value == SpamReportState.disabled;

                          final isSpamFolderSelected = controller
                              .mailboxDashBoardController
                              .selectedMailbox
                              .value
                              ?.isSpam == true;

                          final isPresentationSpamMailboxIsNull = spamController.presentationSpamMailbox.value == null;

                          if (isSpamReportDisabled ||
                            isPresentationSpamMailboxIsNull ||
                            isSpamFolderSelected) {
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
                            margin: ThreadViewStyle.getBannerMargin(
                              context,
                              controller.responsiveUtils,
                            ),
                            isDesktop: controller
                              .responsiveUtils
                              .isDesktop(context),
                            onPositiveAction: spamController.openMailbox,
                            onNegativeAction: () =>
                              spamController.dismissSpamReportAction(
                                context,
                              ),
                          );
                        }),
                        QuotasBannerWidget(),
                        Obx(() {
                          final vacation = controller.mailboxDashBoardController.vacationResponse.value;
                          if (vacation?.vacationResponderIsValid == true) {
                            return VacationNotificationMessageWidget(
                              margin: ThreadViewStyle.getBannerMargin(
                                context,
                                controller.responsiveUtils),
                              vacationResponse: vacation!,
                              actionGotoVacationSetting: controller.mailboxDashBoardController.goToVacationSetting,
                              actionEndNow: controller.mailboxDashBoardController.disableVacationResponder
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        Obx(() => RecoverDeletedMessageLoadingBannerWidget(
                              isLoading: controller.mailboxDashBoardController.isRecoveringDeletedMessage.value,
                              horizontalLoadingWidget: horizontalLoadingWidget,
                              responsiveUtils: controller.responsiveUtils,
                          )),
                      ],
                    Obx(() {
                      final dashboardController = controller
                        .mailboxDashBoardController;
                      final selectedMailbox = dashboardController
                        .selectedMailbox
                        .value;

                      bool showTrashBanner = dashboardController
                        .isEmptyTrashBannerEnabledOnMobile(
                          context,
                          selectedMailbox,
                        );
                      bool showSpamBanner = dashboardController
                        .isEmptySpamBannerEnabledOnMobile(
                          context,
                          selectedMailbox,
                        );

                      if (showTrashBanner) {
                        return CleanMessagesBanner(
                          responsiveUtils: controller.responsiveUtils,
                          key: const Key('empty_trash_banner'),
                          message: AppLocalizations
                            .of(context)
                            .message_delete_all_email_in_trash_button,
                          positiveAction: AppLocalizations
                            .of(context)
                            .empty_trash_now,
                          onPositiveAction: () =>
                            controller.deleteSelectionEmailsPermanently(
                              context,
                              DeleteActionType.all,
                            ),
                          margin: ThreadViewStyle.getBannerMargin(
                            context,
                            controller.responsiveUtils,
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
                          onPositiveAction: () => controller
                            .mailboxDashBoardController
                            .openDialogEmptySpamFolder(context),
                          margin: ThreadViewStyle.getBannerMargin(
                            context,
                            controller.responsiveUtils,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink(
                          key: Key('clean_message_banner_not_visible'),
                        );
                      }
                    }),
                    if (!controller.responsiveUtils.isDesktop(context))
                      _buildMailboxActionProgressBanner(context),
                    Obx(() => ThreadViewLoadingBarWidget(viewState: controller.viewState.value)),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Obx(() {
                          return Visibility(
                            visible: controller.openingEmail.isFalse,
                            child: _buildResultListEmail(
                              context,
                              controller.mailboxDashBoardController.emailsInCurrentMailbox
                            )
                          );
                        })
                      )
                    ),
                  ]
              )
          ))
        ]),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(end: 4.0),
            child: ScrollToTopButtonWidget(
              scrollController: controller.listEmailController,
              onTap: controller.scrollToTop,
              responsiveUtils: controller.responsiveUtils,
              icon: SvgPicture.asset(
                controller.imagePaths.icArrowUpOutline,
                width: ScrollToTopButtonWidgetStyles.iconWidth,
                height: ScrollToTopButtonWidgetStyles.iconHeight,
                fit: BoxFit.fill,
                colorFilter: Colors.white.asFilter(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildFloatingButtonCompose(context),
        ],
      ),
    );

    if (PlatformInfo.isWeb && controller.keyboardFocusNode != null) {
      return KeyboardHandlerWrapper(
        onKeyDownEventAction: controller.onKeyDownEventAction,
        onKeyUpEventAction: controller.onKeyUpEventAction,
        focusNode: controller.keyboardFocusNode!,
        child: bodyWidget,
      );
    } else {
      return bodyWidget;
    }
  }

  bool _supportVerticalDivider(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return controller.responsiveUtils.isTabletLarge(context);
    } else {
      return controller.responsiveUtils.isDesktop(context) ||
        controller.responsiveUtils.isTabletLarge(context) ||
        controller.responsiveUtils.isLandscapeTablet(context);
    }
  }

  Widget _buildFloatingButtonCompose(BuildContext context) {
    if (controller.responsiveUtils.isWebDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isAdvancedSearchViewOpen = controller.searchController.isAdvancedSearchViewOpen.value;
      final isTrashViewOpen = controller.isMailboxTrash;
      final isSelectModeActive = controller.mailboxDashBoardController.currentSelectMode.value == SelectMode.ACTIVE;
      if (
        !controller.searchController.isSearchActive()
        && !isAdvancedSearchViewOpen
        && !isTrashViewOpen
        && !isSelectModeActive
      ) {
        return Container(
          padding: PlatformInfo.isMobile && controller.listEmailSelected.isNotEmpty
            ? EdgeInsets.only(bottom: controller.responsiveUtils.isTabletLarge(context) ? 85 : 70)
            : EdgeInsets.zero,
          child: ComposeFloatingButton(
            scrollController: controller.listEmailController,
            onTap: () => controller.mailboxDashBoardController.openComposer(ComposerArguments())
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildResultListEmail(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    return listPresentationEmail.isNotEmpty
        ? _buildListEmailBody(context, listPresentationEmail)
        : _buildEmptyEmail(context);
  }

  Widget _buildListEmailBody(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    Widget listView = ListView.separated(
      key: const PageStorageKey('list_presentation_email_in_threads'),
      controller: controller.listEmailController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: listPresentationEmail.length + 2,
      itemBuilder: (context, index) => Obx(() {
        if (index == listPresentationEmail.length) {
          return _buildLoadMoreButton(
            context,
            controller.loadingMoreStatus.value,
          );
        }
        if (index == listPresentationEmail.length + 1) {
          return _buildLoadMoreProgressBar(controller.loadingMoreStatus.value);
        }

        if (PlatformInfo.isMobile) {
          return _buildEmailItemNotDraggable(
            context,
            listPresentationEmail[index],
          );
        } else {
          return _buildEmailItem(
            context,
            listPresentationEmail[index],
          );
        }
      }),
      separatorBuilder: (context, index) {
        if (PlatformInfo.isMobile) {
          if (index < listPresentationEmail.length - 1) {
            return Padding(
              padding: ItemEmailTileStyles.getMobilePaddingItemList(
                context,
                controller.responsiveUtils,
              ),
              child: const Divider(),
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return Padding(
            padding: ItemEmailTileStyles.getPaddingDividerWeb(
              context,
              controller.responsiveUtils,
            ),
            child: Divider(
              color: index < listPresentationEmail.length - 1 && controller.mailboxDashBoardController.currentSelectMode.value == SelectMode.INACTIVE
                ? null
                : Colors.white,
            ),
          );
        }
      },
    );

    if (!controller.mailboxDashBoardController.isSelectionEnabled()) {
      listView = PullToRefreshWidget(
        onNormalRefresh: controller.onRefresh,
        onDeepRefresh: controller.onCleanAndRefresh,
        pullDownToRefreshText: AppLocalizations.of(context).pullDownToRefresh,
        normalRefreshText: AppLocalizations.of(context).refresh,
        deepRefreshText: AppLocalizations.of(context).deepRefresh,
        pullHarderForText: AppLocalizations.of(context).pullHarderFor,
        child: listView,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotificationListener,
      child: listView,
    );
  }

  bool _handleScrollNotificationListener(ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollEndNotification &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
        !controller.loadingMoreStatus.value.isRunning &&
        scrollInfo.metrics.axisDirection == AxisDirection.down
    ) {
      controller.handleLoadMoreEmailsRequest();
    }
    return false;
  }

  Widget _buildLoadMoreButton(BuildContext context, LoadingMoreStatus loadingMoreStatus) {
    if (((controller.canLoadMore && !controller.isSearchActive) ||
        (controller.canSearchMore && controller.isSearchActive)) &&
        !loadingMoreStatus.isRunning) {
      return Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: controller.handleLoadMoreEmailsRequest,
          child: Text(
            AppLocalizations.of(context).loadMore,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black
            )
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadMoreProgressBar(LoadingMoreStatus loadingMoreStatus) {
    if (loadingMoreStatus.isRunning) {
      return const CupertinoLoadingWidget();
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmailItem(BuildContext context, PresentationEmail presentationEmail) {
    if (controller.responsiveUtils.isWebDesktop(context)) {
      return _buildEmailItemDraggable(context, presentationEmail);
    } else {
      return _buildEmailItemNotDraggable(context, presentationEmail);
    }
  }

  Widget _buildEmailItemDraggable(BuildContext context, PresentationEmail presentationEmail) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (_) {},
      onTapDown: (_) {},
      child: Draggable<List<PresentationEmail>>(
        data: controller.listEmailDrag,
        feedback: _buildFeedBackWidget(context),
        childWhenDragging: _buildEmailItemWhenDragging(context, presentationEmail),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: () {
          controller.calculateDragValue(presentationEmail);
          controller.onDragMailBox(true);
        },
        onDragEnd: (_) => controller.onDragMailBox(false),
        onDraggableCanceled: (_,__) => controller.onDragMailBox(false),
        child: _buildEmailItemNotDraggable(context, presentationEmail)
      ),
    );
  }

  Widget _buildEmailItemWhenDragging(BuildContext context, PresentationEmail presentationEmail) {
    final isShowingEmailContent = controller.mailboxDashBoardController.selectedEmail.value?.id == presentationEmail.id;
    final selectModeAll = controller.mailboxDashBoardController.currentSelectMode.value;
    final isSenderImportantFlagEnabled =
        controller.mailboxDashBoardController.isSenderImportantFlagEnabled.value;

    return EmailTileBuilder(
      key: Key('email_tile_builder_${presentationEmail.id?.asString}'),
      presentationEmail: presentationEmail,
      selectAllMode: selectModeAll,
      isShowingEmailContent: isShowingEmailContent,
      searchQuery: controller.searchQuery,
      mailboxContain: presentationEmail.mailboxContain,
      isSearchEmailRunning: controller.searchController.isSearchEmailRunning,
      isDrag: true,
      isSenderImportantFlagEnabled: isSenderImportantFlagEnabled,
    );
  }

  Widget _buildEmailItemNotDraggable(BuildContext context, PresentationEmail presentationEmail) {
    final isShowingEmailContent = controller.mailboxDashBoardController.selectedEmail.value?.id == presentationEmail.id;
    final selectModeAll = controller.mailboxDashBoardController.currentSelectMode.value;
    final isSenderImportantFlagEnabled =
      controller.mailboxDashBoardController.isSenderImportantFlagEnabled.value;

    return Dismissible(
      key: ValueKey<EmailId?>(presentationEmail.id),
      direction: controller.getSwipeDirection(
        controller.responsiveUtils.isWebDesktop(context),
        selectModeAll,
        presentationEmail
      ),
      background: Container(
        color: AppColor.colorItemRecipientSelected,
        padding: const EdgeInsetsDirectional.only(start: 16),
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColor.colorSpamReportBannerBackground,
              radius: 24,
              child: !presentationEmail.hasRead
                  ? SvgPicture.asset(
                      controller.imagePaths.icMarkAsRead,
                      fit: BoxFit.fill,
                    )
                  : SvgPicture.asset(
                      controller.imagePaths.icUnreadEmail,
                      fit: BoxFit.fill,
                      colorFilter: AppColor.primaryColor.asFilter(),
                    ),
            ),
            const SizedBox(width: 11),
            Text(
              !presentationEmail.hasRead
                ? AppLocalizations.of(context).mark_as_read
                : AppLocalizations.of(context).mark_as_unread,
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 15,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: controller.isInArchiveMailbox(presentationEmail) == false
        ? Container(
            color: AppColor.colorItemRecipientSelected,
            padding: const EdgeInsetsDirectional.only(end: 16),
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              children: [
                const Spacer(),
                CircleAvatar(
                  backgroundColor: AppColor.colorSpamReportBannerBackground,
                  radius: 24,
                  child: SvgPicture.asset(
                    controller.imagePaths.icMailboxArchived,
                    fit: BoxFit.fill,
                  )
                ),
                const SizedBox(width: 11),
                Text(
                  AppLocalizations.of(context).archiveMessage,
                  style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontSize: 15,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          )
        : null,
      confirmDismiss: (direction) => controller.swipeEmailAction(
        presentationEmail,
        direction,
      ),
      child: Obx(() {
        final isLabelAvailable = controller
            .mailboxDashBoardController.isLabelAvailable;

        final listLabels =
            controller.mailboxDashBoardController.labelController.labels;

        List<Label>? emailLabels;

        if (isLabelAvailable) {
          emailLabels = presentationEmail.getLabelList(listLabels);
        }

        return EmailTileBuilder(
          key: Key('email_tile_builder_${presentationEmail.id?.asString}'),
          presentationEmail: presentationEmail,
          selectAllMode: selectModeAll,
          isShowingEmailContent: isShowingEmailContent,
          isSenderImportantFlagEnabled: isSenderImportantFlagEnabled,
          searchQuery: controller.searchQuery,
          mailboxContain: presentationEmail.mailboxContain,
          isSearchEmailRunning: controller.searchController.isSearchEmailRunning,
          labels: emailLabels,
          emailActionClick: _handleEmailActionClicked,
          onMoreActionClick: (email, position) =>
              _handleEmailContextMenuAction(context, email, position),
        );
      }),
    );
  }

  void _handleEmailActionClicked(
    EmailActionType actionType,
    PresentationEmail presentationEmail
  ) {
    controller.handleEmailActionType(
      actionType,
      presentationEmail,
      mailboxContain: presentationEmail.mailboxContain,
    );
  }

  Future<void> _handleEmailContextMenuAction(
    BuildContext context,
    PresentationEmail presentationEmail,
    RelativeRect? position
  ) {
    final mailboxContain = presentationEmail.mailboxContain;
    final isDrafts = mailboxContain?.isDrafts ?? false;
    final isChildOfTeamMailboxes =
        mailboxContain?.isChildOfTeamMailboxes ?? false;
    final isSpam = mailboxContain?.isSpam ?? false;
    final isArchive = mailboxContain?.isArchive ?? false;
    final isTemplates = mailboxContain?.isTemplates ?? false;
    final isRead = presentationEmail.hasRead;
    final isTrash = mailboxContain?.isTrash ?? false;
    final canPermanentlyDelete = isDrafts || isSpam || isTrash;

    final listEmailActions = [
      isRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
      EmailActionType.moveToMailbox,
      canPermanentlyDelete ? EmailActionType.deletePermanently : EmailActionType.moveToTrash,
      EmailActionType.openInNewTab,
      if (!isDrafts && !isChildOfTeamMailboxes)
        isSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
      if (!isArchive) EmailActionType.archiveMessage,
      if (!isDrafts && !isTemplates) EmailActionType.editAsNewEmail,
    ];

    if (position == null) {
      final contextMenuActions = listEmailActions
          .map((action) => ContextItemEmailAction(
                action,
                AppLocalizations.of(context),
                controller.imagePaths,
                category: action.category,
              ))
          .toList();

      return controller.mailboxDashBoardController.openBottomSheetContextMenu(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          popBack();
          controller.handleEmailActionType(
            menuAction.action,
            presentationEmail,
            mailboxContain: presentationEmail.mailboxContain,
          );
        },
        useGroupedActions: true,
      );
    } else {
      final popupMenuItemEmailActions = listEmailActions.map((actionType) {
        return PopupMenuItemEmailAction(
          actionType,
          AppLocalizations.of(context),
          controller.imagePaths,
          category: actionType.category,
        );
      }).toList();

      final popupMenuWidget = PopupMenuActionGroupWidget(
        actions: popupMenuItemEmailActions,
        onActionSelected: (action) {
          controller.handleEmailActionType(
            action.action,
            presentationEmail,
            mailboxContain: mailboxContain,
          );
        },
      );

      return controller.mailboxDashBoardController.openPopupMenuActionGroup(
        context,
        position,
        popupMenuWidget,
      );
    }
  }

  Widget _buildFeedBackWidget(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(10),
        color: AppColor.colorTextButton,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SvgPicture.asset(
                controller.imagePaths.icFilterMessageAll,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
                colorFilter: Colors.white.asFilter(),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Text(
                  AppLocalizations.of(context).moveConversation(controller.listEmailDrag.length),
                  overflow: TextOverflow.clip,
                  style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is GetAllEmailLoading ||
            success is SearchingState ||
            success is CleanAndGetAllEmailLoading) {
          return const SizedBox.shrink();
        }

        if (success is GetAllEmailSuccess
            && success.currentMailboxId != controller.selectedMailboxId &&
            controller.selectedMailbox?.isFavorite != true) {
          return const SizedBox.shrink();
        } else {
          return PullToRefreshWidget(
            onNormalRefresh: controller.onRefresh,
            onDeepRefresh: controller.onCleanAndRefresh,
            pullDownToRefreshText: AppLocalizations.of(context).pullDownToRefresh,
            normalRefreshText: AppLocalizations.of(context).refresh,
            deepRefreshText: AppLocalizations.of(context).deepRefresh,
            pullHarderForText: AppLocalizations.of(context).pullHarderFor,
            child: EmptyEmailsWidget(
              key: const Key('empty_thread_view'),
              isNetworkConnectionAvailable: controller.networkConnectionController.isNetworkConnectionAvailable(),
              isSearchActive: controller.isSearchActive,
              isFilterMessageActive: controller.mailboxDashBoardController.filterMessageOption.value != FilterMessageOption.all,
              isFavoriteFolder: controller.selectedMailbox?.isFavorite == true,
            ),
          );
        }
      }
    ));
  }

  Widget _buildMailboxActionProgressBanner(BuildContext context) {
    return Obx(() {
      return _MailboxActionProgressBanner(
        viewState: controller.mailboxDashBoardController.viewStateMailboxActionProgress.value,
        responsiveUtils: controller.responsiveUtils,
      );
    });
  }
}

class _MailboxActionProgressBanner extends StatelessWidget with AppLoaderMixin {
  final Either<Failure, Success> viewState;
  final ResponsiveUtils responsiveUtils;

  const _MailboxActionProgressBanner({
    required this.viewState,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    return viewState.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (success is MarkAsMailboxReadLoading ||
            success is EmptySpamFolderLoading ||
            success is EmptyTrashFolderLoading ||
            success is MovingFolderContent ||
            success is ClearingMailbox) {
          return Padding(
            padding: EdgeInsets.only(
              top: responsiveUtils.isDesktop(context) ? 16 : 0,
              left: 16,
              right: 16,
              bottom: responsiveUtils.isDesktop(context) ? 0 : 16,
            ),
            child: horizontalLoadingWidget,
          );
        } else if (success is UpdatingMarkAsMailboxReadState) {
          return _buildProgressBanner(
            context,
            success.countRead,
            success.totalUnread,
          );
        } else if (success is EmptyingFolderState) {
          return _buildProgressBanner(
            context,
            success.countEmailsDeleted,
            success.totalEmails,
          );
        } else if (success is MoveFolderContentProgressState) {
          return _buildProgressBanner(
            context,
            success.countEmailsCompleted,
            success.totalEmails,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Padding _buildProgressBanner(BuildContext context, int progress, int total) {
    final percent = total > 0 ? progress / total : 0.68;
    return Padding(
      padding: EdgeInsets.only(
        top: responsiveUtils.isDesktop(context) ? 16 : 0,
        left: 16,
        right: 16,
        bottom: responsiveUtils.isDesktop(context) ? 0 : 16),
      child: horizontalPercentLoadingWidget(percent));
  }
}