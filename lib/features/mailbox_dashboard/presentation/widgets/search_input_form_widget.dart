
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/quick_search/quick_search_input_form.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/presentation_email.dart';
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
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SearchInputFormWidget extends StatelessWidget with AppLoaderMixin {
  final _searchController = Get.find<search.SearchController>();
  final _dashBoardController = Get.find<MailboxDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();

  SearchInputFormWidget({Key? key}) : super(key: key);

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
                style: const TextStyle(
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
            fetchRecentActionCallback: _searchController.getAllRecentSearchAction,
            itemRecentBuilder: (context, recent) => RecentSearchItemTileWidget(recent),
            onRecentSelected: (recent) => _invokeSelectRecentItem(context, recent),
            suggestionsCallback: _dashBoardController.quickSearchEmails,
            itemBuilder: (context, email) => EmailQuickSearchItemTileWidget(email, _dashBoardController.selectedMailbox.value),
            onSuggestionSelected: (presentationEmail) => _invokeSelectSuggestionItem(context, presentationEmail),
            contactItemBuilder: (context, emailAddress) => ContactQuickSearchItem(emailAddress: emailAddress),
            contactSuggestionsCallback: _dashBoardController.getContactSuggestion,
            onContactSuggestionSelected: (emailAddress) => _invokeSelectContactSuggestion(context, emailAddress),
          )
        ),
      );
    });
  }

  void _invokeSearchEmailAction(BuildContext context, String query) {
    _searchController.searchFocus.unfocus();
    _searchController.enableSearch();

    if (query.isNotEmpty) {
      _searchController.saveRecentSearch(RecentSearch.now(query));
    }

    if (query.isNotEmpty || _searchController.listFilterOnSuggestionForm.isNotEmpty) {
      _searchController.applyFilterSuggestionToSearchFilter(_dashBoardController.sessionCurrent?.username);
      _dashBoardController.searchEmail(context, queryString: query);
    } else {
      _dashBoardController.clearSearchEmail();
    }
  }

  void _invokeSelectSuggestionItem(BuildContext context, PresentationEmail presentationEmail) {
    _dashBoardController.dispatchAction(
      OpenEmailDetailedFromSuggestionQuickSearchAction(
        context,
        presentationEmail
      )
    );
  }

  void _invokeSelectRecentItem(BuildContext context, RecentSearch recent) {
    _searchController.searchInputController.text = recent.value;
    _searchController.searchFocus.unfocus();
    _searchController.enableSearch();

    _searchController.applyFilterSuggestionToSearchFilter(_dashBoardController.sessionCurrent?.username);
    _dashBoardController.searchEmail(context, queryString: recent.value);
  }

  Widget _buildShowAllResultButton(BuildContext context, String keyword) {
    return InkWell(
      onTap: () => _invokeSearchEmailAction(context, keyword.trim()),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Text(
            AppLocalizations.of(context).showingResultsFor,
            style: const TextStyle(
              fontSize: 13.0,
              color: AppColor.colorTextButtonHeaderThread,
              fontWeight: FontWeight.w500
            )
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(
            '"$keyword"',
            style: const TextStyle(
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
      textInputAction: TextInputAction.done,
      cursorColor: AppColor.primaryColor,
      textDirection: DirectionUtils.getDirectionByLanguage(context),
      onSubmitted: (keyword) => _invokeSearchEmailAction(context, keyword.trim()),
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: AppLocalizations.of(context).search_emails,
        hintStyle: const TextStyle(color: AppColor.colorHintSearchBar, fontSize: 16.0),
        labelStyle: const TextStyle(color: Colors.black, fontSize: 16.0)
      ),
      leftButton: Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: buildIconWeb(
          minSize: 40,
          iconPadding: EdgeInsets.zero,
          icon: SvgPicture.asset(_imagePaths.icSearchBar, fit: BoxFit.fill),
          onTap: () => _invokeSearchEmailAction(context, _searchController.searchInputController.text.trim())
        )
      ),
      clearTextButton: buildIconWeb(
        icon: SvgPicture.asset(
          _imagePaths.icClearTextSearch,
          width: 16,
          height: 16,
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
    SuggestionsListState suggestionsListState
  ) {
    return Obx(() {
      final isSelected = searchFilter.isApplied(_searchController.listFilterOnSuggestionForm);

      return SearchFilterButton(
        searchFilter: searchFilter,
        imagePaths: _imagePaths,
        isSelected: isSelected,
        backgroundColor: searchFilter.getSuggestionBackgroundColor(isFilterSelected: isSelected),
        onDeleteSearchFilterAction: (searchFilter) {
          _searchController.deleteQuickSearchFilterFromSuggestionSearchView(searchFilter);
          suggestionsListState.invalidateSuggestions();
        },
      );
    });
  }

  void _invokeSelectContactSuggestion(BuildContext context, EmailAddress emailAddress) {
    _searchController.searchInputController.clear();
    _searchController.searchFocus.unfocus();
    _searchController.enableSearch();
    _dashBoardController.searchEmailByFromFields(context, emailAddress);
  }
}