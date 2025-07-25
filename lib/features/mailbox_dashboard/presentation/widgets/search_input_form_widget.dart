
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/quick_search/quick_search_input_form.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_decoration.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_list.dart';
import 'package:core/presentation/views/quick_search/quick_search_text_field_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_overlay.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/icon_open_advanced_search_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/contact_quick_search_item.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SearchInputFormWidget extends StatelessWidget with AppLoaderMixin {
  final _searchController = Get.find<search.SearchController>();
  final _dashBoardController = Get.find<MailboxDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  SearchInputFormWidget({
    super.key,
    this.fontSize = 16,
    this.contentPadding = EdgeInsets.zero,
  });

  final double fontSize;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PortalTarget(
        visible: _searchController.isAdvancedSearchViewOpen.isTrue,
        portalFollower: PointerInterceptor(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _searchController.closeAdvanceSearch
          ),
        ),
        child: PortalTarget(
          visible: _searchController.isAdvancedSearchViewOpen.isTrue,
          anchor: const Aligned(
            follower: Alignment.topRight,
            target: Alignment.bottomRight,
            widthFactor: 1,
            backup: Aligned(
              follower: Alignment.topRight,
              target: Alignment.bottomRight,
              widthFactor: 1,
            ),
          ),
          portalFollower: const AdvancedSearchFilterOverlay(),
          child: QuickSearchInputForm<PresentationEmail, EmailAddress, RecentSearch>(
            maxHeight: 52,
            suggestionsBoxVerticalOffset: 0.0,
            minInputLengthAutocomplete: _dashBoardController.minInputLengthAutocomplete,
            textFieldConfiguration: _createConfiguration(context),
            suggestionsBoxDecoration: const QuickSearchSuggestionsBoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            debounceDuration: const Duration(milliseconds: 300),
            listActionButton: const [
              QuickSearchFilter.hasAttachment,
              QuickSearchFilter.last7Days,
              QuickSearchFilter.fromMe,
              QuickSearchFilter.starred,
            ],
            actionButtonBuilder: (context, filterAction, suggestionsListState) {
              if (filterAction is QuickSearchFilter) {
                return buildListButtonForQuickSearchForm(
                  context,
                  filterAction,
                  suggestionsListState);
              } else {
                return const SizedBox.shrink();
              }
            },
            buttonActionCallback: (filterAction) {
              if (filterAction is QuickSearchFilter) {
                _searchController.addQuickSearchFilterToSuggestionSearchView(filterAction);
              }
            },
            listActionPadding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
            titleHeaderRecent: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 12),
              child: Text(
                AppLocalizations.of(context).recent,
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 13.0,
                  color: AppColor.colorTextButtonHeaderThread,
                  fontWeight: FontWeight.w500
                )
              )
            ),
            buttonShowAllResult: (context, keyword, _) {
              if (keyword is String) {
                return _buildShowAllResultButton(context, keyword);
              } else {
                return const SizedBox.shrink();
              }
            },
            loadingBuilder: (context) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: loadingWidget
            ),
            fetchRecentActionCallback: (pattern) {
              final accountId = _dashBoardController.accountId.value;
              final userName = _dashBoardController.sessionCurrent?.username;

              if (accountId == null || userName == null) {
                logError('SearchInputFormWidget::fetchRecentActionCallback: accountId or userName is null');
                return <RecentSearch>[];
              } else {
                return _searchController.getAllRecentSearchAction(
                  accountId,
                  userName,
                  pattern,
                );
              }
            },
            itemRecentBuilder: (context, recent) => RecentSearchItemTileWidget(recent),
            onRecentSelected: _invokeSelectRecentItem,
            suggestionsCallback: _dashBoardController.quickSearchEmails,
            itemBuilder: (context, email) => EmailQuickSearchItemTileWidget(
              email,
              _dashBoardController.selectedMailbox.value,
              searchQuery: SearchQuery(_searchController.currentSearchText.trim())),
            onSuggestionSelected: _invokeSelectSuggestionItem,
            contactItemBuilder: (context, emailAddress) => ContactQuickSearchItem(emailAddress: emailAddress),
            contactSuggestionsCallback: _dashBoardController.getContactSuggestion,
            onContactSuggestionSelected: _invokeSelectContactSuggestion,
          )
        ),
      );
    });
  }

  void _invokeSearchEmailAction(String queryString) {
    log('SearchInputFormWidget::_invokeSearchEmailAction:QueryString = $queryString');
    _searchController.searchFocus.unfocus();
    _searchController.enableSearch();

    if (queryString.isNotEmpty) {
      _saveRecentSearch(queryString);
    }

    if (queryString.isNotEmpty || _searchController.listFilterOnSuggestionForm.isNotEmpty) {
      _searchController.clearSearchFilter();
      _searchController.applyFilterSuggestionToSearchFilter(
        _dashBoardController.sessionCurrent?.getOwnEmailAddressOrEmpty(),
      );
      _dashBoardController.searchEmailByQueryString(queryString);
    } else {
      _dashBoardController.clearSearchEmail();
    }
  }

  void _saveRecentSearch(String queryString) {
    final accountId = _dashBoardController.accountId.value;
    final userName = _dashBoardController.sessionCurrent?.username;

    if (accountId == null || userName == null) {
      logError('SearchInputFormWidget::_saveRecentSearch: accountId or userName is null');
      return;
    }

    _searchController.saveRecentSearch(
      accountId,
      userName,
      RecentSearch.now(queryString),
    );
  }

  void _invokeSelectSuggestionItem(PresentationEmail presentationEmail) {
    _dashBoardController.dispatchAction(
      OpenEmailDetailedFromSuggestionQuickSearchAction(
        presentationEmail
      )
    );
  }

  void _invokeSelectRecentItem(RecentSearch recent) {
    _searchController.searchInputController.text = recent.value;
    _searchController.searchFocus.unfocus();
    _searchController.enableSearch();
    _searchController.clearSearchFilter();
    _searchController.applyFilterSuggestionToSearchFilter(
      _dashBoardController.sessionCurrent?.getOwnEmailAddressOrEmpty(),
    );
    _dashBoardController.searchEmailByQueryString(recent.value);
  }

  Widget _buildShowAllResultButton(BuildContext context, String keyword) {
    return InkWell(
      onTap: () => _invokeSearchEmailAction(keyword.trim()),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Text(
            AppLocalizations.of(context).showingResultsFor,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: 13.0,
              color: AppColor.colorTextButtonHeaderThread,
              fontWeight: FontWeight.w500
            )
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(
            '"$keyword"',
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: 13.0,
              color: Colors.black,
              fontWeight: FontWeight.w500
            )
          ))
        ])
      ),
    );
  }

  QuickSearchTextFieldConfiguration _createConfiguration(BuildContext context) {
    return QuickSearchTextFieldConfiguration(
      controller: _searchController.searchInputController,
      focusNode: _searchController.searchFocus,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
      ),
      textInputAction: TextInputAction.done,
      cursorColor: AppColor.primaryColor,
      textDirection: DirectionUtils.getDirectionByLanguage(context),
      onSubmitted: (keyword) => _invokeSearchEmailAction(keyword.trim()),
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: contentPadding,
        hintText: AppLocalizations.of(context).search_emails,
        hintStyle: ThemeUtils.textStyleBodyBody2(
          color: AppColor.steelGray400,
        ),
        labelStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(color: Colors.black, fontSize: 16.0)
      ),
      leftButton: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        child: TMailButtonWidget.fromIcon(
          icon: _imagePaths.icSearchBar,
          iconColor: AppColor.steelGray400,
          iconSize: 22,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          onTapActionCallback: () => _invokeSearchEmailAction(_searchController.searchInputController.text.trim())
        )
      ),
      clearTextButton: buildIconWeb(
        icon: SvgPicture.asset(
          _imagePaths.icClearTextSearch,
          width: 16,
          height: 16,
          colorFilter: AppColor.steelGray400.asFilter(),
          fit: BoxFit.fill
        ),
        onTap: _searchController.clearTextSearch
      ),
      rightButton: IconOpenAdvancedSearchWidget()
    );
  }

  Widget buildListButtonForQuickSearchForm(
    BuildContext context,
    QuickSearchFilter searchFilter,
    QuickSearchSuggestionListState suggestionsListState
  ) {
    return Obx(() {
      final isSelected = searchFilter.isApplied(_searchController.listFilterOnSuggestionForm);

      return SearchFilterButton(
        searchFilter: searchFilter,
        imagePaths: _imagePaths,
        responsiveUtils: _responsiveUtils,
        isSelected: isSelected,
        backgroundColor: searchFilter.getSuggestionBackgroundColor(isSelected: isSelected),
        onDeleteSearchFilterAction: (searchFilter) {
          _searchController.deleteQuickSearchFilterFromSuggestionSearchView(searchFilter);
          suggestionsListState.invalidateSuggestions();
        },
      );
    });
  }

  void _invokeSelectContactSuggestion(EmailAddress emailAddress) {
    _searchController.searchInputController.clear();
    _searchController.searchFocus.unfocus();
    _searchController.enableSearch();
    _dashBoardController.quickSearchEmailByFrom(emailAddress);
  }
}