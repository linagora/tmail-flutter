import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
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
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_pull_to_refresh_list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/scroll_to_top_button_widget_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/thread_view_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/bottom_bar_thread_selection_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/filter_message_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/scroll_to_top_button_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/thread_view_loading_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadView extends GetWidget<ThreadController>
  with AppLoaderMixin,
    FilterEmailPopupMenuMixin,
    PopupMenuWidgetMixin {

  ThreadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
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
                            return AppBarThreadWidget(
                              responsiveUtils: controller.responsiveUtils,
                              imagePaths: controller.imagePaths,
                              mailboxSelected: controller.selectedMailbox,
                              listEmailSelected: controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected,
                              selectMode: controller.mailboxDashBoardController.currentSelectMode.value,
                              filterOption: controller.mailboxDashBoardController.filterMessageOption.value,
                              openMailboxAction: controller.openMailboxLeftMenu,
                              cancelEditThreadAction: controller.cancelSelectEmail,
                              emailSelectionAction: controller.pressEmailSelectionAction,
                              onContextMenuFilterEmailAction: controller.responsiveUtils.isScreenWithShortestSide(context)
                                ? (filterOption) => controller.openContextMenuAction(
                                    context,
                                    _filterMessagesCupertinoActionTile(context, filterOption)
                                  )
                                : null,
                              onPopupMenuFilterEmailAction: !controller.responsiveUtils.isScreenWithShortestSide(context)
                                ? (filterOption, position) => controller.openPopupMenuAction(
                                    context,
                                    position,
                                    popupMenuFilterEmailActionTile(
                                      context,
                                      filterOption,
                                      controller.filterMessagesAction
                                    )
                                  )
                                : null
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
                          SpamReportBannerWidget(
                            spamReportController: controller.mailboxDashBoardController.spamReportController,
                            margin: ThreadViewStyle.getBannerMargin(
                              context,
                              controller.responsiveUtils),
                          ),
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
                          return const SizedBox.shrink();
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
                      _buildListButtonSelectionForMobile(context),
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
      ),
    );
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

  Widget _buildListButtonSelectionForMobile(BuildContext context) {
    return Obx(() {
      final listEmailSelected = controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected;
      final currentSelectMode = controller.mailboxDashBoardController.currentSelectMode.value;
      final isSearchEmailRunning = controller.searchController.simpleSearchIsActivated.isTrue
          || controller.searchController.advancedSearchIsActivated.isTrue;

      if (_validateDisplayBottomBarSelection(
        context: context,
        listEmailSelected: listEmailSelected,
        isSearchEmailRunning: isSearchEmailRunning,
        currentSelectMode: currentSelectMode
      )) {
        return BottomBarThreadSelectionWidget(
          controller.imagePaths,
          controller.responsiveUtils,
          listEmailSelected,
          controller.mailboxDashBoardController.selectedMailbox.value,
          onPressEmailSelectionActionClick: controller.pressEmailSelectionAction
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  bool _validateDisplayBottomBarSelection({
    required BuildContext context,
    required List<PresentationEmail> listEmailSelected,
    required bool isSearchEmailRunning,
    required SelectMode currentSelectMode,
  }) {
    if (PlatformInfo.isMobile && listEmailSelected.isNotEmpty) {
      return true;
    }

    if (PlatformInfo.isWeb
        && currentSelectMode == SelectMode.ACTIVE
        && isSearchEmailRunning
        && !controller.responsiveUtils.isDesktop(context)
        && listEmailSelected.isNotEmpty
    ) {
      return true;
    }

    return false;
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

  List<Widget> _filterMessagesCupertinoActionTile(BuildContext context, FilterMessageOption optionCurrent) {
    final listFilter = [
      FilterMessageOption.attachments,
      FilterMessageOption.unread,
      FilterMessageOption.starred,
    ];
    
    return listFilter.map((filter) => (FilterMessageCupertinoActionSheetActionBuilder(
             Key('filter_email_${filter.name}'),
            SvgPicture.asset(
                filter.getContextMenuIcon(controller.imagePaths),
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter: filter == FilterMessageOption.attachments
                  ? AppColor.colorTextButton.asFilter()
                  : null),
            filter.getName(context),
            filter,
            optionCurrent: optionCurrent,
            iconLeftPadding: controller.responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(left: 12, right: 16)
                : const EdgeInsets.only(right: 12),
            iconRightPadding: controller.responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(right: 12)
                : EdgeInsets.zero,
            actionSelected: SvgPicture.asset(
                controller.imagePaths.icFilterSelected,
                width: 20,
                height: 20,
                fit: BoxFit.fill))
        ..onActionClick(controller.filterMessagesAction))
      .build()).toList();
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
      child: PlatformInfo.isMobile
        ? listView
        : Focus(
            focusNode: controller.focusNodeKeyBoard,
            autofocus: true,
            onKeyEvent: controller.handleKeyEvent,
            child: listView,
          ),
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
              style: const TextStyle(
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          )
        : null,
      confirmDismiss: (direction) => controller.swipeEmailAction(context, presentationEmail, direction),
      child: EmailTileBuilder(
        key: Key('email_tile_builder_${presentationEmail.id?.asString}'),
        presentationEmail: presentationEmail,
        selectAllMode: selectModeAll,
        isShowingEmailContent: isShowingEmailContent,
        isSenderImportantFlagEnabled: isSenderImportantFlagEnabled,
        searchQuery: controller.searchQuery,
        mailboxContain: presentationEmail.mailboxContain,
        isSearchEmailRunning: controller.searchController.isSearchEmailRunning,
        emailActionClick: _handleEmailActionClicked,
        onMoreActionClick: (email, position) => _handleEmailContextMenuAction(context, email, position),
      ),
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

  void _handleEmailContextMenuAction(
    BuildContext context,
    PresentationEmail presentationEmail,
    RelativeRect? position
  ) {
    if (controller.responsiveUtils.isScreenWithShortestSide(context)) {
      controller.openContextMenuAction(
        context,
        _contextMenuActionTile(context, presentationEmail)
      );
    } else {
      final mailboxContain = presentationEmail.mailboxContain;
      final isDrafts = mailboxContain?.isDrafts ?? false;
      final isChildOfTeamMailboxes =
          mailboxContain?.isChildOfTeamMailboxes ?? false;
      final isSpam = mailboxContain?.isSpam ?? false;
      final isArchive = mailboxContain?.isArchive ?? false;
      final isTemplates = mailboxContain?.isTemplates ?? false;

      final popupMenuItems = [
        EmailActionType.openInNewTab,
        if (!isDrafts && !isChildOfTeamMailboxes)
          isSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
        if (!isArchive) EmailActionType.archiveMessage,
        if (!isDrafts && !isTemplates) EmailActionType.editAsNewEmail,
      ].map((actionType) {
        return PopupMenuItem(
          padding: EdgeInsets.zero,
          child: PopupMenuItemActionWidget(
            menuAction: PopupMenuItemEmailAction(
              actionType,
              AppLocalizations.of(context),
              controller.imagePaths,
            ),
            menuActionClick: (menuAction) {
              popBack();
              controller.handleEmailActionType(
                menuAction.action,
                presentationEmail,
                mailboxContain: mailboxContain,
              );
            },
          ),
        );
      }).toList();

      controller.openPopupMenuAction(context, position, popupMenuItems);
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
                  style: const TextStyle(
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
            && success.currentMailboxId != controller.selectedMailboxId) {
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
            ),
          );
        }
      }
    ));
  }

  List<Widget> _contextMenuActionTile(BuildContext context, PresentationEmail email) {
    final mailboxContain = email.mailboxContain;

    return <Widget>[
      _openInNewTabContextMenuItemAction(context, email),
      if (mailboxContain?.isDrafts == false && mailboxContain?.isChildOfTeamMailboxes == false)
        _markAsEmailSpamOrUnSpamContextMenuItemAction(context, email, mailboxContain),
      if (mailboxContain?.isArchive == false)
        _archiveMessageContextMenuItemAction(context, email),
      if (mailboxContain?.isDrafts == false && mailboxContain?.isTemplates == false)
        _editAsNewEmailContextMenuItemAction(context, email),
    ];
  }

  Widget _markAsEmailSpamOrUnSpamContextMenuItemAction(
    BuildContext context,
    PresentationEmail email,
    PresentationMailbox? mailboxContain
  ) {
    return (EmailActionCupertinoActionSheetActionBuilder(
        const Key('mark_as_spam_or_un_spam_action'),
        SvgPicture.asset(
          mailboxContain?.isSpam == true ? controller.imagePaths.icNotSpam : controller.imagePaths.icSpam,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
          colorFilter: AppColor.colorTextButton.asFilter()),
        mailboxContain?.isSpam == true
          ? AppLocalizations.of(context).remove_from_spam
          : AppLocalizations.of(context).mark_as_spam,
        email,
        iconLeftPadding: controller.responsiveUtils.isMobile(context)
          ? const EdgeInsets.only(left: 12, right: 16)
          : const EdgeInsets.only(right: 12),
        iconRightPadding: controller.responsiveUtils.isMobile(context)
          ? const EdgeInsets.only(right: 12)
          : EdgeInsets.zero)
      ..onActionClick((email) => controller.handleEmailActionType(
        mailboxContain?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam,
        email,
        mailboxContain: mailboxContain,
      ))
    ).build();
  }

  Widget _openInNewTabContextMenuItemAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
      const Key('open_in_new_tab_action'),
      SvgPicture.asset(
        controller.imagePaths.icOpenInNewTab,
        width: 24,
        height: 24,
        fit: BoxFit.fill,
        colorFilter: AppColor.colorTextButton.asFilter()),
      AppLocalizations.of(context).openInNewTab,
      email,
      iconLeftPadding: controller.responsiveUtils.isMobile(context)
        ? const EdgeInsets.only(left: 12, right: 16)
        : const EdgeInsets.only(right: 12),
      iconRightPadding: controller.responsiveUtils.isMobile(context)
        ? const EdgeInsets.only(right: 12)
        : EdgeInsets.zero)
      ..onActionClick((email) {
        popBack();
        controller.openEmailInNewTabAction(email);
      })
    ).build();
  }

  Widget _archiveMessageContextMenuItemAction(BuildContext context, PresentationEmail email) {
    return (
      EmailActionCupertinoActionSheetActionBuilder(
        const Key('archive_message_action'),
        SvgPicture.asset(
          controller.imagePaths.icMailboxArchived,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
          colorFilter: AppColor.colorTextButton.asFilter()
        ),
        AppLocalizations.of(context).archiveMessage,
        email,
        iconLeftPadding: controller.responsiveUtils.isMobile(context)
          ? const EdgeInsetsDirectional.only(start: 12, end: 16)
          : const EdgeInsetsDirectional.only(end: 12),
        iconRightPadding: controller.responsiveUtils.isMobile(context)
          ? const EdgeInsetsDirectional.only(start: 12)
          : EdgeInsets.zero
      )
      ..onActionClick((email) => controller.archiveMessage(context, email))
    ).build();
  }

  Widget _editAsNewEmailContextMenuItemAction(
    BuildContext context,
    PresentationEmail email,
  ) {
    return (
      EmailActionCupertinoActionSheetActionBuilder(
        const Key('edit_as_new_email_action'),
        SvgPicture.asset(
          controller.imagePaths.icEdit,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
          colorFilter: AppColor.colorTextButton.asFilter()
        ),
        AppLocalizations.of(context).editAsNewEmail,
        email,
        iconLeftPadding: controller.responsiveUtils.isMobile(context)
          ? const EdgeInsetsDirectional.only(start: 12, end: 16)
          : const EdgeInsetsDirectional.only(end: 12),
        iconRightPadding: controller.responsiveUtils.isMobile(context)
          ? const EdgeInsetsDirectional.only(start: 12)
          : EdgeInsets.zero)
      ..onActionClick((email) {
        popBack();
        controller.editAsNewEmail(email);
      })
    ).build();
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