import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/filter_message_option_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/bottom_bar_thread_selection_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/filter_message_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/suggestion_box_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadView extends GetWidget<ThreadController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
        body: SafeArea(
          right: _responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context),
          left: _responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_responsiveUtils.isDesktop(context))
                  Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(right: 10, top: 16, bottom: 10),
                      child: _buildHeader(context)),
                Obx(() => controller.isSearchActive()
                    ? _buildSearchForm(context)
                    : _responsiveUtils.isDesktop(context) ? SizedBox.shrink() : _buildAppBarNormal(context)),
                Obx(() => !controller.isSearchActive() && !_responsiveUtils.isDesktop(context)
                    ? Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                        child: (SearchBarView(_imagePaths)
                            ..hintTextSearch(AppLocalizations.of(context).hint_search_emails)
                            ..addOnOpenSearchViewAction(() => controller.enableSearch(context)))
                          .build())
                    : SizedBox.shrink()),
                Expanded(child: Container(
                    color: AppColor.colorBgDesktop,
                    margin: _responsiveUtils.isDesktop(context) ? EdgeInsets.all(16) : EdgeInsets.zero,
                    child: Stack(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: _responsiveUtils.isDesktop(context) ? BorderRadius.circular(20) : null,
                                border: _responsiveUtils.isDesktop(context) ? Border.all(color: AppColor.colorBorderBodyThread, width: 1) : null,
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
                      ],
                    ))
                ),
                Obx(() => controller.isSelectionEnabled() && !_responsiveUtils.isDesktop(context)
                    ? Column(children: [
                        Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
                        _buildOptionSelectionBottomBar(context)
                      ])
                    : SizedBox.shrink()),
              ]
          )
        ),
        floatingActionButton: Obx(() => !controller.isSearchActive() && !controller.isSelectionEnabled()
          ? Container(
              padding: EdgeInsets.only(bottom: controller.isSelectionEnabled()
                  ? 80
                  : _responsiveUtils.isMobileDevice(context) ? 0 : 16),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: ScrollingFloatingButtonAnimated(
                      icon: SvgPicture.asset(_imagePaths.icCompose, width: 20, height: 20, fit: BoxFit.fill),
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

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      Obx(() => !controller.isSelectionEnabled() && _responsiveUtils.isDesktop(context)
          ? _buildOptionTopBar(context)
          : SizedBox.shrink()),
      Obx(() => controller.isSelectionEnabled() && _responsiveUtils.isDesktop(context)
          ? _buildOptionSelectionTopBar(context)
          : SizedBox.shrink()),
      SizedBox(width: 16),
      Spacer(),
      Padding(
          padding: EdgeInsets.only(right: 16),
          child: (SearchBarView(_imagePaths)
              ..hintTextSearch(AppLocalizations.of(context).search_emails)
              ..maxSizeWidth(240)
              ..addOnOpenSearchViewAction(() => controller.enableSearch(context)))
            .build()),
      Padding(
          padding: EdgeInsets.only(right: 16),
          child: (AvatarBuilder()
              ..text(controller.mailboxDashBoardController.userProfile.value?.getAvatarText() ?? '')
              ..backgroundColor(Colors.white)
              ..textColor(Colors.black)
              ..addBoxShadows([BoxShadow(
                  color: AppColor.colorShadowBgContentEmail,
                  spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
              ..size(48))
            .build()),
    ]);
  }

  Widget _buildOptionTopBar(BuildContext context) {
    return Row(children: [
      (ButtonBuilder(_imagePaths.icRefresh)
          ..key(Key('button_reload_thread'))
          ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.zero)
          ..size(16)
          ..radiusSplash(10)
          ..padding(EdgeInsets.symmetric(horizontal: 8, vertical: 8))
          ..onPressActionClick(() => controller.refreshAllEmail()))
        .build(),
      SizedBox(width: 16),
      (ButtonBuilder(_imagePaths.icSelectAll)
          ..key(Key('button_select_all'))
          ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.only(right: 8))
          ..size(16)
          ..radiusSplash(10)
          ..padding(EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.enableSelectionEmail())
          ..text(AppLocalizations.of(context).select_all, isVertical: false))
        .build(),
      SizedBox(width: 16),
      (ButtonBuilder(_imagePaths.icMarkAllAsRead)
          ..key(Key('button_mark_all_as_read'))
          ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() {
            final listEmail = controller.isSearchActive()
              ? controller.emailListSearch.allEmailUnread
              : controller.emailList.allEmailUnread;

            if (listEmail.isNotEmpty) {
              controller.markAsSelectedEmailRead(listEmail);
            }
          })
          ..text(AppLocalizations.of(context).mark_all_as_read, isVertical: false))
        .build(),
      SizedBox(width: 16),
      (ButtonBuilder(_imagePaths.icFilterWeb)
          ..key(Key('button_filter_messages'))
          ..context(context)
          ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(TextStyle(
              fontSize: 12,
              color: controller.filterMessageOption.value == FilterMessageOption.all ? AppColor.colorTextButtonHeaderThread : AppColor.colorNameEmail,
              fontWeight: controller.filterMessageOption.value == FilterMessageOption.all ? FontWeight.normal : FontWeight.w500))
          ..addIconAction(Padding(
              padding: EdgeInsets.only(left: 8),
              child: SvgPicture.asset(_imagePaths.icArrowDown, fit: BoxFit.fill)))
          ..addOnPressActionWithPositionClick((position) =>
              controller.openFilterMessagesForTablet(
                  context,
                  position,
                  _popupMenuEmailActionTile(context, controller.filterMessageOption.value)))
          ..text(controller.filterMessageOption.value == FilterMessageOption.all
              ? AppLocalizations.of(context).filter_messages
              : controller.filterMessageOption.value.getTitle(context), isVertical: false))
        .build(),
    ]);
  }

  Widget _buildOptionSelectionTopBar(BuildContext context) {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icCloseComposer, color: AppColor.colorTextButton, fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).cancel,
          onTap: () => controller.cancelSelectEmail()),
      Text(
        AppLocalizations.of(context).count_email_selected(controller.listEmailSelected.length),
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton),),
      SizedBox(width: 30),
      buildIconWeb(
          icon: SvgPicture.asset(controller.listEmailSelected.isAllEmailRead ? _imagePaths.icUnread : _imagePaths.icRead, fit: BoxFit.fill),
          tooltip: controller.listEmailSelected.isAllEmailRead ? AppLocalizations.of(context).unread : AppLocalizations.of(context).read,
          onTap: () => controller.pressEmailSelectionAction(
              context,
              controller.listEmailSelected.isAllEmailRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
              controller.listEmailSelected)),
      buildIconWeb(
          icon: SvgPicture.asset(controller.listEmailSelected.isAllEmailStarred ? _imagePaths.icUnStar : _imagePaths.icStar, fit: BoxFit.fill),
          tooltip: controller.listEmailSelected.isAllEmailStarred ? AppLocalizations.of(context).not_starred : AppLocalizations.of(context).starred,
          onTap: () => controller.pressEmailSelectionAction(
              context,
              controller.listEmailSelected.isAllEmailStarred ? EmailActionType.markAsUnStar : EmailActionType.markAsStar,
              controller.listEmailSelected)),
      buildIconWeb(
          icon: SvgPicture.asset(_imagePaths.icMove, fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).move,
          onTap: () => controller.pressEmailSelectionAction(context, EmailActionType.move, controller.listEmailSelected)),
    ]);
  }

  Widget _buildOptionSelectionBottomBar(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: (BottomBarThreadSelectionWidget(
                context,
                _imagePaths,
                _responsiveUtils,
                controller.listEmailSelected)
            ..addOnPressEmailSelectionActionClick((actionType, selectionEmail) =>
                controller.pressEmailSelectionAction(context, actionType, selectionEmail)))
          .build());
  }

  Widget _buildSearchForm(BuildContext context) {
    return (SearchAppBarWidget(
          _imagePaths,
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
              _imagePaths,
              _responsiveUtils,
              controller.mailboxDashBoardController.selectedMailbox.value,
              controller.listEmailSelected,
              controller.currentSelectMode.value,
              controller.filterMessageOption.value)
          ..addOpenListMailboxActionClick(() => controller.openMailboxLeftMenu())
          ..addOnEditThreadAction(() => controller.enableSelectionEmail())
          ..addOnFilterEmailAction((filterMessageOption, position) =>
              _responsiveUtils.isMobileDevice(context)
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
          SvgPicture.asset(_imagePaths.icAttachment, width: 28, height: 28, fit: BoxFit.fill, color: AppColor.colorTextButton),
          AppLocalizations.of(context).with_attachments,
          FilterMessageOption.attachments,
          optionCurrent: optionCurrent,
          iconLeftPadding: _responsiveUtils.isMobile(context)
              ? EdgeInsets.only(left: 12, right: 16)
              : EdgeInsets.only(right: 12),
          iconRightPadding: _responsiveUtils.isMobile(context)
              ? EdgeInsets.only(right: 12)
              : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(_imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  Widget _filterMessagesUnreadAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          Key('filter_unread_action'),
          SvgPicture.asset(_imagePaths.icUnread, width: 28, height: 28, fit: BoxFit.fill),
          AppLocalizations.of(context).unread,
          FilterMessageOption.unread,
          optionCurrent: optionCurrent,
          iconLeftPadding: _responsiveUtils.isMobile(context)
            ? EdgeInsets.only(left: 12, right: 16)
            : EdgeInsets.only(right: 12),
          iconRightPadding: _responsiveUtils.isMobile(context)
            ? EdgeInsets.only(right: 12)
            : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(_imagePaths.icFilterSelected, fit: BoxFit.fill))
      ..onActionClick((option) => controller.filterMessagesAction(context, option)))
    .build();
  }

  Widget _filterMessageStarredAction(BuildContext context, FilterMessageOption optionCurrent) {
    return (FilterMessageCupertinoActionSheetActionBuilder(
          Key('filter_starred_action'),
          SvgPicture.asset(_imagePaths.icStar, width: 28, height: 28, fit: BoxFit.fill),
          AppLocalizations.of(context).starred,
          FilterMessageOption.starred,
          optionCurrent: optionCurrent,
          iconLeftPadding: _responsiveUtils.isMobile(context)
              ? EdgeInsets.only(left: 12, right: 16)
              : EdgeInsets.only(right: 12),
          iconRightPadding: _responsiveUtils.isMobile(context)
              ? EdgeInsets.only(right: 12)
              : EdgeInsets.zero,
          actionSelected: SvgPicture.asset(_imagePaths.icFilterSelected, fit: BoxFit.fill))
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
              ? Padding(padding: EdgeInsets.only(top: 16), child: _loadingWidget)
              : SizedBox.shrink();
        } else {
          return success is LoadingState
              ? Padding(padding: EdgeInsets.only(top: 16), child: _loadingWidget)
              : SizedBox.shrink();
        }
      }));
  }

  Widget get _loadingWidget {
    return Center(child: Padding(
        padding: EdgeInsets.zero,
        child: SizedBox(
            width: 24,
            height: 24,
            child: CupertinoActivityIndicator(color: AppColor.colorTextButton))));
  }

  Widget _buildLoadingViewLoadMore() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (controller.isSearchActive()) {
          return success is SearchingMoreState
              ? Padding(padding: EdgeInsets.only(bottom: 16), child: _loadingWidget)
              : SizedBox.shrink();
        } else {
          return success is LoadingMoreState
              ? Padding(padding: EdgeInsets.only(bottom: 16), child: _loadingWidget)
              : SizedBox.shrink();
        }
      }));
  }

  Widget _buildListEmail(BuildContext context) {
    return Container(
      margin: _responsiveUtils.isDesktop(context)
          ? EdgeInsets.only(top: 16, bottom: 16)
          : EdgeInsets.zero,
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
        physics: AlwaysScrollableScrollPhysics(),
        key: Key('presentation_email_list'),
        itemCount: listPresentationEmail.length,
        itemBuilder: (context, index) => Obx(() => (EmailTileBuilder(
                context,
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
            ..onSelectEmailAction((selectedEmail) => controller.selectEmail(context, selectedEmail))
            ..addOnMarkAsStarActionClick((selectedEmail) => controller.markAsStarEmail(selectedEmail)))
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
            ..image(SvgPicture.asset(_imagePaths.icEmptyImageDefault, width: 120, height: 120, fit: BoxFit.fill))
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
              _imagePaths,
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
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                  borderRadius: _responsiveUtils.isDesktop(context)
                      ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                      : null,
                  color: AppColor.bgStatusResultSearch),
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