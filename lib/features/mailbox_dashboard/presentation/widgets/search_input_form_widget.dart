
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/quick_search/quick_search_input_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_overlay.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/icon_open_advanced_search_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/email_quick_search_item_tile_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/recent_search_item_tile_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SearchInputFormWidget extends StatelessWidget with AppLoaderMixin {
  final MailboxDashBoardController dashBoardController;
  final ImagePaths imagePaths;
  final double maxWidth;

  SearchInputFormWidget({
    Key? key,
    required this.dashBoardController,
    required this.imagePaths,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = dashBoardController.searchController;

    return Obx(() {
      return PortalTarget(
        visible: controller.isAdvancedSearchViewOpen.isTrue,
        portalFollower: PointerInterceptor(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.selectOpenAdvanceSearch()
          ),
        ),
        child: PortalTarget(
          visible: controller.isAdvancedSearchViewOpen.isTrue,
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
          portalFollower: AdvancedSearchFilterOverlay(maxWidth: maxWidth),
          child: QuickSearchInputForm<PresentationEmail, RecentSearch>(
            maxHeight: 52,
            suggestionsBoxVerticalOffset: 0.0,
            textFieldConfiguration: _createConfiguration(context),
            suggestionsBoxDecoration: QuickSearchSuggestionsBoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              constraints: BoxConstraints(maxWidth: maxWidth)
            ),
            debounceDuration: const Duration(milliseconds: 500),
            listActionButton: QuickSearchFilter.values,
            actionButtonBuilder: (context, filterAction) {
              if (filterAction is QuickSearchFilter) {
                return buildListButtonForQuickSearchForm(context, filterAction);
              } else {
                return const SizedBox.shrink();
              }
            },
            buttonActionCallback: (filterAction) {
              if (filterAction is QuickSearchFilter) {
                dashBoardController.addFilterToSuggestionForm(filterAction);
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
            buttonShowAllResult: (context, keyword) {
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
            fetchRecentActionCallback: controller.getAllRecentSearchAction,
            itemRecentBuilder: (context, recent) => RecentSearchItemTileWidget(recent),
            onRecentSelected: (recent) => _invokeSelectRecentItem(context, recent),
            suggestionsCallback: (pattern) => dashBoardController.quickSearchEmails(),
            itemBuilder: (context, email) => EmailQuickSearchItemTileWidget(email, dashBoardController.selectedMailbox.value),
            onSuggestionSelected: (presentationEmail) => _invokeSelectSuggestionItem(context, presentationEmail))
        ),
      );
    });
  }

  void _invokeSearchEmailAction(BuildContext context, String query) {
    dashBoardController.searchController.enableSearch();

    if (query.isNotEmpty) {
      dashBoardController.searchController.saveRecentSearch(RecentSearch.now(query));
      dashBoardController.searchEmail(context, query);
    } else {
      dashBoardController.clearSearchEmail();
    }
  }

  void _invokeSelectSuggestionItem(BuildContext context, PresentationEmail presentationEmail) {
    dashBoardController.dispatchAction(
      OpenEmailDetailedFromSuggestionQuickSearchAction(
        context,
        presentationEmail
      )
    );
  }

  void _invokeSelectRecentItem(BuildContext context, RecentSearch recent) {
    dashBoardController.searchController.enableSearch();
    dashBoardController.searchController.searchInputController.text = recent.value;
    dashBoardController.searchEmail(context, recent.value);
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
    final controller = dashBoardController.searchController;

    return QuickSearchTextFieldConfiguration(
      controller: controller.searchInputController,
      focusNode: controller.searchFocus,
      textInputAction: TextInputAction.done,
      onSubmitted: (keyword) => _invokeSearchEmailAction(context, keyword.trim()),
      onChanged: controller.onChangeTextSearch,
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
        padding: const EdgeInsets.only(left: 8),
        child: buildIconWeb(
          minSize: 40,
          iconPadding: EdgeInsets.zero,
          icon: SvgPicture.asset(imagePaths.icSearchBar, fit: BoxFit.fill),
          onTap: () => _invokeSearchEmailAction(context, controller.searchInputController.text.trim())
        )
      ),
      clearTextButton: buildIconWeb(
        icon: SvgPicture.asset(
          imagePaths.icClearTextSearch,
          width: 16,
          height: 16,
          fit: BoxFit.fill
        ),
        onTap: controller.clearTextSearch
      ),
      rightButton: IconOpenAdvancedSearchWidget(context)
    );
  }

  Widget buildListButtonForQuickSearchForm(BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      final isFilterSelected = filter.isApplied(dashBoardController.searchController.listFilterOnSuggestionForm);

      return Chip(
        labelPadding: const EdgeInsets.only(
          top: 2,
          bottom: 2,
          right: 10),
        label: Text(
          filter.getName(context),
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: filter.getTextStyle(isFilterSelected: isFilterSelected),
        ),
        avatar: SvgPicture.asset(
          filter.getIcon(imagePaths, isFilterSelected: isFilterSelected),
          width: 16,
          height: 16,
          fit: BoxFit.fill),
        labelStyle: filter.getTextStyle(isFilterSelected: isFilterSelected),
        backgroundColor: filter.getBackgroundColor(isFilterSelected: isFilterSelected),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: filter.getBackgroundColor(isFilterSelected: isFilterSelected)),
        ),
      );
    });
  }
}