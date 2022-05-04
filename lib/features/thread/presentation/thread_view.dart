import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/bottom_bar_thread_selection_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/filter_message_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/suggestion_box_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadView extends GetWidget<ThreadController> with AppLoaderMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ThreadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
        body: Row(children: [
          if ((!BuildUtils.isWeb && _responsiveUtils.isDesktop(context) && _responsiveUtils.isTabletLarge(context))
              || (BuildUtils.isWeb && _responsiveUtils.isTabletLarge(context)))
            const VerticalDivider(color: AppColor.lineItemListColor, width: 1, thickness: 0.2),
          Expanded(child: SafeArea(
              right: _responsiveUtils.isLandscapeMobile(context),
              left: _responsiveUtils.isLandscapeMobile(context),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => !controller.isSearchActive()
                        && ((!_responsiveUtils.isDesktop(context) && BuildUtils.isWeb) || !BuildUtils.isWeb)
                      ? _buildAppBarNormal(context)
                      : const SizedBox.shrink()),
                    _buildSearchInputFormForMobile(context),
                    Container(
                        color: BuildUtils.isWeb ? AppColor.colorBgDesktop : Colors.white,
                        padding: EdgeInsets.zero,
                        child: _buildSearchButtonViewForMobile(context)),
                    Obx(() => controller.isMailboxTrash && controller.emailList.isNotEmpty && !controller.isSearchActive()
                        ? _buildEmptyTrashButton(context)
                        : const SizedBox.shrink()),
                    Expanded(child: Container(
                        color: BuildUtils.isWeb ? AppColor.colorBgDesktop : Colors.white,
                        padding: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                            ? const EdgeInsets.only(left: 32, right: 24, top: 16, bottom: 24)
                            : EdgeInsets.zero,
                        child: Stack(children: [
                          Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                                      ? BorderRadius.circular(20)
                                      : null,
                                  border: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                                      ? Border.all(color: AppColor.colorBorderBodyThread, width: 1)
                                      : null,
                                  color: Colors.white),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStatusResultSearch(context),
                                    _buildLoadingView(),
                                    Expanded(child: _buildListEmail(context)),
                                    _buildLoadingViewLoadMore(),
                                  ]
                              )
                          ),
                          _buildSuggestionBox(context)
                        ]))),
                    _buildListButtonSelectionForMobile(context),
                  ]
              )
          ))
        ]),
        floatingActionButton: _buildFloatingButtonCompose(context),
      ),
    );
  }

  Widget _buildListButtonSelectionForMobile(BuildContext context) {
    return Obx(() {
      if ((!BuildUtils.isWeb || (BuildUtils.isWeb && controller.isSelectionEnabled()
            && controller.isSearchActive() && !_responsiveUtils.isDesktop(context)))
          && controller.listEmailSelected.isNotEmpty) {
        return Column(children: [
          const Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
          Padding(
            padding: const EdgeInsets.all(10),
            child: (BottomBarThreadSelectionWidget(
                    context,
                    _imagePaths,
                    _responsiveUtils,
                    controller.listEmailSelected,
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

  Widget _buildSearchButtonViewForMobile(BuildContext context) {
    return Obx(() {
      if (!controller.isSearchActive() &&
          ((!_responsiveUtils.isDesktop(context) && BuildUtils.isWeb) || !BuildUtils.isWeb)) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: (SearchBarView(_imagePaths)
              ..hintTextSearch(BuildUtils.isWeb ? AppLocalizations.of(context).search_emails : AppLocalizations.of(context).hint_search_emails)
              ..addOnOpenSearchViewAction(() => controller.enableSearch(context)))
            .build());
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildSearchInputFormForMobile(BuildContext context) {
    return Obx(() {
      if (controller.isSearchActive() &&
          ((!_responsiveUtils.isDesktop(context) && BuildUtils.isWeb) || !BuildUtils.isWeb)) {
        return Column(children: [
          _buildSearchForm(context),
          const Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
        ]);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildSearchForm(BuildContext context) {
    return (SearchAppBarWidget(
          context,
          _imagePaths,
          _responsiveUtils,
          controller.searchQuery,
          controller.mailboxDashBoardController.searchFocus,
          controller.mailboxDashBoardController.searchInputController,
          suggestionSearch: controller.mailboxDashBoardController.suggestionSearch,)
      ..addDecoration(const BoxDecoration(color: Colors.white))
      ..setMargin(const EdgeInsets.only(right: 10))
      ..setHintText(AppLocalizations.of(context).search_mail)
      ..addOnCancelSearchPressed(() => controller.disableSearch())
      ..addOnClearTextSearchAction(() => controller.mailboxDashBoardController.clearSearchText())
      ..addOnTextChangeSearchAction((query) => controller.mailboxDashBoardController.addSuggestionSearch(query))
      ..addOnSearchTextAction((query) => controller.mailboxDashBoardController.searchEmail(context, query)))
    .build();
  }

  Widget _buildAppBarNormal(BuildContext context) {
    return (AppBarThreadWidgetBuilder(
              context,
              _imagePaths,
              _responsiveUtils,
              controller.mailboxDashBoardController.selectedMailbox.value,
              controller.listEmailSelected,
              controller.mailboxDashBoardController.currentSelectMode.value,
              controller.mailboxDashBoardController.filterMessageOption.value)
          ..addOpenMailboxMenuActionClick(() => controller.openMailboxLeftMenu())
          ..addOnEditThreadAction(() => controller.enableSelectionEmail())
          ..addOnEmailSelectionAction((actionType, selectionEmail) =>
              controller.pressEmailSelectionAction(context, actionType, selectionEmail))
          ..addOnFilterEmailAction((filterMessageOption, position) =>
              _responsiveUtils.isScreenWithShortestSide(context)
                ? controller.openContextMenuAction(
                    context,
                    _filterMessagesCupertinoActionTile(context, filterMessageOption))
                : controller.openPopupMenuAction(
                    context,
                    position,
                    _popupMenuEmailActionTile(context, filterMessageOption)))
          ..addOnCancelEditThread(() => controller.cancelSelectEmail()))
        .build();
  }

  Widget _buildFloatingButtonCompose(BuildContext context) {
    return Obx(() {
      if (!controller.isSearchActive()
          && (!BuildUtils.isWeb || (BuildUtils.isWeb && !_responsiveUtils.isDesktop(context)))) {
        return Container(
          padding: BuildUtils.isWeb
              ? EdgeInsets.zero
              : controller.isSelectionEnabled() ? const EdgeInsets.only(bottom: 70) : EdgeInsets.zero,
          child: Align(
            alignment: Alignment.bottomRight,
            child: ScrollingFloatingButtonAnimated(
              icon: SvgPicture.asset(_imagePaths.icCompose, width: 20, height: 20, fit: BoxFit.fill),
              text: Padding(padding: const EdgeInsets.only(right: 10),
                child: Text(AppLocalizations.of(context).compose,
                  style: const TextStyle(color: AppColor.colorTextButton, fontSize: 15.0, fontWeight: FontWeight.w500))),
              onPress: () => controller.composeEmailAction(),
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
    return <Widget>[
      _filterMessageWithAttachmentsAction(context, optionCurrent),
      _filterMessagesUnreadAction(context, optionCurrent),
      _filterMessageStarredAction(context, optionCurrent),
    ];
  }

  Widget _filterMessageWithAttachmentsAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          const Key('filter_attachment_action'),
          SvgPicture.asset(_imagePaths.icAttachment, width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
          AppLocalizations.of(context).with_attachments,
          FilterMessageOption.attachments,
          optionCurrent: optionCurrent,
          iconLeftPadding: _responsiveUtils.isMobile(context)
              ? const EdgeInsets.only(left: 12, right: 16)
              : const EdgeInsets.only(right: 12),
          iconRightPadding: _responsiveUtils.isMobile(context)
              ? const EdgeInsets.only(right: 12)
              : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(_imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  Widget _filterMessagesUnreadAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          const Key('filter_unread_action'),
          SvgPicture.asset(_imagePaths.icUnread, width: 28, height: 28, fit: BoxFit.fill),
          AppLocalizations.of(context).unread,
          FilterMessageOption.unread,
          optionCurrent: optionCurrent,
          iconLeftPadding: _responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(left: 12, right: 16)
            : const EdgeInsets.only(right: 12),
          iconRightPadding: _responsiveUtils.isMobile(context)
            ? const EdgeInsets.only(right: 12)
            : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(_imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  Widget _filterMessageStarredAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          const Key('filter_starred_action'),
          SvgPicture.asset(_imagePaths.icStar, width: 28, height: 28, fit: BoxFit.fill),
          AppLocalizations.of(context).starred,
          FilterMessageOption.starred,
          optionCurrent: optionCurrent,
          iconLeftPadding: _responsiveUtils.isMobile(context)
              ? const EdgeInsets.only(left: 12, right: 16)
              : const EdgeInsets.only(right: 12),
          iconRightPadding: _responsiveUtils.isMobile(context)
              ? const EdgeInsets.only(right: 12)
              : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(_imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, FilterMessageOption option) {
    return [
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _filterMessageWithAttachmentsAction(context, option)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _filterMessagesUnreadAction(context, option)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _filterMessageStarredAction(context, option)),
    ];
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) {
        if (controller.isSearchActive()) {
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
          ? EdgeInsets.symmetric(vertical: controller.isSelectionEnabled() ? 4 : 12, horizontal: 4)
          : EdgeInsets.only(top: controller.isSearchActive() ? 8 : 0),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Obx(() {
        if (controller.isSearchActive()) {
          if (controller.mailboxDashBoardController.suggestionSearch.isNotEmpty) {
            return const SizedBox.shrink();
          } else {
            return _buildResultSearchEmails(context, controller.emailListSearch);
          }
        } else {
          return _buildResultListEmail(context, controller.emailList);
        }
      })
    );
  }

  Widget _buildResultSearchEmails(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    return listPresentationEmail.isNotEmpty
      ? _buildListEmailBody(context, listPresentationEmail)
      : _buildEmptyEmail(context);
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
          if (controller.isSearchActive()) {
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
        key: const PageStorageKey('list_presentation_email_in_threads'),
        itemCount: listPresentationEmail.length,
        padding: EdgeInsets.only(top: BuildUtils.isWeb && !_responsiveUtils.isDesktop(context) ? 10 : 0),
        itemBuilder: (context, index) => Obx(() => (EmailTileBuilder(
                context,
                listPresentationEmail[index],
                controller.currentMailbox?.role,
                controller.mailboxDashBoardController.currentSelectMode.value,
                controller.mailboxDashBoardController.searchState.value.searchStatus,
                controller.searchQuery)
            ..addOnPressEmailActionClick((action, email) => controller.pressEmailAction(context, action, email))
            ..addOnMoreActionClick((email, position) => _responsiveUtils.isMobile(context)
              ? controller.openContextMenuAction(context, _contextMenuActionTile(context, email))
              : controller.openPopupMenuAction(context, position, _popupMenuActionTile(context, email))))
          .build()),
      )
    );
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

  Widget _buildSuggestionBox(BuildContext context) {
    return Obx(() => controller.mailboxDashBoardController.suggestionSearch.isNotEmpty
      ? (SuggestionBoxWidget(
              context,
              _imagePaths,
              controller.mailboxDashBoardController.suggestionSearch)
          ..addOnSelectedSuggestion((suggestion) =>
              controller.mailboxDashBoardController.searchEmail(context, suggestion)))
        .build()
      : const SizedBox.shrink()
    );
  }

  Widget _buildStatusResultSearch(BuildContext context) {
    return Obx(() {
      if (controller.isSearchActive()) {
        return controller.emailListSearch.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                  borderRadius: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                      ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                      : null,
                  color: AppColor.bgStatusResultSearch),
              child: Text(
                AppLocalizations.of(context).results,
                style: const TextStyle(color: AppColor.baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
              ))
         : const SizedBox.shrink();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildEmptyTrashButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: Border.all(color: AppColor.colorLineLeftEmailView),
          color: Colors.white),
      margin: EdgeInsets.only(
          left: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 32 : 16,
          right: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 20 : 16,
          bottom: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 0 : 16,
          top: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 16 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset(_imagePaths.icDeleteTrash, fit: BoxFit.fill)),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                          AppLocalizations.of(context).message_delete_all_email_in_trash_button,
                          style: const TextStyle(color: AppColor.colorContentEmail, fontSize: 13, fontWeight: FontWeight.w500))),
                  TextButton(
                      onPressed: () => controller.deleteSelectionEmailsPermanently(context, DeleteActionType.all),
                      child: Text(
                          AppLocalizations.of(context).empty_trash_now,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton)
                      )
                  )
                ]
            )
        )
      ]),
    );
  }

  List<Widget> _contextMenuActionTile(BuildContext context, PresentationEmail email) {
    return <Widget>[
      _markAsEmailSpamOrUnSpamAction(context, email),
    ];
  }

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    return (EmailActionCupertinoActionSheetActionBuilder(
            const Key('mark_as_spam_or_un_spam_action'),
            SvgPicture.asset(
                controller.currentMailbox?.isSpam == true ? _imagePaths.icNotSpam : _imagePaths.icSpam,
                width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
            controller.currentMailbox?.isSpam == true
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
            controller.currentMailbox?.isSpam == true
                ? EmailActionType.unSpam
                : EmailActionType.moveToSpam,
            email)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(padding: const EdgeInsets.symmetric(horizontal: 8), child: _markAsEmailSpamOrUnSpamAction(context, email)),
    ];
  }
}