import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
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
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadView extends GetWidget<ThreadController> with AppLoaderMixin,
    FilterEmailPopupMenuMixin {

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
              const VerticalDivider(
                  color: AppColor.colorDividerVertical,
                  width: 1,
                  thickness: 0.2),
            Expanded(child: SafeArea(
                right: _responsiveUtils.isLandscapeMobile(context),
                left: _responsiveUtils.isLandscapeMobile(context),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_responsiveUtils.isWebDesktop(context))
                        ... [
                          _buildAppBarNormal(context),
                          _buildSearchBarView(context),
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
    if (BuildUtils.isWeb) {
      return _responsiveUtils.isTabletLarge(context);
    } else {
      return _responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context);
    }
  }

  Widget _buildSearchBarView(BuildContext context) {
    return Obx(() {
      if (!controller.searchController.isSearchActive()) {
        return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: _responsiveUtils.isWebNotDesktop(context) ? 8 : 0),
            margin: const EdgeInsets.only(
                bottom: !BuildUtils.isWeb ? 16 : 0),
            child: SearchBarView(_imagePaths,
                hintTextSearch: AppLocalizations.of(context).search_emails,
                onOpenSearchViewAction: () => controller.goToSearchView()));
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildVacationNotificationMessage(BuildContext context) {
    return Obx(() {
      final vacation = controller.mailboxDashBoardController.vacationResponse.value;
      if (vacation?.vacationResponderIsValid == true) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: VacationNotificationMessageWidget(
              vacationResponse: vacation!,
              actionGotoVacationSetting: () => controller.mailboxDashBoardController.goToVacationSetting(),
              actionEndNow: () => controller.mailboxDashBoardController.disableVacationResponder()),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildListButtonSelectionForMobile(BuildContext context) {
    return Obx(() {
      if ((!BuildUtils.isWeb || (BuildUtils.isWeb && controller.isSelectionEnabled()
            && controller.isSearchActive() && !_responsiveUtils.isDesktop(context)))
          && controller.emailList.listEmailSelected.isNotEmpty) {
        return Column(children: [
          const Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
          Padding(
            padding: const EdgeInsets.all(10),
            child: (BottomBarThreadSelectionWidget(
                    context,
                    _imagePaths,
                    _responsiveUtils,
                    controller.emailList.listEmailSelected,
                    controller.mailboxDashBoardController.selectedMailbox.value)
                ..addOnPressEmailSelectionActionClick((actionType, selectionEmail) =>
                    controller.pressEmailSelectionAction(context, actionType, selectionEmail)))
              .build()),
        ]);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildAppBarNormal(BuildContext context) {
    return Obx(() {
      return AppBarThreadWidgetBuilder(
        controller.currentMailbox,
        controller.emailList.listEmailSelected,
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
          padding: BuildUtils.isWeb
              ? EdgeInsets.zero
              : controller.isSelectionEnabled() ? const EdgeInsets.only(bottom: 70) : EdgeInsets.zero,
          child: Align(
            alignment: Alignment.bottomRight,
            child: ScrollingFloatingButtonAnimated(
              icon: SvgPicture.asset(_imagePaths.icCompose, width: 20, height: 20, fit: BoxFit.fill),
              text: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(AppLocalizations.of(context).compose,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  style: const TextStyle(
                      color: AppColor.colorTextButton,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500))),
              onPress: () => controller.mailboxDashBoardController.goToComposer(ComposerArguments()),
              scrollController: controller.listEmailController,
              color: Colors.white,
              elevation: 4.0,
              width: 140,
              animateIcon: false
            )
          )
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
                color: filter == FilterMessageOption.attachments
                    ? AppColor.colorTextButton : null),
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
        if (controller.isSearchActive() || controller.isAdvanceSearchActive()) {
          return success is SearchingState
              ? Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: loadingWidget)
              : const SizedBox.shrink();
        } else {
          return success is LoadingState
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
      margin: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: 4)
          : EdgeInsets.zero,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Obx(() {
        return _buildResultListEmail(context, controller.emailList);
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
            && !controller.isLoadingMore
            && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
        ) {
          if (controller.isSearchActive() || controller.isAdvanceSearchActive()) {
            controller.searchMoreEmails();
          } else {
            controller.loadMoreEmails();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: controller.listEmailController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        key: const PageStorageKey('list_presentation_email_in_threads'),
        itemExtent: _getItemExtent(context),
        itemCount: listPresentationEmail.length,
        itemBuilder: (context, index) => Obx(() => (EmailTileBuilder(
                context,
                listPresentationEmail[index],
                controller.mailboxDashBoardController.currentSelectMode.value,
                controller.searchController.searchState.value.searchStatus,
                controller.searchQuery,
                mailboxCurrent: controller.searchController.isSearchEmailRunning
                    ? listPresentationEmail[index].findMailboxContain(
                          controller.mailboxDashBoardController.mapMailbox)
                    : controller.currentMailbox,
                advancedSearchActivated: controller.searchController.isAdvancedSearchHasApply.isTrue)
            ..addOnPressEmailActionClick((action, email) =>
                controller.pressEmailAction(
                    context,
                    action,
                    email,
                    mailboxContain: controller.searchController.isSearchEmailRunning
                      ? email.findMailboxContain(controller.mailboxDashBoardController.mapMailbox)
                      : controller.currentMailbox))
            ..addOnMoreActionClick((email, position) => _responsiveUtils.isMobile(context)
              ? controller.openContextMenuAction(context, _contextMenuActionTile(context, email))
              : controller.openPopupMenuAction(context, position, _popupMenuActionTile(context, email))))
          .build()))
    );
  }

  double? _getItemExtent(BuildContext context) {
    if (BuildUtils.isWeb) {
     return _responsiveUtils.isDesktop(context) ? 52 : 95;
    } else {
      return null;
    }
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is! LoadingState && success is! SearchingState
        ? (BackgroundWidgetBuilder(context)
            ..key(const Key('empty_email_background'))
            ..image(SvgPicture.asset(_imagePaths.icEmptyImageDefault, width: 120, height: 120, fit: BoxFit.fill))
            ..text(controller.isSearchActive()
                ? AppLocalizations.of(context).no_emails_matching_your_search
                : AppLocalizations.of(context).no_emails))
          .build()
        : const SizedBox.shrink())
    );
  }

  bool supportEmptyTrash(BuildContext context) {
    return controller.isMailboxTrash
        && controller.emailList.isNotEmpty
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
              left: _responsiveUtils.isWebDesktop(context) ? 0 : 16,
              right: 16,
              bottom: _responsiveUtils.isWebDesktop(context) ? 0 : 16,
              top: _responsiveUtils.isWebDesktop(context) ? 16 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(
                    _imagePaths.icDeleteTrash,
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
    return <Widget>[
      _markAsEmailSpamOrUnSpamAction(context, email),
    ];
  }

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    final mailboxContain = controller.searchController.isSearchEmailRunning
        ? email.findMailboxContain(controller.mailboxDashBoardController.mapMailbox)
        : controller.currentMailbox;
    return (EmailActionCupertinoActionSheetActionBuilder(
            const Key('mark_as_spam_or_un_spam_action'),
            SvgPicture.asset(
                mailboxContain?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam,
                width: 28,
                height: 28,
                fit: BoxFit.fill,
                color: AppColor.colorTextButton),
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
            mailboxContain?.isSpam == true
                ? EmailActionType.unSpam
                : EmailActionType.moveToSpam,
            email,
            mailboxContain: mailboxContain)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _markAsEmailSpamOrUnSpamAction(context, email)),
    ];
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