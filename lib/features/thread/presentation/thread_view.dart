import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_select_mode_active_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_context_menu_action_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
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
                Expanded(child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      color: responsiveUtils.isMobile(context) ? AppColor.bgMailboxListMail : AppColor.primaryLightColor,
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
              ]
            )
          )
        ),
        floatingActionButton: Obx(() => !controller.isSearchActive()
          ? FloatingActionButton(
              elevation: 4.0,
              child: new Icon(Icons.add),
              backgroundColor: AppColor.appColor,
              onPressed: () => controller.composeEmailAction())
          : SizedBox.shrink())
      ),
    );
  }

  Widget _buildAppBarThread(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          _buildAppBarNormal(context),
          if (controller.isSearchActive()) _buildSearchForm(context),
          if (controller.currentSelectMode.value == SelectMode.ACTIVE) _buildAppBarSelectModeActive(context),
        ],
      );
    });
  }

  Widget _buildSearchForm(BuildContext context) {
    return (SearchAppBarWidget(
          context,
          imagePaths,
          controller.searchQuery,
          controller.mailboxDashBoardController.suggestionSearch,
          controller.mailboxDashBoardController.searchFocus,
          controller.mailboxDashBoardController.searchInputController)
      ..addDecoration(BoxDecoration(color: Colors.white))
      ..addOnCancelSearchPressed(() => controller.disableSearch())
      ..addOnClearTextSearchAction(() => controller.mailboxDashBoardController.clearSearchText())
      ..addOnSuggestionSearchQuery((query) => controller.mailboxDashBoardController.addSuggestionSearch(query))
      ..addOnSearchTextAction((query) => controller.mailboxDashBoardController.searchEmail(query)))
    .build();
  }

  Widget _buildAppBarNormal(BuildContext context) {
    return (AppBarThreadWidgetBuilder(
              context,
              imagePaths,
              responsiveUtils,
              controller.mailboxDashBoardController.selectedMailbox.value,
              controller.mailboxDashBoardController.userProfile.value)
          ..onOpenUserInformationAction(() => {})
          ..onOpenSearchMailActionClick(() => controller.enableSearch(context))
          ..onOpenListMailboxActionClick(() => controller.openMailboxLeftMenu()))
        .build();
  }

  Widget _buildAppBarSelectModeActive(BuildContext context) {
    return (AppBarThreadSelectModeActiveBuilder(
              context,
              imagePaths,
              controller.getListEmailSelected(),
              responsiveUtils)
          ..addCloseActionClick(() => controller.cancelSelectEmail())
          // ..addRemoveEmailActionClick((listEmail) => {})
          ..addOnMarkAsEmailReadActionClick((listEmail) => controller.markAsSelectedEmailRead(listEmail))
          ..addOpenContextMenuActionClick((listEmail) =>
              controller.openContextMenuSelectedEmail(context, _contextMenuEmailActionTile(context, listEmail)))
          ..addOnOpenPopupMenuActionClick((listEmail, position) =>
              controller.openPopupMenuSelectedEmail(context, position, _popupMenuEmailActionTile(context, listEmail))))
        .build();
  }

  List<Widget> _contextMenuEmailActionTile(BuildContext context, List<PresentationEmail> listEmail) {
    return [
      // _moveToTrashAction(context, listEmail),
      _moveToMailboxAction(context, listEmail),
      _markAsReadAction(context, listEmail),
      _markAsStarAction(context, listEmail),
      // _moveToSpamAction(context, listEmail),
      SizedBox(height: 20),
    ];
  }

  Widget _markAsReadAction(BuildContext context, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
            Key('mark_as_read_context_menu_action'),
            SvgPicture.asset(imagePaths.icEyeDisable, width: 24, height: 24, fit: BoxFit.fill),
            controller.isAllEmailRead(listEmail)
                ? AppLocalizations.of(context).mark_as_unread
                : AppLocalizations.of(context).mark_as_read,
            listEmail)
          ..onActionClick((data) => controller.markAsSelectedEmailRead(data, fromContextMenuAction: true)))
        .build();
  }

  // Widget _moveToTrashAction(BuildContext context, List<PresentationEmail> listEmail) {
  //   return (EmailContextMenuActionBuilder(
  //           Key('move_to_trash_context_menu_action'),
  //           SvgPicture.asset(imagePaths.icTrash, width: 24, height: 24, fit: BoxFit.fill),
  //           AppLocalizations.of(context).move_to_trash,
  //           listEmail)
  //       ..onActionClick((data) => {}))
  //     .build();
  // }

  Widget _moveToMailboxAction(BuildContext context, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
            Key('move_to_mailbox_context_menu_action'),
            SvgPicture.asset(imagePaths.icFolder, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).move_to_mailbox,
            listEmail)
        ..onActionClick((data) => controller.moveSelectedMultipleEmailToMailboxAction(data)))
      .build();
  }

  Widget _markAsStarAction(BuildContext context, List<PresentationEmail> listEmail) {
    final markStarAction = controller.isAllEmailMarkAsStar(listEmail) ? MarkStarAction.unMarkStar : MarkStarAction.markStar;

    return (EmailContextMenuActionBuilder(
            Key('mark_as_star_context_menu_action'),
            SvgPicture.asset(
                markStarAction == MarkStarAction.markStar ? imagePaths.icFlag : imagePaths.icFlagged,
                width: 24,
                height: 24,
                fit: BoxFit.fill),
            markStarAction == MarkStarAction.markStar
                ? AppLocalizations.of(context).mark_as_star
                : AppLocalizations.of(context).mark_as_unstar,
            listEmail)
          ..onActionClick((data) => controller.markAsStarSelectedMultipleEmail(data, markStarAction)))
        .build();
  }

  // Widget _moveToSpamAction(BuildContext context, List<PresentationEmail> listEmail) {
  //   return (EmailContextMenuActionBuilder(
  //           Key('move_to_spam_context_menu_action'),
  //           SvgPicture.asset(imagePaths.icMailboxSpam, width: 24, height: 24, fit: BoxFit.fill),
  //           AppLocalizations.of(context).move_to_spam,
  //           listEmail)
  //       ..onActionClick((data) => {}))
  //     .build();
  // }

  List<PopupMenuItem> _popupMenuEmailActionTile(BuildContext context, List<PresentationEmail> listEmail) {
    return [
      // PopupMenuItem(child: _moveToTrashAction(context, listEmail)),
      PopupMenuItem(child: _moveToMailboxAction(context, listEmail)),
      PopupMenuItem(child: _markAsReadAction(context, listEmail)),
      PopupMenuItem(child: _markAsStarAction(context, listEmail)),
      // PopupMenuItem(child: _moveToSpamAction(context, listEmail)),
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
      color: responsiveUtils.isMobile(context) ? AppColor.bgMailboxListMail : Colors.white,
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
                controller.getSelectMode(listPresentationEmail[index], controller.mailboxDashBoardController.selectedEmail.value),
                listPresentationEmail[index],
                responsiveUtils,
                controller.mailboxDashBoardController.selectedMailbox.value?.role,
                controller.currentSelectMode.value,
                controller.mailboxDashBoardController.searchState.value.searchStatus,
                controller.searchQuery)
            ..onOpenEmailAction((selectedEmail) => controller.previewEmail(context, selectedEmail))
            ..onSelectEmailAction((selectedEmail) => controller.selectEmail(context, selectedEmail))
            ..addOnMarkAsStarEmailActionClick((selectedEmail) => controller.markAsStarEmail(selectedEmail)))
          .build()),
      ));
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
          ..addOnSelectedSuggestion((suggestion) => controller.mailboxDashBoardController.searchEmail(suggestion)))
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