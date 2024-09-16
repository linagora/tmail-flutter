
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/contact_quick_search_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/simple_search_filter.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/utils/search_email_utils.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/app_bar_selection_mode.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/email_receive_time_action_tile_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/email_receive_time_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/email_sort_by_action_tile_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/email_sort_by_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/search_email_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SearchEmailView extends GetWidget<SearchEmailController>
    with AppLoaderMixin {

  SearchEmailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.responsiveUtils.isWebDesktop(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.closeSearchView(context: context);
      });
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white,
          child: Column(children: [
            Container(
                height: 52,
                color: Colors.white,
                padding: SearchEmailUtils.getPaddingAppBar(context, controller.responsiveUtils),
                child: Obx(() {
                  if (controller.selectionMode.value == SelectMode.ACTIVE) {
                    return AppBarSelectionMode(
                        controller.listResultSearch.listEmailSelected,
                        controller.mailboxDashBoardController.mapMailboxById,
                        onCancelSelection: controller.cancelSelectionMode,
                        onHandleEmailAction: (actionType, listEmails) =>
                            controller.handleSelectionEmailAction(context, actionType, listEmails));
                  } else {
                    return _buildSearchInputForm(context);
                  }
                })
            ),
            const Divider(color: AppColor.colorDividerComposer, height: 1),
            _buildListSearchFilterAction(context),
            Obx(() => SearchEmailLoadingBarWidget(
              suggestionViewState: controller.suggestionSearchViewState.value,
              resultSearchViewState: controller.viewState.value,
            )),
            Expanded(child: Obx(() {
              if (controller.searchIsRunning.isFalse) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(children: [
                    if (controller.currentSearchText.value.isNotEmpty)
                      _buildShowAllResultSearchButton(context, controller.currentSearchText.value),
                    if (controller.listContactSuggestionSearch.isNotEmpty
                        && controller.currentSearchText.isNotEmpty)
                      _buildListContactSuggestionSearch(context, controller.listContactSuggestionSearch),
                    if (controller.listContactSuggestionSearch.isNotEmpty
                        && controller.listSuggestionSearch.isNotEmpty)
                      const Divider(),
                    if (controller.listSuggestionSearch.isNotEmpty && controller.currentSearchText.isNotEmpty)
                      _buildListSuggestionSearch(context, controller.listSuggestionSearch)
                    else if (controller.listRecentSearch.isNotEmpty && controller.listSuggestionSearch.isEmpty)
                      _buildListRecentSearch(context, controller.listRecentSearch)
                  ]),
                );
              } else {
                if (controller.listResultSearch.isNotEmpty) {
                  return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildListEmailBody(context, controller.listResultSearch)
                  );
                } else {
                  return _buildEmptyEmail(context);
                }
              }
            })),
            _buildLoadingViewLoadMore(),
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchInputForm(BuildContext context) {
    return Row(
        children: [
          buildIconWeb(
              icon: SvgPicture.asset(
                DirectionUtils.isDirectionRTLByLanguage(context) ? controller.imagePaths.icCollapseFolder : controller.imagePaths.icBack,
                colorFilter: AppColor.colorTextButton.asFilter(),
                fit: BoxFit.fill
              ),
              tooltip: AppLocalizations.of(context).back,
              onTap: () => controller.closeSearchView(context: context)
          ),
          Expanded(child: TextFieldBuilder(
            onTextChange: controller.onTextSearchChange,
            textInputAction: TextInputAction.search,
            controller: controller.textInputSearchController,
            focusNode: controller.textInputSearchFocus,
            maxLines: 1,
            textDirection: DirectionUtils.getDirectionByLanguage(context),
            textStyle: const TextStyle(color: Colors.black, fontSize: 16),
            keyboardType: TextInputType.text,
            onTextSubmitted: (text) => controller.onTextSearchSubmitted(context, text),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              hintText: AppLocalizations.of(context).search_emails,
              hintStyle: const TextStyle(color: AppColor.loginTextFieldHintColor, fontSize: 16),
              border: InputBorder.none),
          )),
          Obx(() {
            if (controller.currentSearchText.isNotEmpty) {
              return
                buildIconWeb(
                    icon: SvgPicture.asset(
                        controller.imagePaths.icClearTextSearch,
                        width: 18,
                        height: 18,
                        fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).clearAll,
                    onTap: controller.clearAllTextInputSearchForm);
            } else {
              return const SizedBox.shrink();
            }
          })
        ]
    );
  }

  Widget _buildListSearchFilterAction(BuildContext context) {
    return Container(
      margin: SearchEmailUtils.getMarginSearchFilterButton(context, controller.responsiveUtils),
      padding: SearchEmailUtils.getPaddingSearchFilterButton(context, controller.responsiveUtils),
      height: 60,
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildSearchFilterByContactButton(context, PrefixEmailAddress.from),
            _buildSearchFilterByContactButton(context, PrefixEmailAddress.to),
            ...[
              QuickSearchFilter.hasAttachment,
              QuickSearchFilter.last7Days
            ].map((filter) => _buildQuickSearchFilterButton(context, filter)),
            _buildSearchFilterByMailboxButton(context),
            _buildQuickSearchFilterButton(context, QuickSearchFilter.sortBy)
          ],
      ),
    );
  }

  Widget _buildQuickSearchFilterButton(BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      final filterSelected = controller.checkQuickSearchFilterSelected(filter);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();

            if (filter == QuickSearchFilter.hasAttachment) {
              controller.selectQuickSearchFilter(context, filter);
            } else if (controller.responsiveUtils.isMobile(context)) {
              if (filter == QuickSearchFilter.last7Days) {
                controller.openContextMenuAction(
                  context,
                  _emailReceiveTimeCupertinoActionTile(
                      context,
                      controller.emailReceiveTimeType.value,
                      (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(context, receiveTime)));
              } else {
                controller.openContextMenuAction(
                context,
                _emailSortOrderCupertinoActionTitle(
                  context,
                  controller.emailSortOrderType.value,
                  controller.selectSortOrderQuickSearchFilter
                )
              );
              }
            }
          },
          onTapDown: (detail) {
            if (!controller.responsiveUtils.isMobile(context)) {
              FocusScope.of(context).unfocus();

              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              if (filter == QuickSearchFilter.last7Days) {
                controller.openPopupMenuAction(
                  context,
                  position,
                  _popupMenuEmailReceiveTimeType(
                      context,
                      controller.emailReceiveTimeType.value,
                      (receiveTime) => controller.selectReceiveTimeQuickSearchFilter(context, receiveTime)));
              } else if (filter == QuickSearchFilter.sortBy) {
                controller.openPopupMenuAction(
                  context,
                  position,
                  _popupMenuEmailSortOrderType(
                    context,
                    controller.emailSortOrderType.value,
                    controller.selectSortOrderQuickSearchFilter
                  )
                );
              }
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filter.getBackgroundColor(isFilterSelected: filterSelected)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filter.getIcon(controller.imagePaths, isSelected: filterSelected),
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filter.getTitle(
                    context,
                    receiveTimeType: controller.emailReceiveTimeType.value,
                    startDate: controller.simpleSearchFilter.value.startDate?.value.toLocal(),
                    endDate: controller.simpleSearchFilter.value.endDate?.value.toLocal(),
                    sortOrderType: controller.emailSortOrderType.value
                  ),
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColor.colorTextButtonHeaderThread),
                ),
                if (filter == QuickSearchFilter.last7Days || filter == QuickSearchFilter.sortBy)
                  ... [
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                        controller.imagePaths.icChevronDownOutline,
                        colorFilter: filterSelected
                          ? AppColor.primaryColor.asFilter()
                          : AppColor.colorDefaultRichTextButton.asFilter(),
                        fit: BoxFit.fill),
                  ]
              ])
          ),
        ),
      );
    });
  }

  List<PopupMenuEntry> _popupMenuEmailReceiveTimeType(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      Function(EmailReceiveTimeType)? onCallBack
  ) {
    return EmailReceiveTimeType.values
      .map((timeType) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: EmailReceiveTimeActionTileWidget(
          receiveTimeSelected: receiveTimeSelected,
          receiveTimeType: timeType,
          onCallBack: onCallBack
        )))
      .toList();
  }

  List<Widget> _emailReceiveTimeCupertinoActionTile(
      BuildContext context,
      EmailReceiveTimeType? receiveTimeSelected,
      Function(EmailReceiveTimeType)? onCallBack
  ) {
    return EmailReceiveTimeType.values
        .map((timeType) => (EmailReceiveTimeCupertinoActionSheetActionBuilder(
                timeType.getTitle(context),
                timeType,
                timeTypeCurrent: receiveTimeSelected,
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
            ..onActionClick((timeType) => onCallBack?.call(timeType)))
            .build())
        .toList();
  }

  List<PopupMenuEntry> _popupMenuEmailSortOrderType(
    BuildContext context,
    EmailSortOrderType? sortTypeSelected,
    Function(BuildContext, EmailSortOrderType)? onCallBack
  ) {
    return EmailSortOrderType.values
      .map((sortType) => PopupMenuItem(
        padding: EdgeInsets.zero,
        child: EmailSortByActionTitleWidget(
          sortType: sortType,
          imagePaths: controller.imagePaths,
          onSortOrderSelected: onCallBack,
          sortTypeSelected: sortTypeSelected,
        ),
      )).toList();
  }

  List<Widget> _emailSortOrderCupertinoActionTitle(
    BuildContext context,
    EmailSortOrderType? sortOrderSelected,
    Function(BuildContext context, EmailSortOrderType)? onCallBack,
  ) {
    return EmailSortOrderType.values
      .map(
        (sortType) => (
          EmailSortByCupertinoActionSheetActionBuilder(
            sortType.getTitle(context),
            sortType,
            sortTypeCurrent: sortOrderSelected,
            iconLeftPadding: controller.responsiveUtils.isMobile(context)
              ? const EdgeInsetsDirectional.only(start: 12, end: 16)
              : const EdgeInsetsDirectional.only(start: 12),
            iconRightPadding: controller.responsiveUtils.isMobile(context)
              ? const EdgeInsetsDirectional.only(end: 12)
              : EdgeInsetsDirectional.zero,
            actionSelected: SvgPicture.asset(
              controller.imagePaths.icFilterSelected,
              width: 20,
              height: 20,
              fit: BoxFit.fill
            )
          )
          ..onActionClick((sortType) => onCallBack?.call(context, sortType))
        ).build()
      ).toList();
  }

  Widget _buildShowAllResultSearchButton(BuildContext context, String textSearch) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final query = textSearch.trim();
          if (query.isNotEmpty) {
            controller.saveRecentSearch(RecentSearch.now(query));
            controller.showAllResultSearchAction(context, query);
          }
        },
        child: Padding(
            padding: SearchEmailUtils.getPaddingShowAllResultButton(context, controller.responsiveUtils),
            child: Row(children: [
              Text(AppLocalizations.of(context).showingResultsFor,
                  style: const TextStyle(fontSize: 13.0,
                      color: AppColor.colorTextButtonHeaderThread,
                      fontWeight: FontWeight.w500)
              ),
              const SizedBox(width: 4),
              Expanded(child: Text('"${controller.currentSearchText.value}"',
                  style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)))
            ])
        ),
      ),
    );
  }

  Widget _buildListRecentSearch(
      BuildContext context,
      List<RecentSearch> listRecentSearch
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: SearchEmailUtils.getPaddingSearchRecentTitle(context, controller.responsiveUtils),
          child: Text(AppLocalizations.of(context).recent,
              style: const TextStyle(fontSize: 13.0,
                  color: AppColor.colorTextButtonHeaderThread,
                  fontWeight: FontWeight.w500)
          )
      ),
      ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: listRecentSearch.length,
          itemBuilder: (context, index) {
            final recentSearch = listRecentSearch[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                child: RecentSearchItemTileWidget(
                    recentSearch,
                    contentPadding: SearchEmailUtils.getPaddingListRecentSearch(context, controller.responsiveUtils)),
                onTap: () => controller.searchEmailByRecentAction(context, recentSearch),
              ),
            );
          })
    ]);
  }

  Widget _buildListSuggestionSearch(
      BuildContext context,
      List<PresentationEmail> listSuggestionSearch
  ) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: listSuggestionSearch.length,
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              child: EmailQuickSearchItemTileWidget(
                  listSuggestionSearch[index],
                  controller.currentMailbox,
                  contentPadding: SearchEmailUtils.getPaddingSearchSuggestionList(context, controller.responsiveUtils)),
              onTap: () {
                final emailPreview = listSuggestionSearch[index];
                final mailboxContain = emailPreview
                    .findMailboxContain(controller.mailboxDashBoardController.mapMailboxById);
                controller.pressEmailAction(
                    context,
                    EmailActionType.preview,
                    emailPreview,
                    mailboxContain: mailboxContain);
              },
            ),
          );
        });
  }

  Widget _buildListContactSuggestionSearch(
    BuildContext context,
    List<EmailAddress> listContactSuggestionSearch
  ) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: listContactSuggestionSearch.length,
      itemBuilder: (context, index) {
        final emailAddress = listContactSuggestionSearch[index];
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            child: ContactQuickSearchItem(emailAddress: emailAddress),
            onTap: () => controller.searchEmailByEmailAddressAction(
              context,
              emailAddress
            ),
          ),
        );
      }
    );
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) => success is! SearchingState
            ? EmptyEmailsWidget(
                key: const Key('empty_search_email_view'),
                isNetworkConnectionAvailable: controller.networkConnectionController.isNetworkConnectionAvailable(),
                isSearchActive: true)
            : const SizedBox.shrink())
    );
  }

  Widget _buildListEmailBody(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification
              && controller.searchMoreState != SearchMoreState.waiting
              && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.searchMoreEmailsAction();
          }
          return false;
        },
        child: PlatformInfo.isMobile
          ? ListView.separated(
              controller: controller.resultSearchScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              key: const PageStorageKey('list_presentation_email_in_search_view'),
              itemCount: listPresentationEmail.length,
              itemBuilder: (context, index) {
                final currentPresentationEmail = listPresentationEmail[index];
                return Obx(() => EmailTileBuilder(
                  presentationEmail: currentPresentationEmail,
                  selectAllMode: controller.selectionMode.value,
                  searchQuery: controller.searchQuery,
                  isShowingEmailContent: controller.mailboxDashBoardController.selectedEmail.value?.id == currentPresentationEmail.id,
                  isSearchEmailRunning: true,
                  padding: SearchEmailUtils.getPaddingSearchResultList(context, controller.responsiveUtils),
                  mailboxContain: currentPresentationEmail.mailboxContain,
                  emailActionClick: (action, email) {
                    controller.pressEmailAction(
                      context,
                      action,
                      email,
                      mailboxContain: currentPresentationEmail.mailboxContain
                    );
                  },
                  onMoreActionClick: (email, position) {
                    if (controller.responsiveUtils.isScreenWithShortestSide(context)) {
                      controller.openContextMenuAction(
                        context,
                        _contextMenuActionTile(context, email)
                      );
                    } else {
                      controller.openPopupMenuAction(
                        context,
                        position,
                        _popupMenuActionTile(context, email)
                      );
                    }
                  },
                ));
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index < listPresentationEmail.length - 1) {
                  return Padding(
                    padding: SearchEmailUtils.getPaddingItemListMobile(context, controller.responsiveUtils),
                    child: const Divider());
                } else {
                  return const SizedBox.shrink();
                }
              },
            )
          : ListView.separated(
            controller: controller.resultSearchScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            key: const PageStorageKey('list_presentation_email_in_search_view'),
            itemCount: listPresentationEmail.length,
            itemBuilder: (context, index) {
              final currentPresentationEmail = listPresentationEmail[index];
              return Obx(() => EmailTileBuilder(
                presentationEmail: currentPresentationEmail,
                selectAllMode: controller.selectionMode.value,
                searchQuery: controller.searchQuery,
                isShowingEmailContent: controller.mailboxDashBoardController.selectedEmail.value?.id == currentPresentationEmail.id,
                isSearchEmailRunning: true,
                padding: SearchEmailUtils.getPaddingSearchResultList(context, controller.responsiveUtils),
                mailboxContain: currentPresentationEmail.mailboxContain,
                emailActionClick: (action, email) {
                  controller.pressEmailAction(
                    context,
                    action,
                    email,
                    mailboxContain: currentPresentationEmail.mailboxContain
                  );
                },
                onMoreActionClick: (email, position) {
                  if (controller.responsiveUtils.isScreenWithShortestSide(context)) {
                    controller.openContextMenuAction(
                      context,
                      _contextMenuActionTile(context, email)
                    );
                  } else {
                    controller.openPopupMenuAction(
                      context,
                      position,
                      _popupMenuActionTile(context, email)
                    );
                  }
                },

              ));
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: ItemEmailTileStyles.getPaddingDividerWeb(context, controller.responsiveUtils),
                child: Divider(
                  color: index < listPresentationEmail.length - 1 &&
                    controller.selectionMode.value == SelectMode.INACTIVE
                    ? null
                    : Colors.white
                )
              );
            },
          )
    );
  }

  List<Widget> _contextMenuActionTile(BuildContext context, PresentationEmail email) {
    return <Widget>[
      _markAsEmailSpamOrUnSpamAction(context, email),
    ];
  }

  Widget _markAsEmailSpamOrUnSpamAction(BuildContext context, PresentationEmail email) {
    final mailboxContain = email.mailboxContain;

    return (EmailActionCupertinoActionSheetActionBuilder(
        const Key('mark_as_spam_or_un_spam_action'),
        SvgPicture.asset(
          mailboxContain?.isSpam == true ? controller.imagePaths.icNotSpam : controller.imagePaths.icSpam,
          width: 28,
          height: 28,
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
          mailboxContain?.isSpam == true
              ? EmailActionType.unSpam
              : EmailActionType.moveToSpam,
          email)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuActionTile(BuildContext context, PresentationEmail email) {
    return [
      PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _markAsEmailSpamOrUnSpamAction(context, email)),
    ];
  }

  Widget _buildLoadingViewLoadMore() {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) {
          return success is SearchingMoreState
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: loadingWidget)
              : const SizedBox.shrink();
        }));
  }

  Widget _buildSearchFilterByMailboxButton(BuildContext context) {
    return Obx(() {
      final filterSelected = controller.simpleSearchFilter.value.searchFilterByMailboxApplied;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () => controller.selectMailboxForSearchFilter(
              context,
              controller.simpleSearchFilter.value.mailbox),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filterSelected
                    ? AppColor.colorItemEmailSelectedDesktop
                    : AppColor.colorButtonHeaderThread),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filterSelected ? controller.imagePaths.icSelectedSB : controller.imagePaths.icFolderMailbox,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                  filterSelected
                    ? controller.simpleSearchFilter.value.getMailboxName(context)
                    : AppLocalizations.of(context).folder,
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  style: filterSelected
                    ? const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColor.colorTextButton)
                    : const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: AppColor.colorTextButtonHeaderThread)
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                    controller.imagePaths.icChevronDownOutline,
                    colorFilter: filterSelected
                      ? AppColor.primaryColor.asFilter()
                      : AppColor.colorDefaultRichTextButton.asFilter(),
                    fit: BoxFit.fill),
              ])
          ),
        ),
      );
    });
  }

  Widget _buildSearchFilterByContactButton(BuildContext context, PrefixEmailAddress prefixEmailAddress) {
    return Obx(() {
      final filterSelected = controller.simpleSearchFilter.value
          .searchFilterByContactApplied(prefixEmailAddress);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () => controller.selectContactForSearchFilter(context, prefixEmailAddress),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filterSelected
                      ? AppColor.colorItemEmailSelectedDesktop
                      : AppColor.colorButtonHeaderThread),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(
                    filterSelected ? controller.imagePaths.icSelectedSB : controller.imagePaths.icUserSB,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                const SizedBox(width: 4),
                Text(
                    filterSelected
                        ? controller.simpleSearchFilter.value.getNameContactApplied(context, prefixEmailAddress)
                        : controller.simpleSearchFilter.value.getNameContactDefault(context, prefixEmailAddress),
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: filterSelected
                        ? const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorTextButton)
                        : const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: AppColor.colorTextButtonHeaderThread)
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                    controller.imagePaths.icChevronDownOutline,
                    colorFilter: filterSelected
                      ? AppColor.primaryColor.asFilter()
                      : AppColor.colorDefaultRichTextButton.asFilter(),
                    fit: BoxFit.fill),
              ])
          ),
        ),
      );
    });
  }
}