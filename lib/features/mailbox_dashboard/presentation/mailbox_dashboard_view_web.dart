import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_overlay.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/icon_open_advanced_search_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/download/download_task_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  final SearchController searchController = Get.find<SearchController>();

  @override
  Widget build(BuildContext context) {
    if (controller.isDrawerOpen && responsiveUtils.isDesktop(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.closeMailboxMenuDrawer();
      });
    }

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Colors.white,
      drawer: ResponsiveWidget(
          responsiveUtils: responsiveUtils,
          mobile: SizedBox(child: MailboxView(), width: ResponsiveUtils.defaultSizeDrawer),
          tablet: SizedBox(child: MailboxView(), width: ResponsiveUtils.defaultSizeDrawer),
          tabletLarge: SizedBox(child: MailboxView(), width: ResponsiveUtils.defaultSizeLeftMenuMobile),
          desktop: const SizedBox.shrink()),
      drawerEnableOpenDragGesture: !responsiveUtils.isDesktop(context),
      body: Portal(
        child: Stack(children: [
          ResponsiveWidget(
              responsiveUtils: responsiveUtils,
              desktop: Container(
                color: AppColor.colorBgDesktop,
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: responsiveUtils.defaultSizeMenu,
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 25, bottom: 25, left: 28),
                      child: Row(children: [
                        (SloganBuilder(arrangedByHorizontal: true)
                            ..setSloganText(AppLocalizations.of(context).app_name)
                            ..setSloganTextAlign(TextAlign.center)
                            ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                            ..setSizeLogo(24)
                            ..setLogo(imagePaths.icLogoTMail))
                          .build(),
                        Obx(() {
                          if (controller.appInformation.value != null) {
                            return Padding(padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'v.${controller.appInformation.value!.version}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
                              ));
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                      ])
                    ),
                    Expanded(child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(right: 10, top: 16, bottom: 10),
                      child: _buildRightHeader(context)))
                  ]),
                  Expanded(child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(child: MailboxView(), width: responsiveUtils.defaultSizeMenu),
                      Expanded(child: Column(children: [
                        Obx(() {
                          if (controller.vacationResponse.value?.vacationResponderIsReady == true) {
                            return VacationNotificationMessageWidget(
                                margin: const EdgeInsets.only(top: 16, right: 16),
                                vacationResponse: controller.vacationResponse.value!,
                                action: () => controller.disableVacationResponder());
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                        _buildMarkAsMailboxReadLoading(context),
                        Expanded(child: Obx(() {
                          switch(controller.routePath.value) {
                            case AppRoutes.THREAD:
                              return ThreadView();
                            case AppRoutes.EMAIL:
                              return EmailView();
                            default:
                              return const SizedBox.shrink();
                          }
                        }))
                      ]))
                    ],
                  ))
                ]),
              ),
              tabletLarge: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: ResponsiveUtils.defaultSizeLeftMenuMobile,
                      child: ThreadView()),
                  Expanded(child: EmailView()),
                ],
              ),
              mobile: Obx(() {
                switch(controller.routePath.value) {
                  case AppRoutes.THREAD:
                    return ThreadView();
                  case AppRoutes.EMAIL:
                    return EmailView();
                  default:
                    return ThreadView();
                }
              }),
          ),
          Obx(() => controller.composerOverlayState.value == ComposerOverlayState.active
              ? ComposerView()
              : const SizedBox.shrink()),
          Obx(() {
            if (controller.isNetworkConnectionAvailable()) {
              return const SizedBox.shrink();
            } else {
              return Align(
                  alignment: Alignment.bottomCenter,
                  child: buildNetworkConnectionWidget(context));
            }
          }),
          _buildDownloadTaskStateWidget(),
        ]),
      ),
    );
  }

  Widget _buildRightHeader(BuildContext context) {
    return Row(children: [
      Obx(() {
        if (controller.routePath.value != AppRoutes.THREAD) {
          return const SizedBox.shrink();
        }
        if (controller.isSelectionEnabled()) {
          return _buildListButtonTopBarSelection(context);
        } else {
          return searchController.isSearchActive()
            ? _buildListButtonTopBarSearchActive(context)
            : _buildListButtonTopBar(context);
        }
      }),
      const SizedBox(width: 16),
      Obx(() => !searchController.isSearchActive() ? const Spacer() : const SizedBox.shrink()),
      Obx(() {
        if (searchController.isSearchActive()) {
          return Expanded(child: _buildSearchForm(context));
        } else {
          return PortalTarget(
            visible: searchController.isAdvancedSearchViewOpen.isTrue,
            portalFollower: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => searchController.selectOpenAdvanceSearch()),
            child: PortalTarget(
              visible: searchController.isAdvancedSearchViewOpen.isTrue,
              anchor: const Aligned(
                follower: Alignment.topRight,
                target: Alignment.bottomRight,
                widthFactor: 3,
                backup: Aligned(
                  follower: Alignment.topRight,
                  target: Alignment.bottomRight,
                  widthFactor: 3,
                ),
              ),
              portalFollower: responsiveUtils.isMobile(context)
                  ? const SizedBox.shrink()
                  : const AdvancedSearchFilterOverlay(),
              child: (SearchBarView(imagePaths)
                  ..hintTextSearch(AppLocalizations.of(context).search_emails)
                  ..maxSizeWidth(240)
                  ..addOnOpenSearchViewAction(() => searchController.enableSearch())
                  ..addRightButton(IconOpenAdvancedSearchWidget(context)))
                .build(),
            ),
          );
        }
      }),
      Obx(() => !searchController.isSearchActive() ? const SizedBox(width: 16) : const SizedBox.shrink()),
      Obx(() => (AvatarBuilder()
          ..text(controller.userProfile.value?.getAvatarText() ?? '')
          ..backgroundColor(Colors.white)
          ..textColor(Colors.black)
          ..context(context)
          ..addOnTapAvatarActionWithPositionClick((position) =>
              controller.openPopupMenuAction(context, position, popupMenuUserSettingActionTile(context,
                  controller.userProfile.value,
                  onLogoutAction: () {
                    popBack();
                    controller.logoutAction();
                  },
                  onSettingAction: () {
                    popBack();
                    controller.goToSettings();
                  })))
          ..addBoxShadows([const BoxShadow(
              color: AppColor.colorShadowBgContentEmail,
              spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))])
          ..size(48))
        .build()),
      const SizedBox(width: 16)
    ]);
  }

  Widget _buildListButtonTopBar(BuildContext context) {
    return Row(children: [
      (ButtonBuilder(imagePaths.icRefresh)
          ..key(const Key('button_reload_thread'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(EdgeInsets.zero)
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 8, vertical: 8))
          ..onPressActionClick(() => controller.dispatchAction(RefreshAllEmailAction())))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(imagePaths.icSelectAll)
          ..key(const Key('button_select_all'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(SelectionAllEmailAction()))
          ..text(AppLocalizations.of(context).select_all, isVertical: false))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(imagePaths.icMarkAllAsRead)
          ..key(const Key('button_mark_all_as_read'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.markAsReadMailboxAction())
          ..text(AppLocalizations.of(context).mark_all_as_read, isVertical: false))
        .build(),
      const SizedBox(width: 16),
      Obx(() => (ButtonBuilder(imagePaths.icFilterAdvanced)
          ..key(const Key('button_filter_messages'))
          ..context(context)
          ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(TextStyle(
              fontSize: 12,
              color: controller.filterMessageOption.value == FilterMessageOption.all
                  ? AppColor.colorTextButtonHeaderThread
                  : AppColor.colorNameEmail,
              fontWeight: controller.filterMessageOption.value == FilterMessageOption.all
                  ? FontWeight.normal
                  : FontWeight.w500))
          ..addIconAction(Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SvgPicture.asset(imagePaths.icArrowDown, fit: BoxFit.fill)))
          ..addOnPressActionWithPositionClick((position) => controller.openPopupMenuAction(context, position,
              popupMenuFilterEmailActionTile(context,
                  controller.filterMessageOption.value,
                  (option) => controller.dispatchAction(FilterMessageAction(context, option)))))
          ..text(controller.filterMessageOption.value == FilterMessageOption.all
              ? AppLocalizations.of(context).filter_messages
              : controller.filterMessageOption.value.getTitle(context), isVertical: false))
        .build()),
    ]);
  }

  Widget _buildListButtonTopBarSearchActive(BuildContext context) {
    return Row(children: [
      (ButtonBuilder(imagePaths.icSelectAll)
          ..key(const Key('button_select_all'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.dispatchAction(SelectionAllEmailAction()))
          ..text(AppLocalizations.of(context).select_all, isVertical: false))
        .build(),
      const SizedBox(width: 16),
      (ButtonBuilder(imagePaths.icMarkAllAsRead)
          ..key(const Key('button_mark_all_as_read'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorButtonHeaderThread))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..size(16)
          ..padding(const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
          ..radiusSplash(10)
          ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButtonHeaderThread))
          ..onPressActionClick(() => controller.markAsReadMailboxAction())
          ..text(AppLocalizations.of(context).mark_all_as_read, isVertical: false))
        .build(),
    ]);
  }

  Widget _buildListButtonTopBarSelection(BuildContext context) {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(imagePaths.icCloseComposer, color: AppColor.colorTextButton, fit: BoxFit.fill),
          tooltip: AppLocalizations.of(context).cancel,
          onTap: () => controller.dispatchAction(CancelSelectionAllEmailAction())),
      Obx(() => Text(
          AppLocalizations.of(context).count_email_selected(controller.listEmailSelected.length),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorTextButton))),
      const SizedBox(width: 30),
      Obx(() => buildIconWeb(
          icon: SvgPicture.asset(
              controller.listEmailSelected.isAllEmailRead
                  ? imagePaths.icRead
                  : imagePaths.icUnread,
              fit: BoxFit.fill),
          tooltip: controller.listEmailSelected.isAllEmailRead
              ? AppLocalizations.of(context).mark_as_unread
              : AppLocalizations.of(context).mark_as_read,
          onTap: () => controller.dispatchAction(
              HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  controller.listEmailSelected.isAllEmailRead
                      ? EmailActionType.markAsUnread
                      : EmailActionType.markAsRead)))),
      Obx(() => buildIconWeb(
          icon: SvgPicture.asset(
              controller.listEmailSelected.isAllEmailStarred
                  ? imagePaths.icUnStar
                  : imagePaths.icStar,
              fit: BoxFit.fill),
          tooltip: controller.listEmailSelected.isAllEmailStarred
              ? AppLocalizations.of(context).un_star
              : AppLocalizations.of(context).star,
          onTap: () => controller.dispatchAction(
              HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  controller.listEmailSelected.isAllEmailStarred
                      ? EmailActionType.markAsStarred
                      : EmailActionType.unMarkAsStarred)))),
      Obx(() {
        if (controller.selectedMailbox.value?.isDrafts == false) {
          return buildIconWeb(
              icon: SvgPicture.asset(imagePaths.icMove, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).move,
              onTap: () => controller.dispatchAction(
                  HandleEmailActionTypeAction(context,
                      controller.listEmailSelected,
                      EmailActionType.moveToMailbox)));
        } else {
          return const SizedBox.shrink();
        }
      }),
      Obx(() {
        if (controller.selectedMailbox.value?.isDrafts == false) {
          return buildIconWeb(
              icon: SvgPicture.asset(
                  controller.selectedMailbox.value?.isSpam == true
                      ? imagePaths.icNotSpam
                      : imagePaths.icSpam,
                  fit: BoxFit.fill),
              tooltip: controller.selectedMailbox.value?.isSpam == true
                  ? AppLocalizations.of(context).un_spam
                  : AppLocalizations.of(context).mark_as_spam,
              onTap: () {
                if (controller.selectedMailbox.value?.isSpam == true) {
                  return controller.dispatchAction(
                      HandleEmailActionTypeAction(context,
                          controller.listEmailSelected,
                          EmailActionType.unSpam));
                } else {
                  return controller.dispatchAction(
                      HandleEmailActionTypeAction(context,
                          controller.listEmailSelected,
                          EmailActionType.moveToSpam));
                }
              });
        } else {
          return const SizedBox.shrink();
        }
      }),
      Obx(() => buildIconWeb(
          icon: SvgPicture.asset(imagePaths.icDelete, fit: BoxFit.fill),
          tooltip: controller.selectedMailbox.value?.isTrash == true
              ? AppLocalizations.of(context).delete_permanently
              : AppLocalizations.of(context).move_to_trash,
          onTap: () {
            if (controller.selectedMailbox.value?.isTrash == true) {
              return controller.dispatchAction(HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  EmailActionType.deletePermanently));
            } else {
              return controller.dispatchAction(HandleEmailActionTypeAction(context,
                  controller.listEmailSelected,
                  EmailActionType.moveToTrash));
            }
          })),
    ]);
  }

  Widget _buildSearchForm(BuildContext context) {
    return Row(
        children: [
          buildIconWeb(
              icon: SvgPicture.asset(
                  imagePaths.icBack,
                  color: AppColor.colorTextButton,
                  fit: BoxFit.fill),
              onTap: () => controller.dispatchAction(DisableSearchEmailAction())),
          Expanded(child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColor.colorBgSearchBar),
            height: 45,
            child: PortalTarget(
              visible: searchController.isAdvancedSearchViewOpen.isTrue,
              portalFollower: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => searchController.selectOpenAdvanceSearch()),
              child: PortalTarget(
                visible: searchController.isAdvancedSearchViewOpen.isTrue,
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
                portalFollower: responsiveUtils.isMobile(context)
                    ? const SizedBox.shrink()
                    : const AdvancedSearchFilterOverlay(),
                child: QuickSearchInputForm<PresentationEmail, RecentSearch>(
                    textFieldConfiguration: QuickSearchTextFieldConfiguration(
                        controller: searchController.searchInputController,
                        autofocus: true,
                        enabled: searchController.isAdvancedSearchViewOpen.isFalse,
                        focusNode: searchController.searchFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (keyword) {
                          if (keyword.trim().isNotEmpty) {
                            searchController.saveRecentSearch(RecentSearch.now(keyword));
                          }
                          controller.searchEmail(context, keyword);
                        },
                        onChanged: (query) {
                          log('MailboxDashBoardView::_buildSearchForm(): onChanged: $query');
                          searchController.onChangeTextSearch(query);
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
                                imagePaths.icSearchBar,
                                width: 16,
                                height: 16,
                                fit: BoxFit.fill),
                            onTap: () {
                              final keyword = searchController.searchInputController.text;
                              if (keyword.trim().isNotEmpty) {
                                searchController.saveRecentSearch(RecentSearch.now(keyword));
                              }
                              controller.searchEmail(context, keyword);
                            }),
                        clearTextButton: buildIconWeb(
                            icon: SvgPicture.asset(
                                imagePaths.icClearTextSearch,
                                width: 16,
                                height: 16,
                                fit: BoxFit.fill),
                            onTap: () {
                              searchController.clearTextSearch();
                            }),
                        rightButton: IconOpenAdvancedSearchWidget(context)
                    ),
                    suggestionsBoxDecoration: QuickSearchSuggestionsBoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      constraints: BoxConstraints(
                          maxWidth: responsiveUtils.isDesktop(context)
                              ? 556
                              : double.infinity),
                    ),
                    debounceDuration: const Duration(milliseconds: 500),
                    listActionButton: const [
                      QuickSearchFilter.hasAttachment,
                      QuickSearchFilter.last7Days,
                      QuickSearchFilter.fromMe,
                    ],
                    actionButtonBuilder: (context, filterAction) {
                      if (filterAction is QuickSearchFilter) {
                        return buildQuickSearchFilterButton(context, filterAction);
                      }
                      return const SizedBox.shrink();
                    },
                    buttonActionCallback: (filterAction) {
                      if (filterAction is QuickSearchFilter) {
                        controller.selectQuickSearchFilter(
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
                              searchController.saveRecentSearch(RecentSearch.now(keyword));
                            }
                            controller.searchEmail(context, keyword);
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14),
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
                      return searchController.getAllRecentSearchAction(pattern);
                    },
                    itemRecentBuilder: (context, recent) {
                      return RecentSearchItemTileWidget(recent);
                    },
                    onRecentSelected: (recent) {
                      searchController.searchInputController.text = recent.value;
                      controller.searchEmail(context, recent.value);
                    },
                    suggestionsCallback: (pattern) async {
                      return controller.quickSearchEmails();
                    },
                    itemBuilder: (context, email) {
                      return EmailQuickSearchItemTileWidget(
                          email, controller.selectedMailbox.value);
                    },
                    onSuggestionSelected: (presentationEmail) async {
                      controller.dispatchAction(
                          OpenEmailDetailedAction(context, presentationEmail));
                    }),
              ),
            ),
          )),
          const SizedBox(width: 16),
        ]
    );
  }

  Widget _buildMarkAsMailboxReadLoading(BuildContext context) {
    return Obx(() {
      final viewState = controller.viewStateMarkAsReadMailbox.value;
      return viewState.fold(
          (failure) => const SizedBox.shrink(),
          (success) {
            if (success is MarkAsMailboxReadLoading) {
              return Padding(
                  padding: EdgeInsets.only(
                      top: responsiveUtils.isDesktop(context) ? 16 : 0,
                      left: 16,
                      right: 16,
                      bottom: responsiveUtils.isDesktop(context) ? 0 : 16),
                  child: horizontalLoadingWidget);
            } else if (success is UpdatingMarkAsMailboxReadState) {
              final percent = success.countRead / success.totalUnread;
              return Padding(
                  padding: EdgeInsets.only(
                      top: responsiveUtils.isDesktop(context) ? 16 : 0,
                      left: 16,
                      right: 16,
                      bottom: responsiveUtils.isDesktop(context) ? 0 : 16),
                  child: horizontalPercentLoadingWidget(percent));
            }
            return const SizedBox.shrink();
          });
    });
  }

  Widget _buildDownloadTaskStateWidget() {
    return Obx(() {
      if (controller.downloadController.notEmptyListDownloadTask) {
        final downloadTasks = controller.downloadController.listDownloadTaskState;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: AppColor.colorBackgroundSnackBar,
            height: 60,
            width: double.infinity,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: downloadTasks.length,
                separatorBuilder: (context, index) =>
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: VerticalDivider(
                      color: Colors.grey,
                      width: 2.5,
                      thickness: 0.2),
                  ),
                itemBuilder: (context, index) =>
                    DownloadTaskItemWidget(downloadTasks[index])
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}