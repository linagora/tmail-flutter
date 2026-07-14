
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/keyboard/keyboard_handler_wrapper.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_ai_needs_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/contact_quick_search_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/search/email/presentation/delegates/search_filter_selection_action_delegate.dart';
import 'package:tmail_ui_user/features/search/email/presentation/extension/handle_email_more_action_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/extension/handle_keyboard_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/extension/handle_press_email_selection_action.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/riverpod_widgets/clear_search_filter_button.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/state/search_email_presentation_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/styles/search_email_view_style.dart';
import 'package:tmail_ui_user/features/search/email/presentation/utils/search_email_utils.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/empty_search_email_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/search_email_load_more_indicator.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/search_email_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/selection_mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SearchEmailView extends ConsumerWidget {

  const SearchEmailView({super.key});

  SearchEmailController get controller => Get.find<SearchEmailController>();

  SearchFilterSelectionActionDelegate get _searchFilterSelectionActionDelegate =>
      SearchFilterSelectionActionDelegate(controller: controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Skip after the search binding is disposed.
    if (!Get.isRegistered<SearchEmailController>()) {
      return const SizedBox.shrink();
    }

    final presentationState = ref.watch(searchEmailPresentationProvider);
    final searchQuery = ref.watch(
      searchFilterProvider.select((filter) => filter.text),
    );

    _dismissSearchOnWebDesktop(context);

    return _buildScaffold(
      context,
      _buildBody(ref, context, presentationState, searchQuery),
    );
  }

  /// Close mobile search on web desktop rebuilds.
  void _dismissSearchOnWebDesktop(BuildContext context) {
    if (!controller.responsiveUtils.isWebDesktop(context)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted ||
          !Get.isRegistered<SearchEmailController>()) {
        return;
      }
      Get.find<SearchEmailController>().closeSearchView(context: context);
    });
  }

  Widget _buildBody(
    WidgetRef ref,
    BuildContext context,
    SearchEmailPresentationState presentationState,
    SearchQuery? searchQuery,
  ) {
    return Column(children: [
      _buildSearchAppBar(ref, context, presentationState),
      const Divider(color: AppColor.colorDividerComposer, height: 1),
      _buildListSearchFilterAction(context),
      SearchEmailLoadingBarWidget(
        suggestionViewState: presentationState.suggestionSearchViewState,
        resultSearchViewState: presentationState.resultSearchViewState,
      ),
      Expanded(
        child: presentationState.searchIsRunning
            ? _buildSearchResultBody(context, presentationState, searchQuery)
            : _buildSuggestionAndRecentView(ref, context, presentationState),
      ),
      const SearchEmailLoadMoreIndicator(),
    ]);
  }

  Widget _buildSearchAppBar(
    WidgetRef ref,
    BuildContext context,
    SearchEmailPresentationState presentationState,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (!PlatformInfo.isAndroid) return;
        controller.closeSearchView(context: context);
      },
      child: Container(
        height: 52,
        color: Colors.white,
        padding: SearchEmailViewStyle.getAppBarPadding(
          context,
          controller.responsiveUtils,
        ),
        child: _buildSearchAppBarContent(ref, context, presentationState),
      ),
    );
  }

  Widget _buildSuggestionAndRecentView(
    WidgetRef ref,
    BuildContext context,
    SearchEmailPresentationState presentationState,
  ) {
    final hasText = presentationState.currentSearchText.isNotEmpty;
    final hasContactSuggestion =
        presentationState.listContactSuggestionSearch.isNotEmpty;
    final hasSuggestion = presentationState.listSuggestionSearch.isNotEmpty;
    final hasRecent = presentationState.listRecentSearch.isNotEmpty;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(children: [
        if (hasText)
          _buildShowAllResultSearchButton(
            ref,
            context,
            presentationState.currentSearchText,
          ),
        if (hasContactSuggestion && hasText)
          _buildListContactSuggestionSearch(
            ref,
            context,
            presentationState.listContactSuggestionSearch,
          ),
        if (hasContactSuggestion && hasSuggestion) const Divider(),
        if (hasSuggestion && hasText)
          _buildListSuggestionSearch(
            context,
            presentationState.listSuggestionSearch,
            presentationState.currentSearchText,
          )
        else if (hasRecent && !hasSuggestion)
          _buildListRecentSearch(
            ref,
            context,
            presentationState.listRecentSearch,
          ),
      ]),
    );
  }

  Widget _buildScaffold(BuildContext context, Widget bodyWidget) {
    if (PlatformInfo.isWeb && controller.keyboardFocusNode != null) {
      return KeyboardHandlerWrapper(
        onKeyDownEventAction: controller.onKeyDownEventAction,
        focusNode: controller.keyboardFocusNode!,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: bodyWidget,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: controller.textInputSearchFocus.unfocus,
        child: bodyWidget,
      ),
    );
  }

  Widget _buildSearchAppBarContent(
    WidgetRef ref,
    BuildContext context,
    SearchEmailPresentationState presentationState,
  ) {
    if (presentationState.selectionMode != SelectMode.ACTIVE) {
      return _buildSearchInputForm(
        ref,
        context,
        presentationState.currentSearchText,
      );
    }

    final mapMailboxById = controller.mailboxDashBoardController.mapMailboxById;
    final selectedEmails = presentationState.listResultSearch.listEmailSelected;
    final isLabelAvailable =
        controller.mailboxDashBoardController.isLabelAvailable;

    final actionTypes = _createEmailSelectionActionTypes(
      mapMailboxById,
      selectedEmails,
    );

    return SelectionMobileAppBarThreadWidget(
      imagePaths: controller.imagePaths,
      responsiveUtils: controller.responsiveUtils,
      selectedEmails: selectedEmails,
      padding: EdgeInsets.zero,
      onCancelSelectionAction: controller.cancelSelectionMode,
      emailSelectionActionTypes: actionTypes,
      onPressEmailSelectionActionClick: (type, emails) =>
          controller.handlePressEmailSelectionAction(
            context,
            type,
            emails,
            mapMailboxById,
            isLabelAvailable,
          ),
    );
  }

  Widget _buildSearchResultBody(
    BuildContext context,
    SearchEmailPresentationState presentationState,
    SearchQuery? searchQuery,
  ) {
    if (presentationState.listResultSearch.isEmpty) {
      return EmptySearchEmailWidget(
        suggestionViewState: presentationState.suggestionSearchViewState,
        resultSearchViewState: presentationState.resultSearchViewState,
        isNetworkConnectionAvailable:
            controller.networkConnectionController.isNetworkConnectionAvailable(),
      );
    }

    return _buildListEmailBody(
      context,
      presentationState.listResultSearch,
      presentationState.selectionMode,
      presentationState.searchMoreState,
      searchQuery,
    );
  }

  List<EmailSelectionActionType> _createEmailSelectionActionTypes(
    Map<MailboxId, PresentationMailbox> mapMailboxById,
    List<PresentationEmail> selectedEmails,
  ) {
    return <EmailSelectionActionType>[
      EmailSelectionActionType.selectAll,
      if (selectedEmails.isArchiveMessageEnabled(mapMailboxById))
        EmailSelectionActionType.archiveMessage,
      if (selectedEmails.isDeletePermanentlyDisabled(mapMailboxById))
        EmailSelectionActionType.moveToTrash
      else
        EmailSelectionActionType.deletePermanently,
      if (selectedEmails.isAllEmailRead)
        EmailSelectionActionType.markAsUnread
      else
        EmailSelectionActionType.markAsRead,
      EmailSelectionActionType.moreAction,
    ];
  }

  Widget _buildSearchInputForm(
    WidgetRef ref,
    BuildContext context,
    String currentSearchText,
  ) {
    return Row(
        children: [
          buildIconWeb(
              icon: SvgPicture.asset(
                key: const ValueKey('search_email_back_button'),
                DirectionUtils.isDirectionRTLByLanguage(context) ? controller.imagePaths.icCollapseFolder : controller.imagePaths.icBack,
                colorFilter: AppColor.colorTextButton.asFilter(),
                fit: BoxFit.fill
              ),
              tooltip: AppLocalizations.of(context).back,
              onTap: () => controller.closeSearchView(context: context)
          ),
          Expanded(child: TextFieldBuilder(
            key: const Key('search_email_text_field'),
            onTap: controller.onSearchFieldTap,
            onTextChange: controller.onTextSearchChange,
            textInputAction: TextInputAction.search,
            controller: controller.textInputSearchController,
            focusNode: controller.textInputSearchFocus,
            maxLines: 1,
            textDirection: DirectionUtils.getDirectionByLanguage(context),
            textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
            keyboardType: TextInputType.text,
            onTextSubmitted: (text) => controller.onTextSearchSubmitted(ref, context, text),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              hintText: AppLocalizations.of(context).search_emails,
              hintStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                color: AppColor.loginTextFieldHintColor,
                fontSize: 16,
              ),
              border: InputBorder.none),
          )),
          if (currentSearchText.isNotEmpty)
            buildIconWeb(
                icon: SvgPicture.asset(
                    controller.imagePaths.icClearTextSearch,
                    width: 18,
                    height: 18,
                    fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).clearAll,
                onTap: () => controller.clearAllTextInputSearchForm(requestFocus: true))
        ]
    );
  }

  Widget _buildListSearchFilterAction(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            height: 45,
            margin: SearchEmailViewStyle.listSearchFilterButtonMargin,
            alignment: AlignmentDirectional.centerStart,
            child: ScrollbarListView(
              scrollBehavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad
                },
                scrollbars: false
              ),
              scrollController: controller.listSearchFilterScrollController,
              child: Obx(() {
                final isLabelAvailable =
                    controller.mailboxDashBoardController.isLabelAvailable;
                final labelList = controller
                    .mailboxDashBoardController.labelController.labels;

                return ListView(
                  key: const Key(UiKeys.searchFilterListView),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  controller: controller.listSearchFilterScrollController,
                  padding: SearchEmailViewStyle.getListSearchFilterButtonPadding(
                      context,
                      controller.responsiveUtils
                  ),
                  children: [
                    _buildSearchFilterButton(context, QuickSearchFilter.folder),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    if (isLabelAvailable && labelList.isNotEmpty)
                     ...[
                       _buildSearchFilterButton(context, QuickSearchFilter.labels),
                       SearchEmailViewStyle.searchFilterSizeBoxMargin,
                     ],
                    _buildSearchFilterButton(context, QuickSearchFilter.from),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.to),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.hasAttachment),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.dateTime),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.starred),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.unread),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.events),
                    SearchEmailViewStyle.searchFilterSizeBoxMargin,
                    _buildSearchFilterButton(context, QuickSearchFilter.sortBy),
                  ],
                );
              }),
            ),
          ),
        ),
        ClearSearchFilterButton(
          onClearFilter: controller.clearAllSearchFilterApplied,
        )
      ],
    );
  }

  Widget _buildSearchFilterButton(
    BuildContext context,
    QuickSearchFilter searchFilter,
  ) {
    return Consumer(builder: (context, ref, _) {
      final searchEmailFilter = ref.watch(searchFilterProvider);
      final sortOrderType = searchEmailFilter.sortOrderType;
      final currentUserEmail = controller.ownEmailAddress;

      final isSelected = searchFilter.isSelected(
        context,
        searchEmailFilter,
        sortOrderType,
        currentUserEmail);

      return SearchFilterButton(
        key: Key('mobile_${searchFilter.name}_search_filter_button'),
        searchFilter: searchFilter,
        imagePaths: controller.imagePaths,
        responsiveUtils: controller.responsiveUtils,
        isSelected: isSelected,
        receiveTimeType: searchEmailFilter.emailReceiveTimeType,
        startDate: searchEmailFilter.startDate?.value.toLocal(),
        endDate: searchEmailFilter.endDate?.value.toLocal(),
        sortOrderType: sortOrderType,
        listAddressOfFrom: searchEmailFilter.from,
        listAddressOfTo: searchEmailFilter.to,
        mailbox: searchEmailFilter.mailbox,
        label: searchEmailFilter.label,
        backgroundColor: searchFilter.getMobileBackgroundColor(isSelected: isSelected),
        onSelectSearchFilterAction: (context, quickSearchFilter, {buttonPosition}) =>
          _searchFilterSelectionActionDelegate.onSelectSearchFilterAction(
            SearchFilterSelectionActionRequest(
              ref: ref,
              context: context,
              searchFilter: quickSearchFilter,
              searchEmailFilter: searchEmailFilter,
              buttonPosition: buttonPosition,
            ),
          ),
        onDeleteSearchFilterAction: (searchFilter) =>
          controller.onDeleteSearchFilterAction(ref, searchFilter),
      );
    });
  }

  Widget _buildShowAllResultSearchButton(
    WidgetRef ref,
    BuildContext context,
    String textSearch,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final query = textSearch.trim();
          if (query.isNotEmpty) {
            controller.saveRecentSearch(query);
            controller.showAllResultSearchAction(ref, context, query);
          }
        },
        child: Padding(
          padding: SearchEmailViewStyle.getShowAllResultButtonPadding(
            context,
            controller.responsiveUtils
          ),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).showingResultsFor,
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 13.0,
                  color: AppColor.colorTextButtonHeaderThread,
                  fontWeight: FontWeight.w500
                )
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '"$textSearch"',
                  style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontSize: 13.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                  )
                )
              )
            ]
          )
        ),
      ),
    );
  }

  Widget _buildListRecentSearch(
      WidgetRef ref,
      BuildContext context,
      List<RecentSearch> listRecentSearch
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: SearchEmailViewStyle.getSearchRecentTitleMargin(
            context,
            controller.responsiveUtils
          ),
          child: Text(
            AppLocalizations.of(context).recent,
            style: SearchEmailViewStyle.searchRecentTitleStyle
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
                  contentPadding: SearchEmailViewStyle.getListRecentSearchPadding(
                    context,
                    controller.responsiveUtils
                  )
                ),
                onTap: () => controller.searchEmailByRecentAction(
                  ref,
                  context,
                  recentSearch
                ),
              ),
            );
          }
        )
      ]
    );
  }

  Widget _buildListSuggestionSearch(
      BuildContext context,
      List<PresentationEmail> listSuggestionSearch,
      String currentSearchText,
  ) {
    return ListView.builder(
        key: const Key('suggestion_search_list_view'),
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
                searchQuery: SearchQuery(currentSearchText.trim()),
                contentPadding: SearchEmailViewStyle.getSearchSuggestionListPadding(
                  context,
                  controller.responsiveUtils
                )
              ),
              onTap: () {
                final emailPreview = listSuggestionSearch[index];
                final mailboxContain = emailPreview
                    .findMailboxContain(controller.mailboxDashBoardController.mapMailboxById);
                controller.pressEmailAction(
                    EmailActionType.preview,
                    emailPreview,
                    mailboxContain,
                );
              },
            ),
          );
        });
  }

  Widget _buildListContactSuggestionSearch(
    WidgetRef ref,
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
              ref,
              emailAddress
            ),
          ),
        );
      }
    );
  }

  Widget _buildListEmailBody(
    BuildContext context,
    List<PresentationEmail> listPresentationEmail,
    SelectMode selectionMode,
    SearchMoreState searchMoreState,
    SearchQuery? searchQuery,
  ) {
    return NotificationListener<ScrollNotification>(
        key: const Key('search_email_list_notification_listener'),
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification
              && searchMoreState != SearchMoreState.waiting
              && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent
              && scrollInfo.metrics.axisDirection == AxisDirection.down) {
            controller.searchMoreEmailsAction();
          }
          return false;
        },
        child: ListView.separated(
          controller: controller.resultSearchScrollController,
          physics: PlatformInfo.isIOS
              ? const ClampingScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          key: const PageStorageKey('list_presentation_email_in_search_view'),
          itemCount: listPresentationEmail.length,
          itemBuilder: (context, index) => _buildEmailItem(
            context,
            listPresentationEmail[index],
            selectionMode,
            searchQuery,
          ),
          separatorBuilder: (context, index) {
            final isMobile = PlatformInfo.isMobile;
            final isLastItem = index == listPresentationEmail.length - 1;
            final isInactive = selectionMode == SelectMode.INACTIVE;

            final showDivider = !isLastItem;

            final dividerColor = isMobile
                ? null
                : (showDivider && isInactive ? null : Colors.white);

            final padding = isMobile
                ? SearchEmailUtils.getPaddingItemListMobile(
                    context,
                    controller.responsiveUtils,
                  )
                : ItemEmailTileStyles.getPaddingDividerWeb(
                    context,
                    controller.responsiveUtils,
                  );

            if (!showDivider) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: padding,
              child: Divider(color: dividerColor),
            );
          },
        )
    );
  }

  Widget _buildEmailItem(
    BuildContext context,
    PresentationEmail presentationEmail,
    SelectMode selectionMode,
    SearchQuery? searchQuery,
  ) {
    final dashboardController = controller.mailboxDashBoardController;

    return Obx(
      () {
        final isShowingEmailContent =
            dashboardController.selectedEmail.value?.id == presentationEmail.id;

        final isSenderImportantFlagEnabled =
            dashboardController.isSenderImportantFlagEnabled.value;

        final isAINeedsActionEnabled = dashboardController.isAINeedsActionEnabled;

        final isLabelAvailable = dashboardController.isLabelAvailable;

        final listLabels = dashboardController.labelController.labels;

        final isLabelMailboxOpened =
            dashboardController.selectedMailbox.value?.isLabelMailbox == true;

        List<Label>? emailLabels;

        if (isLabelAvailable) {
          emailLabels = presentationEmail.getLabelList(listLabels);
        }

        return EmailTileBuilder(
          presentationEmail: presentationEmail,
          selectAllMode: selectionMode,
          searchQuery: searchQuery,
          isShowingEmailContent: isShowingEmailContent,
          isSenderImportantFlagEnabled: isSenderImportantFlagEnabled,
          isSearchEmailRunning: true,
          isLabelMailboxOpened: isLabelMailboxOpened,
          isAINeedsActionEnabled: isAINeedsActionEnabled,
          labels: emailLabels,
          padding: SearchEmailViewStyle.getPaddingSearchResultList(
            context,
            controller.responsiveUtils,
          ),
          mailboxContain: presentationEmail.mailboxContain,
          emailActionClick: (action, email) {
            controller.pressEmailAction(
              action,
              email,
              presentationEmail.mailboxContain,
            );
          },
          onMoreActionClick: (email, position) =>
              controller.handleEmailMoreAction(
            context,
            email,
            position,
            isLabelAvailable,
            listLabels,
          ),
        );
      },
    );
  }
}
