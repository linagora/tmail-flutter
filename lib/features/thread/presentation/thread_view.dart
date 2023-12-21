import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recover_deleted_message_loading_banner_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_banner_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_banner_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_delete_all_spam_emails_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_empty_trash_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/scroll_to_top_button_widget_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_delete_all_spam_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/banner_empty_trash_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/bottom_bar_thread_selection_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/filter_message_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/scroll_to_top_button_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_banner/spam_report_banner_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/thread_view_bottom_loading_bar_widget.dart';
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
    return WillPopScope(
      onWillPop: () => controller.backButtonPressedCallbackAction(context),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Portal(
            child: Row(children: [
              if (supportVerticalDivider(context))
                const VerticalDivider(color: AppColor.colorDividerVertical, width: 1),
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
                                mailboxSelected: controller.currentMailbox,
                                listEmailSelected: controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected,
                                selectMode: controller.mailboxDashBoardController.currentSelectMode.value,
                                filterOption: controller.mailboxDashBoardController.filterMessageOption.value,
                                openMailboxAction: controller.openMailboxLeftMenu,
                                cancelEditThreadAction: controller.cancelSelectEmail,
                                editThreadAction: controller.enableSelectionEmail,
                                emailSelectionAction: (actionType, selectionEmail) {
                                  return controller.pressEmailSelectionAction(
                                    context,
                                    actionType,
                                    selectionEmail
                                  );
                                },
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
                                        (option) => controller.filterMessagesAction(context, option)
                                      )
                                    )
                                  : null
                              );
                            }),
                            if (!PlatformInfo.isWeb)
                              Obx(() {
                                if (!controller.networkConnectionController.isNetworkConnectionAvailable()) {
                                  return const Padding(
                                    padding: EdgeInsetsDirectional.only(bottom: 8),
                                    child: NetworkConnectionBannerWidget());
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                            _buildSearchBarView(context),
                            const SpamReportBannerWidget(),
                            const QuotasBannerWidget(),
                            _buildVacationNotificationMessage(context),
                            Obx(() => RecoverDeletedMessageLoadingBannerWidget(
                                isLoading: controller.mailboxDashBoardController.isRecoveringDeletedMessage.value,
                                horizontalLoadingWidget: horizontalLoadingWidget,
                                responsiveUtils: controller.responsiveUtils,
                            )),
                          ],
                        Obx(() {
                          if (controller.mailboxDashBoardController.isEmptyTrashBannerEnabledOnMobile(context)) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: BannerEmptyTrashStyles.mobileMargin
                              ),
                              child: BannerEmptyTrashWidget(
                                onTapAction: () => controller.deleteSelectionEmailsPermanently(context, DeleteActionType.all)
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        Obx(() {
                          if (controller.mailboxDashBoardController.isEmptySpamBannerEnabledOnMobile(context)) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: BannerDeleteAllSpamEmailsStyles.mobileMargin
                              ),
                              child: BannerDeleteAllSpamEmailsWidget(
                                onTapAction: () => controller.mailboxDashBoardController.openDialogEmptySpamFolder(context)
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        if (!controller.responsiveUtils.isDesktop(context))
                          _buildMarkAsMailboxReadLoading(context),
                        Obx(() => ThreadViewLoadingBarWidget(viewState: controller.viewState.value)),
                        Expanded(child: _buildListEmail(context)),
                        Obx(() => ThreadViewBottomLoadingBarWidget(viewState: controller.viewState.value)),
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
      ),
    );
  }

  bool supportVerticalDivider(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return controller.responsiveUtils.isTabletLarge(context);
    } else {
      return controller.responsiveUtils.isDesktop(context) ||
        controller.responsiveUtils.isTabletLarge(context) ||
        controller.responsiveUtils.isLandscapeTablet(context);
    }
  }

  Widget _buildSearchBarView(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: controller.responsiveUtils.isWebNotDesktop(context) ? 8 : 0),
      margin: EdgeInsets.only(bottom: PlatformInfo.isMobile ? 8 : 0),
      child: SearchBarView(controller.imagePaths,
        hintTextSearch: AppLocalizations.of(context).search_emails,
        onOpenSearchViewAction: controller.goToSearchView));
  }

  Widget _buildVacationNotificationMessage(BuildContext context) {
    return Obx(() {
      final vacation = controller.mailboxDashBoardController.vacationResponse.value;
      if (vacation?.vacationResponderIsValid == true) {
        return VacationNotificationMessageWidget(
          margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          vacationResponse: vacation!,
          actionGotoVacationSetting: controller.mailboxDashBoardController.goToVacationSetting,
          actionEndNow: controller.mailboxDashBoardController.disableVacationResponder);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildListButtonSelectionForMobile(BuildContext context) {
    return Obx(() {
      if ((PlatformInfo.isMobile || (PlatformInfo.isWeb && controller.isSelectionEnabled()
            && controller.isSearchActive() && !controller.responsiveUtils.isDesktop(context)))
          && controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected.isNotEmpty) {
        return BottomBarThreadSelectionWidget(
          controller.imagePaths,
          controller.responsiveUtils,
          controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected,
          controller.mailboxDashBoardController.selectedMailbox.value,
          onPressEmailSelectionActionClick: (actionType, selectionEmail) =>
            controller.pressEmailSelectionAction(
              context,
              actionType,
              selectionEmail
            )
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildFloatingButtonCompose(BuildContext context) {
    if (controller.responsiveUtils.isWebDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (controller.isAllSearchInActive) {
        return Container(
          padding: PlatformInfo.isMobile && controller.listEmailSelected.isNotEmpty
            ? EdgeInsets.only(bottom: controller.responsiveUtils.isTabletLarge(context) ? 85 : 70)
            : EdgeInsets.zero,
          child: ComposeFloatingButton(
            scrollController: controller.listEmailController,
            onTap: () => controller.mailboxDashBoardController.goToComposer(ComposerArguments())
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
                filter.getIcon(controller.imagePaths),
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
        ..onActionClick((option) => controller.filterMessagesAction(context, option)))
      .build()).toList();
  }

  Widget _buildListEmail(BuildContext context) {
    return Container(
      padding: PlatformInfo.isWeb
        ? const EdgeInsets.symmetric(horizontal: 4)
        : EdgeInsets.zero,
      alignment: Alignment.center,
      color: Colors.white,
      child: Obx(() {
        return Visibility(
          visible: controller.openingEmail.isFalse,
          child: _buildResultListEmail(context, controller.mailboxDashBoardController.emailsInCurrentMailbox));
      })
    );
  }

  Widget _buildResultListEmail(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    if (controller.mailboxDashBoardController.currentSelectMode.value == SelectMode.INACTIVE) {
      return listPresentationEmail.isNotEmpty
        ? RefreshIndicator(
            color: AppColor.colorTextButton,
            onRefresh: () async => controller.refreshAllEmail(),
            child: _buildListEmailBody(context, listPresentationEmail))
        : RefreshIndicator(
            color: AppColor.colorTextButton,
            onRefresh: () async => controller.refreshAllEmail(),
            child: _buildEmptyEmail(context));
    } else {
      return listPresentationEmail.isNotEmpty
        ? _buildListEmailBody(context, listPresentationEmail)
        : _buildEmptyEmail(context);
    }
  }

  Widget _buildListEmailBody(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification
            && !controller.loadingMoreStatus.isRunning
            && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
        ) {
          if (controller.isSearchActive() || controller.searchController.advancedSearchIsActivated.isTrue) {
            controller.searchMoreEmails();
          } else {
            controller.loadMoreEmails();
          }
        }
        return false;
      },
      child: PlatformInfo.isMobile
        ? ListView.builder(
            key: const PageStorageKey('list_presentation_email_in_threads'),
            controller: controller.listEmailController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemExtent: _getItemExtent(context),
            itemCount: listPresentationEmail.length,
            itemBuilder: (context, index) => Obx(() => _buildEmailItem(context, listPresentationEmail[index]))
          )
        : Focus(
            focusNode: controller.focusNodeKeyBoard,
            autofocus: true,
            onKey: controller.handleKeyEvent,
            child: ScrollbarListView(
              scrollController: controller.listEmailController,
              child: ListView.builder(
                key: const PageStorageKey('list_presentation_email_in_threads'),
                controller: controller.listEmailController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemExtent: _getItemExtent(context),
                itemCount: listPresentationEmail.length,
                itemBuilder: (context, index) => Obx(() => _buildEmailItem(context, listPresentationEmail[index]))
              ),
            ),
          )
    );
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

    return EmailTileBuilder(
      presentationEmail: presentationEmail,
      selectAllMode: selectModeAll,
      isShowingEmailContent: isShowingEmailContent,
      searchQuery: controller.searchQuery,
      mailboxContain: presentationEmail.mailboxContain,
      isSearchEmailRunning: controller.searchController.isSearchEmailRunning,
      isDrag: true
    );
  }

  Widget _buildEmailItemNotDraggable(BuildContext context, PresentationEmail presentationEmail) {
    final isShowingEmailContent = controller.mailboxDashBoardController.selectedEmail.value?.id == presentationEmail.id;
    final selectModeAll = controller.mailboxDashBoardController.currentSelectMode.value;

    return Dismissible(
      key: ValueKey<EmailId?>(presentationEmail.id),
      direction: controller.getSwipeDirection(controller.responsiveUtils.isWebDesktop(context), selectModeAll),
      background: Container(
        color: AppColor.colorItemRecipientSelected,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: Align(
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
        ),
      ),
      confirmDismiss: (direction) => controller.swipeEmailAction(context, presentationEmail, direction),
      child: EmailTileBuilder(
        presentationEmail: presentationEmail,
        selectAllMode: selectModeAll,
        isShowingEmailContent: isShowingEmailContent,
        searchQuery: controller.searchQuery,
        mailboxContain: presentationEmail.mailboxContain,
        isSearchEmailRunning: controller.searchController.isSearchEmailRunning,
        emailActionClick: (action, email) => _handleEmailActionClicked(context, email, action),
        onMoreActionClick: (email, position) => _handleEmailContextMenuAction(context, email, position),
      ),
    );
  }

  void _handleEmailActionClicked(
    BuildContext context,
    PresentationEmail presentationEmail,
    EmailActionType actionType
  ) {
    controller.pressEmailAction(
      context,
      actionType,
      presentationEmail,
      mailboxContain: presentationEmail.mailboxContain
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
      controller.openPopupMenuAction(
        context,
        position,
        _popupMenuActionTile(context, presentationEmail)
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

  double? _getItemExtent(BuildContext context) {
    if (PlatformInfo.isWeb) {
     return controller.responsiveUtils.isDesktop(context) ? 52 : 98;
    } else {
      return null;
    }
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is! LoadingState && success is! SearchingState
        ? EmptyEmailsWidget(
            key: const Key('empty_thread_view'),
            title: _getMessageEmptyEmail(context),
            iconSVG: controller.imagePaths.icEmptyEmail,
            subTitle: _getSubMessageEmptyEmail(context),
            onCreateFiltersActionCallback: controller.isNewFolderCreated
              ? controller.goToCreateEmailRuleView
              : null,
          )
        : const SizedBox.shrink())
    );
  }

  String _getMessageEmptyEmail(BuildContext context) {
    if (controller.isSearchActive()) {
      return AppLocalizations.of(context).no_emails_matching_your_search;
    } else {
      if (controller.mailboxDashBoardController.filterMessageOption.value == FilterMessageOption.all &&
          controller.isNewFolderCreated) {
        return AppLocalizations.of(context).folderCreatedTitle;
      } else {
        return AppLocalizations.of(context).noEmailMatchYourCurrentFilter;
      }
    }
  }

  String? _getSubMessageEmptyEmail(BuildContext context) {
    if (!controller.isSearchActive()
      && controller.mailboxDashBoardController.filterMessageOption.value != FilterMessageOption.all) {
      return AppLocalizations.of(context).reduceSomeFiltersAndTryAgain;
    } else if (controller.mailboxDashBoardController.filterMessageOption.value == FilterMessageOption.all &&
        controller.isNewFolderCreated) {
      return AppLocalizations.of(context).folderCreatedMessage;
    } else {
      return null;
    }
  }

  List<Widget> _contextMenuActionTile(BuildContext context, PresentationEmail email) {
    final mailboxContain = email.mailboxContain;

    return <Widget>[
      _openInNewTabContextMenuItemAction(context, email),
      if (mailboxContain?.isDrafts == false)
        _markAsEmailSpamOrUnSpamContextMenuItemAction(context, email, mailboxContain),
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
      ..onActionClick((email) => controller.pressEmailAction(context,
        mailboxContain?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam,
        email,
        mailboxContain: mailboxContain)
      )
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
        controller.openEmailInNewTabAction(context, email);
      })
    ).build();
  }

  List<PopupMenuEntry> _popupMenuActionTile(BuildContext context, PresentationEmail email) {
    final mailboxContain = email.mailboxContain;

    return [
      _buildOpenInNewTabPopupMenuItem(context, email, mailboxContain),
      if (mailboxContain?.isDrafts == false)
        _buildMarkAsSpamPopupMenuItem(context, email, mailboxContain)
    ];
  }

  PopupMenuEntry _buildMarkAsSpamPopupMenuItem(
    BuildContext context,
    PresentationEmail email,
    PresentationMailbox? mailboxContain
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: popupItem(
        mailboxContain?.isSpam == true ? controller.imagePaths.icNotSpam : controller.imagePaths.icSpam,
        mailboxContain?.isSpam == true
          ? AppLocalizations.of(context).remove_from_spam
          : AppLocalizations.of(context).mark_as_spam,
        colorIcon: AppColor.colorTextButton,
        styleName: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black
        ),
        onCallbackAction: () => controller.pressEmailAction(
          context,
          mailboxContain?.isSpam == true ? EmailActionType.unSpam : EmailActionType.moveToSpam,
          email,
          mailboxContain: mailboxContain
        )
      )
    );
  }

  PopupMenuEntry _buildOpenInNewTabPopupMenuItem(
    BuildContext context,
    PresentationEmail email,
    PresentationMailbox? mailboxContain
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: popupItem(
        controller.imagePaths.icOpenInNewTab,
        AppLocalizations.of(context).openInNewTab,
        colorIcon: AppColor.colorTextButton,
        styleName: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black
        ),
        onCallbackAction: () {
          popBack();
          controller.openEmailInNewTabAction(context, email);
        }
      )
    );
  }

  Widget _buildMarkAsMailboxReadLoading(BuildContext context) {
    return Obx(() {
      final viewState = controller.mailboxDashBoardController.viewStateMarkAsReadMailbox.value;
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
}