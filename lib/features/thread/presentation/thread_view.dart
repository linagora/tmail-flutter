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
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_overlay.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/icon_open_advanced_search_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recent_search_item_tile_widget.dart';
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
        backgroundColor: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
        body: Portal(
          child: Row(children: [
            if ((!BuildUtils.isWeb && _responsiveUtils.isDesktop(context) && _responsiveUtils.isTabletLarge(context))
                || (BuildUtils.isWeb && _responsiveUtils.isTabletLarge(context)))
              const VerticalDivider(color: AppColor.lineItemListColor, width: 1, thickness: 0.2),
            Expanded(child: SafeArea(
                right: _responsiveUtils.isLandscapeMobile(context),
                left: _responsiveUtils.isLandscapeMobile(context),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((!_responsiveUtils.isDesktop(context) && BuildUtils.isWeb) || !BuildUtils.isWeb)
                        ... [
                          _buildAppBarNormal(context),
                          Obx(() {
                            return Stack(children: [
                              if (!controller.isSearchActive())
                                Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: BuildUtils.isWeb && !_responsiveUtils.isDesktop(context) ? 8 : 0),
                                    margin: const EdgeInsets.only(
                                        bottom: !BuildUtils.isWeb ? 16 : 0),
                                    child: _buildSearchFormInActive(context))
                              else
                                Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: BuildUtils.isWeb && !_responsiveUtils.isDesktop(context) ? 8 : 0),
                                    margin: const EdgeInsets.only(
                                        bottom: !BuildUtils.isWeb ? 16 : 0),
                                    child: _buildSearchFormActive(context))
                            ]);
                          })
                        ]
                      else
                        const SizedBox.shrink(),
                      Obx(() {
                        if (controller.isMailboxTrash
                            && controller.emailList.isNotEmpty
                            && !controller.isSearchActive()) {
                          return _buildEmptyTrashButton(context);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      Obx(() {
                        if (controller.isSearchActive()
                            && controller.searchIsActive.isTrue
                            && _responsiveUtils.isDesktop(context)
                            && BuildUtils.isWeb) {
                          return _buildListButtonQuickSearchFilter(context);
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      if (!_responsiveUtils.isDesktop(context))
                        _buildMarkAsMailboxReadLoading(context),
                      Expanded(child: Container(
                          alignment: Alignment.center,
                          margin: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                              ? const EdgeInsets.only(right: 16, top: 16, bottom: 16)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                              borderRadius: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                                  ? BorderRadius.circular(20)
                                  : null,
                              border: BuildUtils.isWeb && _responsiveUtils.isDesktop(context)
                                  ? Border.all(color: AppColor.colorBorderBodyThread, width: 1)
                                  : null,
                              color: Colors.white),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(
                                BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 20 : 0)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLoadingView(),
                                  Expanded(child: _buildListEmail(context)),
                                  _buildLoadingViewLoadMore(),
                                ]
                            ),
                          )
                      )),
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

  Widget _buildSearchFormInActive(BuildContext context) {
    return PortalTarget(
      visible: controller.searchController.isAdvancedSearchViewOpen.isTrue,
      anchor: const Aligned(
        follower: Alignment.topLeft,
        target: Alignment.bottomLeft,
        widthFactor: 1,
        backup: Aligned(
          follower: Alignment.topLeft,
          target: Alignment.bottomLeft,
          widthFactor: 1,
        ),
      ),
      portalFollower: _responsiveUtils.isMobile(context) ? const SizedBox.shrink() : const AdvancedSearchFilterOverlay(),
      child: (SearchBarView(_imagePaths)
          ..hintTextSearch(AppLocalizations.of(context).search_emails)
          ..addOnOpenSearchViewAction(() => controller.enableSearch(context))
          ..addRightButton(IconOpenAdvancedSearchWidget(context)))
        .build(),
    );
  }

  Widget _buildSearchFormActive(BuildContext context) {
    return Row(
        children: [
          buildIconWeb(
              icon: SvgPicture.asset(
                  _imagePaths.icBack,
                  color: AppColor.colorTextButton,
                  fit: BoxFit.fill),
              onTap: () => controller.closeSearchEmailAction()),
          Expanded(child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: AppColor.colorBgSearchBar),
            height: 45,
            child: PortalTarget(
              visible: controller.searchController.isAdvancedSearchViewOpen.isTrue,
              anchor: const Aligned(
                follower: Alignment.topLeft,
                target: Alignment.bottomLeft,
                widthFactor: 1,
                backup: Aligned(
                  follower: Alignment.topLeft,
                  target: Alignment.bottomLeft,
                  widthFactor: 1,
                ),
              ),
              portalFollower: _responsiveUtils.isMobile(context) ? const SizedBox.shrink() : const AdvancedSearchFilterOverlay(),
              child: QuickSearchInputForm<PresentationEmail, RecentSearch>(
                  textFieldConfiguration: QuickSearchTextFieldConfiguration(
                      controller: controller.searchController.searchInputController,
                      autofocus: true,
                      enabled: controller.searchController.isAdvancedSearchViewOpen.isFalse,
                      focusNode: controller.searchController.searchFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (keyword) {
                        if (keyword.trim().isNotEmpty) {
                          controller.searchController.saveRecentSearch(RecentSearch.now(keyword));
                        }
                        controller.mailboxDashBoardController.searchEmail(context, keyword);
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: AppLocalizations.of(context).search_mail,
                          hintStyle: const TextStyle(
                              color: AppColor.colorHintSearchBar,
                              fontSize: 17.0),
                          labelStyle: const TextStyle(
                              color: AppColor.colorHintSearchBar,
                              fontSize: 17.0)
                      ),
                      leftButton: buildIconWeb(
                          icon: SvgPicture.asset(
                              _imagePaths.icSearchBar,
                              width: 16,
                              height: 16,
                              fit: BoxFit.fill),
                          onTap: () {
                            final keyword = controller.currentTextSearch;
                            if (keyword.trim().isNotEmpty) {
                              controller.searchController.saveRecentSearch(RecentSearch.now(keyword));
                            }
                            controller.mailboxDashBoardController.searchEmail(context, keyword);
                          }),
                      clearTextButton: buildIconWeb(
                          icon: SvgPicture.asset(
                              _imagePaths.icClearTextSearch,
                              width: 16,
                              height: 16,
                              fit: BoxFit.fill),
                          onTap: () {
                            controller.clearTextSearch();
                          }),
                      rightButton: IconOpenAdvancedSearchWidget(context)
                  ),
                  suggestionsBoxDecoration: const QuickSearchSuggestionsBoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  debounceDuration: const Duration(milliseconds: 500),
                  hideSuggestionsBox: _responsiveUtils.isScreenWithShortestSide(context),
                  listActionButton: const [
                    QuickSearchFilter.hasAttachment,
                    QuickSearchFilter.last7Days,
                    QuickSearchFilter.fromMe,
                  ],
                  actionButtonBuilder: (context, filterAction) {
                    if (filterAction is QuickSearchFilter) {
                      return _buildQuickSearchFilterButtonSuggestionBox(
                          context,
                          filterAction);
                    }
                    return const SizedBox.shrink();
                  },
                  buttonActionCallback: (filterAction) {
                    if (filterAction is QuickSearchFilter) {
                      controller.mailboxDashBoardController.selectQuickSearchFilter(
                        quickSearchFilter: filterAction,
                        fromSuggestionBox: true,
                      );
                    }
                  },
                  listActionPadding: const EdgeInsets.only(
                    left: 24, right: 24, top: 20, bottom: 12),
                  titleHeaderRecent: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(AppLocalizations.of(context).recent,
                          style: const TextStyle(fontSize: 13.0,
                              color: AppColor.colorTextButtonHeaderThread,
                              fontWeight: FontWeight.w500)
                      )
                  ),
                  buttonShowAllResult: (context, keyword) {
                    if (keyword is String) {
                      return InkWell(
                        onTap: () {
                          if (keyword.trim().isNotEmpty) {
                            controller.searchController.saveRecentSearch(RecentSearch.now(keyword));
                          }
                          controller.mailboxDashBoardController.searchEmail(context, keyword);
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(children: [
                              Text(AppLocalizations.of(context).showingResultsFor,
                                  style: const TextStyle(fontSize: 13.0,
                                      color: AppColor.colorTextButtonHeaderThread,
                                      fontWeight: FontWeight.w500)
                              ),
                              const SizedBox(width: 4),
                              Expanded(child: Text('"$keyword"',
                                  style: const TextStyle(
                                      fontSize: 13.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)))
                            ])
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                  loadingBuilder: (context) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: loadingWidget,
                  ),
                  fetchRecentActionCallback: (pattern) async {
                    return controller.searchController.getAllRecentSearchAction(pattern);
                  },
                  itemRecentBuilder: (context, recent) {
                    return RecentSearchItemTileWidget(recent);
                  },
                  onRecentSelected: (recent) {
                    controller.searchController.updateTextSearch(recent.value);
                    controller.mailboxDashBoardController.searchEmail(context, recent.value);
                  },
                  suggestionsCallback: (pattern) async {
                    return controller.mailboxDashBoardController.quickSearchEmails();
                  },
                  itemBuilder: (context, email) {
                    return EmailQuickSearchItemTileWidget(
                        email,
                        controller.currentMailbox);
                  },
                  onSuggestionSelected: (presentationEmail) async {
                    controller.pressEmailAction(
                        context,
                        EmailActionType.preview,
                        presentationEmail);
                  }),
            ),
          )),
          const SizedBox(width: 16),
        ]
    );
  }

  Widget _buildAppBarNormal(BuildContext context) {
    return Obx(() {
      return (AppBarThreadWidgetBuilder(
              context,
              controller.currentMailbox,
              controller.listEmailSelected,
              controller.mailboxDashBoardController.currentSelectMode.value,
              controller.mailboxDashBoardController.filterMessageOption.value)
          ..addOpenMailboxMenuActionClick(() => controller.openMailboxLeftMenu())
          ..addOnEditThreadAction(() => controller.enableSelectionEmail())
          ..addOnEmailSelectionAction((actionType, selectionEmail) =>
              controller.pressEmailSelectionAction(context, actionType, selectionEmail))
          ..addOnFilterEmailAction((filterMessageOption, position) {
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
          })
          ..addOnCancelEditThread(() => controller.cancelSelectEmail()))
        .build();
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
              text: Padding(padding: const EdgeInsets.only(right: 10),
                child: Text(AppLocalizations.of(context).compose,
                  style: const TextStyle(color: AppColor.colorTextButton, fontSize: 15.0, fontWeight: FontWeight.w500))),
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
        padding: EdgeInsets.zero,
        key: const PageStorageKey('list_presentation_email_in_threads'),
        itemCount: listPresentationEmail.length,
        itemBuilder: (context, index) => Obx(() => (EmailTileBuilder(
                context,
                listPresentationEmail[index],
                controller.currentMailbox?.role,
                controller.mailboxDashBoardController.currentSelectMode.value,
                controller.searchController.searchState.value.searchStatus,
                controller.searchQuery,
        )
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

  Widget _buildEmptyTrashButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: Border.all(color: AppColor.colorLineLeftEmailView),
          color: Colors.white),
      margin: EdgeInsets.only(
          left: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 0 : 16,
          right: 16,
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

  Widget _buildListButtonQuickSearchFilter(BuildContext context) {
    final listQuickSearchFilter = [
      QuickSearchFilter.hasAttachment,
      QuickSearchFilter.last7Days,
      QuickSearchFilter.fromMe,
    ];
    return Padding(
      padding: EdgeInsets.only(
          left: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 32 : 16,
          right: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 20 : 16,
          bottom: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 0 : 16,
          top: BuildUtils.isWeb && _responsiveUtils.isDesktop(context) ? 16 : 0),
      child: Row(
          children: listQuickSearchFilter
              .map((filter) => _buildQuickSearchFilterButton(context, filter))
              .toList()),
    );
  }

  Widget _buildQuickSearchFilterButton(
      BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      final quickSearchFilterSelected = controller.mailboxDashBoardController.checkQuickSearchFilterSelected(
          quickSearchFilter: filter,
      );

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () {
            if (filter != QuickSearchFilter.last7Days) {
              controller.selectQuickSearchFilter(filter);
            }
          },
          onTapDown: (detail) {
            if (filter == QuickSearchFilter.last7Days) {
              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              controller.openPopupReceiveTimeQuickSearchFilter(context, position,
                  popupMenuEmailReceiveTimeType(context,
                      controller.searchController.emailReceiveTimeType.value,
                      (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(receiveTime)));
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filter.getBackgroundColor(quickSearchFilterSelected: quickSearchFilterSelected)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filter.getIcon(_imagePaths, quickSearchFilterSelected: quickSearchFilterSelected),
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filter.getTitle(context, receiveTimeType: controller.searchController.emailReceiveTimeType.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: filter.getTextStyle(quickSearchFilterSelected: quickSearchFilterSelected),
                ),
                if (filter == QuickSearchFilter.last7Days)
                  ... [
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                        _imagePaths.icChevronDown,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill),
                  ]
              ])),
        ),
      );
    });
  }

  List<PopupMenuEntry> popupMenuEmailReceiveTimeType(BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected, Function(EmailReceiveTimeType?)? onCallBack) {
    return EmailReceiveTimeType.values
        .map((timeType) => PopupMenuItem(
            padding: EdgeInsets.zero,
            child: _receiveTimeTileAction(context, receiveTimeSelected, timeType, onCallBack)))
        .toList();
  }

  Widget _receiveTimeTileAction(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      EmailReceiveTimeType receiveTimeType,
      Function(EmailReceiveTimeType?)? onCallBack
  ) {
    return InkWell(
        onTap: () => onCallBack?.call(receiveTimeType == receiveTimeSelected
            ? null
            : receiveTimeType),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SizedBox(
              width: 320,
              child: Row(children: [
                Expanded(child: Text(
                    receiveTimeType.getTitle(context),
                    style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.normal))),
                if (receiveTimeType == receiveTimeSelected)
                  const SizedBox(width: 12),
                if (receiveTimeType == receiveTimeSelected)
                  SvgPicture.asset(_imagePaths.icFilterSelected, width: 24, height: 24, fit: BoxFit.fill),
              ])
          ),
        )
    );
  }

  Widget _buildQuickSearchFilterButtonSuggestionBox(
      BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      final quickSearchFilterSelected = controller.mailboxDashBoardController.checkQuickSearchFilterSelected(
        quickSearchFilter: filter,
      );

      return Chip(
        labelPadding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
        label: Text(
          filter.getTitle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: filter.getTextStyle(quickSearchFilterSelected: quickSearchFilterSelected),
        ),
        avatar: SvgPicture.asset(
            filter.getIcon(_imagePaths, quickSearchFilterSelected: quickSearchFilterSelected),
            width: 16,
            height: 16,
            fit: BoxFit.fill),
        labelStyle: filter.getTextStyle(quickSearchFilterSelected: quickSearchFilterSelected),
        backgroundColor: filter.getBackgroundColor(quickSearchFilterSelected: quickSearchFilterSelected),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: filter.getBackgroundColor(quickSearchFilterSelected: quickSearchFilterSelected)),
        ),
      );
    });
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