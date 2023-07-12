import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_banner_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_warning_banner_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/bottom_bar_thread_selection_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/filter_message_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/spam_report_banner_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ThreadView extends GetWidget<ThreadController>
  with AppLoaderMixin,
    FilterEmailPopupMenuMixin,
    PopupMenuWidgetMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ThreadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Portal(
          child: Row(children: [
            if (supportVerticalDivider(context))
              const VerticalDivider(color: AppColor.colorDividerVertical, width: 1),
            Expanded(child: SafeArea(
                right: _responsiveUtils.isLandscapeMobile(context),
                left: _responsiveUtils.isLandscapeMobile(context),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_responsiveUtils.isWebDesktop(context))
                        ... [
                          _buildAppBarNormal(context),
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
                          const QuotasWarningBannerWidget(),
                          _buildVacationNotificationMessage(context),
                        ],
                      _buildEmptyTrashButton(context),
                      if (!_responsiveUtils.isDesktop(context))
                        _buildMarkAsMailboxReadLoading(context),
                      _buildLoadingView(),
                      Expanded(child: _buildListEmail(context)),
                      _buildLoadingViewLoadMore(),
                      _buildListButtonSelectionForMobile(context),
                    ]
                )
            ))
          ]),
        ),
        floatingActionButton: _buildFloatingButtonCompose(context),
      ),
    );
  }

  bool supportVerticalDivider(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return _responsiveUtils.isTabletLarge(context);
    } else {
      return _responsiveUtils.isDesktop(context) ||
        _responsiveUtils.isTabletLarge(context) ||
        _responsiveUtils.isLandscapeTablet(context);
    }
  }

  Widget _buildSearchBarView(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: _responsiveUtils.isWebNotDesktop(context) ? 8 : 0),
      margin: EdgeInsets.only(bottom: PlatformInfo.isMobile ? 16 : 0),
      child: SearchBarView(_imagePaths,
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
            && controller.isSearchActive() && !_responsiveUtils.isDesktop(context)))
          && controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected.isNotEmpty) {
        return BottomBarThreadSelectionWidget(
          _imagePaths,
          _responsiveUtils,
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

  Widget _buildAppBarNormal(BuildContext context) {
    return Obx(() {
      return AppBarThreadWidgetBuilder(
        controller.currentMailbox,
        controller.mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected,
        controller.mailboxDashBoardController.currentSelectMode.value,
        controller.mailboxDashBoardController.filterMessageOption.value,
        onOpenMailboxMenuActionClick: controller.openMailboxLeftMenu,
        onCancelEditThread: controller.cancelSelectEmail,
        onEditThreadAction: controller.enableSelectionEmail,
        onEmailSelectionAction: (actionType, selectionEmail) =>
            controller.pressEmailSelectionAction(context, actionType, selectionEmail),
        onFilterEmailAction: (filterMessageOption, position) {
          if (_responsiveUtils.isScreenWithShortestSide(context)) {
            controller.openContextMenuAction(
                context,
                _filterMessagesCupertinoActionTile(context, filterMessageOption));
          } else {
            controller.openPopupMenuAction(
                context,
                position,
                popupMenuFilterEmailActionTile(
                    context,
                    filterMessageOption,
                        (option) => controller.filterMessagesAction(context, option)));
          }
        });
    });
  }

  Widget _buildFloatingButtonCompose(BuildContext context) {
    if (_responsiveUtils.isWebDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (controller.isAllSearchInActive) {
        return Container(
          padding: PlatformInfo.isWeb
            ? EdgeInsets.zero
            : controller.listEmailSelected.isNotEmpty ? const EdgeInsets.only(bottom: 70) : EdgeInsets.zero,
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
                filter.getIcon(_imagePaths),
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter: filter == FilterMessageOption.attachments
                  ? AppColor.colorTextButton.asFilter()
                  : null),
            filter.getName(context),
            filter,
            optionCurrent: optionCurrent,
            iconLeftPadding: _responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(left: 12, right: 16)
                : const EdgeInsets.only(right: 12),
            iconRightPadding: _responsiveUtils.isMobile(context)
                ? const EdgeInsets.only(right: 12)
                : EdgeInsets.zero,
            actionSelected: SvgPicture.asset(
                _imagePaths.icFilterSelected,
                width: 20,
                height: 20,
                fit: BoxFit.fill))
        ..onActionClick((option) => controller.filterMessagesAction(context, option)))
      .build()).toList();
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (controller.isSearchActive() || controller.searchController.advancedSearchIsActivated.isTrue) {
          return success is SearchingState
              ? Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: loadingWidget)
              : const SizedBox.shrink();
        } else {
          return success is LoadingState || controller.openingEmail.isTrue
              ? Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: loadingWidget)
              : const SizedBox.shrink();
        }
      }));
  }

  Widget _buildLoadingViewLoadMore() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (controller.isSearchActive()) {
          return success is SearchingMoreState
              ? Padding(padding: const EdgeInsets.only(bottom: 16), child: loadingWidget)
              : const SizedBox.shrink();
        } else {
          return success is LoadingMoreState
              ? Padding(padding: const EdgeInsets.only(bottom: 16), child: loadingWidget)
              : const SizedBox.shrink();
        }
      }));
  }

  Widget _buildListEmail(BuildContext context) {
    return Container(
      margin: PlatformInfo.isWeb && _responsiveUtils.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: 4)
          : EdgeInsets.zero,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
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
          log('ThreadView::_buildListEmailBody(): CALL LOAD MORE');
          if (controller.isSearchActive() || controller.searchController.advancedSearchIsActivated.isTrue) {
            controller.searchMoreEmails();
          } else {
            controller.loadMoreEmails();
          }
        }
        return false;
      },
      child: Focus(
        focusNode: controller.focusNodeKeyBoard,
        autofocus: kIsWeb,
        onKey: kIsWeb ? controller.handleKeyEvent : null,
        child: ListView.builder(
          controller: controller.listEmailController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          key: const PageStorageKey('list_presentation_email_in_threads'),
          itemExtent: _getItemExtent(context),
          itemCount: listPresentationEmail.length,
          itemBuilder: (context, index) => Obx(() => _buildEmailItem(context, listPresentationEmail[index]))
        ),
      )
    );
  }

  Widget _buildEmailItem(BuildContext context, PresentationEmail presentationEmail) {
    if (_responsiveUtils.isWebDesktop(context)) {
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

    return (EmailTileBuilder(
      context,
      presentationEmail,
      selectModeAll,
      controller.searchQuery,
      isShowingEmailContent,
      mailboxContain: presentationEmail.mailboxContain,
      isSearchEmailRunning: controller.searchController.isSearchEmailRunning,
      isDrag: true
    )).build();
  }

  Widget _buildEmailItemNotDraggable(BuildContext context, PresentationEmail presentationEmail) {
    final isShowingEmailContent = controller.mailboxDashBoardController.selectedEmail.value?.id == presentationEmail.id;
    final selectModeAll = controller.mailboxDashBoardController.currentSelectMode.value;

    return (EmailTileBuilder(
      context,
      presentationEmail,
      selectModeAll,
      controller.searchQuery,
      isShowingEmailContent,
      mailboxContain: presentationEmail.mailboxContain,
      isSearchEmailRunning: controller.searchController.isSearchEmailRunning
    )
      ..addOnPressEmailActionClick((action, email) => _handleEmailActionClicked(context, email, action))
      ..addOnMoreActionClick((email, position) => _handleEmailContextMenuAction(context, email, position))
    ).build();
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
    if (_responsiveUtils.isScreenWithShortestSide(context)) {
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
                _imagePaths.icFilterMessageAll,
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
     return _responsiveUtils.isDesktop(context) ? 52 : 95;
    } else {
      return null;
    }
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is! LoadingState && success is! SearchingState
        ? BackgroundWidgetBuilder(
            _getMessageEmptyEmail(context),
            controller.responsiveUtils,
            iconSVG: _imagePaths.icEmptyEmail,
            subTitle: _getSubMessageEmptyEmail(context),
          )
        : const SizedBox.shrink())
    );
  }

  String _getMessageEmptyEmail(BuildContext context) {
    if (controller.isSearchActive()) {
      return AppLocalizations.of(context).no_emails_matching_your_search;
    } else {
      if (controller.mailboxDashBoardController.filterMessageOption.value == FilterMessageOption.all) {
        return AppLocalizations.of(context).noEmailInYourCurrentMailbox;
      } else {
        return AppLocalizations.of(context).noEmailMatchYourCurrentFilter;
      }
    }
  }

  String? _getSubMessageEmptyEmail(BuildContext context) {
    if (!controller.isSearchActive()
      && controller.mailboxDashBoardController.filterMessageOption.value != FilterMessageOption.all) {
      return AppLocalizations.of(context).reduceSomeFiltersAndTryAgain;
    } else {
      return null;
    }
  }

  bool supportEmptyTrash(BuildContext context) {
    return controller.isMailboxTrash
        && controller.mailboxDashBoardController.emailsInCurrentMailbox.isNotEmpty
        && !controller.isSearchActive()
        && !_responsiveUtils.isWebDesktop(context);
  }

  Widget _buildEmptyTrashButton(BuildContext context) {
    return Obx(() {
      if (supportEmptyTrash(context)) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              border: Border.all(color: AppColor.colorLineLeftEmailView),
              color: Colors.white),
          margin: EdgeInsets.only(
              left: AppUtils.isDirectionRTL(context) ? 16 : _responsiveUtils.isWebDesktop(context) ? 0 : 16,
              right: AppUtils.isDirectionRTL(context) ? _responsiveUtils.isWebDesktop(context) ? 0 : 16 : 16,
              bottom: _responsiveUtils.isWebDesktop(context) ? 0 : 16,
              top: _responsiveUtils.isWebDesktop(context) ? 16 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Padding(
                padding: EdgeInsets.only(
                  right: AppUtils.isDirectionRTL(context) ? 0 : 16,
                  left: AppUtils.isDirectionRTL(context) ? 16 : 0,
                ),
                child: SvgPicture.asset(
                    _imagePaths.icDeleteTrash,
                    fit: BoxFit.fill)),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(
                            left: AppUtils.isDirectionRTL(context) ? 0 : 8,
                            right: AppUtils.isDirectionRTL(context) ? 0 : 8,
                          ),
                          child: Text(
                              AppLocalizations.of(context).message_delete_all_email_in_trash_button,
                              style: const TextStyle(
                                  color: AppColor.colorContentEmail,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500))),
                      TextButton(
                          onPressed: () =>
                              controller.deleteSelectionEmailsPermanently(context, DeleteActionType.all),
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
          mailboxContain?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
          colorFilter: AppColor.colorTextButton.asFilter()),
        mailboxContain?.isSpam == true
          ? AppLocalizations.of(context).remove_from_spam
          : AppLocalizations.of(context).mark_as_spam,
        email,
        iconLeftPadding: _responsiveUtils.isMobile(context)
          ? const EdgeInsets.only(left: 12, right: 16)
          : const EdgeInsets.only(right: 12),
        iconRightPadding: _responsiveUtils.isMobile(context)
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
        _imagePaths.icOpenInNewTab,
        width: 24,
        height: 24,
        fit: BoxFit.fill,
        colorFilter: AppColor.colorTextButton.asFilter()),
      AppLocalizations.of(context).openInNewTab,
      email,
      iconLeftPadding: _responsiveUtils.isMobile(context)
        ? const EdgeInsets.only(left: 12, right: 16)
        : const EdgeInsets.only(right: 12),
      iconRightPadding: _responsiveUtils.isMobile(context)
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
        mailboxContain?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam,
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
        _imagePaths.icOpenInNewTab,
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
                    top: _responsiveUtils.isDesktop(context) ? 16 : 0,
                    left: 16,
                    right: 16,
                    bottom: _responsiveUtils.isDesktop(context) ? 0 : 16),
                child: horizontalLoadingWidget);
          } else if (success is UpdatingMarkAsMailboxReadState) {
            final percent = success.countRead / success.totalUnread;
            return Padding(
                padding: EdgeInsets.only(
                    top: _responsiveUtils.isDesktop(context) ? 16 : 0,
                    left: 16,
                    right: 16,
                    bottom: _responsiveUtils.isDesktop(context) ? 0 : 16),
                child: horizontalPercentLoadingWidget(percent));
          }
          return const SizedBox.shrink();
          });
    });
  }
}