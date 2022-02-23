import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/bottom_bar_thread_selection_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/filter_message_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_bar_thread_view_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/suggestion_box_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadView extends GetWidget<ThreadController> {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          right: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
          left: responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBarThread(context),
                Obx(() => !controller.isSearchActive()
                  ? (SearchBarThreadViewWidget(imagePaths)
                      ..hintTextSearch(AppLocalizations.of(context).hint_search_emails)
                      ..addOnOpenSearchViewAction(() => controller.enableSearch(context)))
                    .build()
                  : SizedBox.shrink()),
                Expanded(child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusResultSearch(context),
                          _buildLoadingView(),
                          Expanded(child: _buildListEmail(context)),
                          _buildLoadingViewLoadMore()
                        ]
                      )
                    ),
                    _buildSuggestionBox(context)
                  ],
                )),
                Obx(() => controller.isSelectionEnabled()
                  ? Column(children: [
                      Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
                      _buildOptionSelectionBottomBar(context)
                    ])
                  : SizedBox.shrink()),
              ]
            )
          )
        ),
        floatingActionButton: Obx(() => !controller.isSearchActive() && !controller.isSelectionEnabled()
          ? Container(
              padding: EdgeInsets.only(bottom: controller.isSelectionEnabled()
                  ? 80
                  : responsiveUtils.isMobileDevice(context) ? 0 : 16),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: ScrollingFloatingButtonAnimated(
                      icon: SvgPicture.asset(imagePaths.icCompose, width: 20, height: 20, fit: BoxFit.fill),
                      text: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                              AppLocalizations.of(context).compose,
                              style: TextStyle(color: AppColor.colorTextButton, fontSize: 15.0, fontWeight: FontWeight.w500))
                      ),
                      onPress: () => controller.composeEmailAction(),
                      scrollController: controller.listEmailController,
                      color: Colors.white,
                      elevation: 4.0,
                      width: 140,
                      animateIcon: false)))
          : SizedBox.shrink()),
      ),
    );
  }

  Widget _buildAppBarThread(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          if (!controller.isSearchActive()) _buildAppBarNormal(context),
          if (controller.isSearchActive()) _buildSearchForm(context),
        ],
      );
    });
  }

  Widget _buildOptionSelectionBottomBar(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: (BottomBarThreadSelectionWidget(
                context,
                imagePaths,
                responsiveUtils,
                controller.getListEmailSelected())
            ..addOnPressEmailSelectionActionClick((actionType, selectionEmail) =>
                controller.pressEmailSelectionAction(context, actionType, selectionEmail)))
          .build());
  }

  Widget _buildSearchForm(BuildContext context) {
    return (SearchAppBarWidget(
          imagePaths,
          controller.searchQuery,
          controller.mailboxDashBoardController.searchFocus,
          controller.mailboxDashBoardController.searchInputController,
          suggestionSearch: controller.mailboxDashBoardController.suggestionSearch,)
      ..addDecoration(BoxDecoration(color: Colors.white))
      ..setMargin(EdgeInsets.only(right: 10))
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
              imagePaths,
              responsiveUtils,
              controller.mailboxDashBoardController.selectedMailbox.value,
              controller.getListEmailSelected(),
              controller.currentSelectMode.value,
              controller.filterMessageOption.value)
          ..addOpenListMailboxActionClick(() => controller.openMailboxLeftMenu())
          ..addOnEditThreadAction(() => controller.enableSelectionEmail())
          ..addOnFilterEmailAction((filterMessageOption, position) =>
              responsiveUtils.isMobileDevice(context)
                ? controller.openFilterMessagesCupertinoActionSheet(
                    context,
                    _filterMessagesCupertinoActionTile(context, filterMessageOption),
                    cancelButton: _buildCupertinoActionCancelButton(context))
                : controller.openFilterMessagesForTablet(
                    context,
                    position,
                    _popupMenuEmailActionTile(context, filterMessageOption)))
          ..addOnCancelEditThread(() => controller.cancelSelectEmail()))
        .build();
  }

  List<Widget> _filterMessagesCupertinoActionTile(BuildContext context, FilterMessageOption optionCurrent) {
    return <Widget>[
      _filterMessageWithAttachmentsAction(context, optionCurrent),
      _filterMessagesUnreadAction(context, optionCurrent),
      _filterMessageStarredAction(context, optionCurrent),
    ];
  }

  Widget _buildCupertinoActionCancelButton(BuildContext context) {
    return CupertinoActionSheetAction(
      child: Text(
        AppLocalizations.of(context).cancel,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: AppColor.colorTextButton)),
      onPressed: () => controller.closeFilterMessageActionSheet(),
    );
  }

  Widget _filterMessageWithAttachmentsAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          Key('filter_attachment_action'),
          SvgPicture.asset(imagePaths.icAttachment, width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
          AppLocalizations.of(context).with_attachments,
          FilterMessageOption.attachments,
          optionCurrent: optionCurrent,
          iconLeftPadding: responsiveUtils.isMobile(context)
              ? EdgeInsets.only(left: 12, right: 16)
              : EdgeInsets.only(right: 12),
          iconRightPadding: responsiveUtils.isMobile(context)
              ? EdgeInsets.only(right: 12)
              : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  Widget _filterMessagesUnreadAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          Key('filter_unread_action'),
          SvgPicture.asset(imagePaths.icUnreadV2, width: 28, height: 28, fit: BoxFit.fill),
          AppLocalizations.of(context).unread,
          FilterMessageOption.unread,
          optionCurrent: optionCurrent,
          iconLeftPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(left: 12, right: 16)
            : EdgeInsets.only(right: 12),
          iconRightPadding: responsiveUtils.isMobile(context)
            ? EdgeInsets.only(right: 12)
            : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  Widget _filterMessageStarredAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          Key('filter_starred_action'),
          SvgPicture.asset(imagePaths.icStar, width: 28, height: 28, fit: BoxFit.fill),
          AppLocalizations.of(context).starred,
          FilterMessageOption.starred,
          optionCurrent: optionCurrent,
          iconLeftPadding: responsiveUtils.isMobile(context)
              ? EdgeInsets.only(left: 12, right: 16)
              : EdgeInsets.only(right: 12),
          iconRightPadding: responsiveUtils.isMobile(context)
              ? EdgeInsets.only(right: 12)
              : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(BuildContext context, FilterMessageOption option) {
    return [
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _filterMessageWithAttachmentsAction(context, option)),
      PopupMenuDivider(height: 0.5),
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _filterMessagesUnreadAction(context, option)),
      PopupMenuDivider(height: 0.5),
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: _filterMessageStarredAction(context, option)),
    ];
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (controller.isSearchActive()) {
          return success is SearchingState
              ? Center(child: Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppColor.primaryColor))))
              : SizedBox.shrink();
        } else {
          return success is LoadingState
            ? Center(child: Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: AppColor.primaryColor))))
            : SizedBox.shrink();
        }
      }));
  }

  Widget _buildLoadingViewLoadMore() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (controller.isSearchActive()) {
          return success is SearchingMoreState
            ? Center(child: Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: AppColor.primaryColor))))
            : SizedBox.shrink();
        } else {
          return success is LoadingMoreState
            ? Center(child: Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: AppColor.primaryColor))))
            : SizedBox.shrink();
        }
      }));
  }

  Widget _buildListEmail(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: Colors.white,
      child: Obx(() {
        if (controller.isSearchActive()) {
          if (controller.mailboxDashBoardController.suggestionSearch.isNotEmpty) {
            return SizedBox.shrink();
          } else {
            return _buildResultSearchEmails(context, controller.emailListSearch);
          }
        } else {
          return _buildResultListEmail(
              context,
              controller.isFilterMessagesEnabled ? controller.emailListFiltered : controller.emailList);
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
    if (controller.currentSelectMode.value == SelectMode.INACTIVE) {
      return listPresentationEmail.isNotEmpty
        ? RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: () async => controller.refreshAllEmail(),
            child: _buildListEmailBody(context, listPresentationEmail))
        : RefreshIndicator(
            color: AppColor.primaryColor,
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
            && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
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
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 16),
        key: Key('presentation_email_list'),
        itemCount: listPresentationEmail.length,
        itemBuilder: (context, index) => Obx(() => (EmailTileBuilder(
                context,
                imagePaths,
                listPresentationEmail[index],
                controller.mailboxDashBoardController.selectedMailbox.value?.role,
                controller.currentSelectMode.value,
                controller.mailboxDashBoardController.searchState.value.searchStatus,
                controller.searchQuery)
            ..onOpenEmailAction((selectedEmail) {
              if (controller.mailboxDashBoardController.selectedMailbox.value?.role == PresentationMailbox.roleDrafts) {
                controller.editEmail(selectedEmail);
              } else {
                controller.previewEmail(context, selectedEmail);
              }
            })
            ..onSelectEmailAction((selectedEmail) => controller.selectEmail(context, selectedEmail)))
          .build()),
      )
    );
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => !(success is LoadingState) && !(success is SearchingState)
        ? (BackgroundWidgetBuilder(context)
            ..key(Key('empty_email_background'))
            ..image(SvgPicture.asset(imagePaths.icEmptyImageDefault, width: 120, height: 120, fit: BoxFit.fill))
            ..text(controller.isSearchActive()
                ? AppLocalizations.of(context).no_emails_matching_your_search
                : AppLocalizations.of(context).no_emails))
          .build()
        : SizedBox.shrink())
    );
  }

  Widget _buildSuggestionBox(BuildContext context) {
    return Obx(() => controller.mailboxDashBoardController.suggestionSearch.isNotEmpty
      ? (SuggestionBoxWidget(
              context,
              imagePaths,
              controller.mailboxDashBoardController.suggestionSearch)
          ..addOnSelectedSuggestion((suggestion) =>
              controller.mailboxDashBoardController.searchEmail(context, suggestion)))
        .build()
      : SizedBox.shrink()
    );
  }

  Widget _buildStatusResultSearch(BuildContext context) {
    return Obx(() {
      if (controller.isSearchActive()) {
        return controller.emailListSearch.length > 0
          ? Container(
              width: double.infinity,
              margin: EdgeInsets.zero,
              color: AppColor.bgStatusResultSearch,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Text(
                AppLocalizations.of(context).results,
                style: TextStyle(color: AppColor.baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
              ))
         : SizedBox.shrink();
      } else {
        return SizedBox.shrink();
      }
    });
  }
}