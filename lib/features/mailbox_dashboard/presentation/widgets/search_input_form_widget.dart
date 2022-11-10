
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
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

    return PortalTarget(
      visible: controller.isAdvancedSearchViewOpen.isTrue,
      portalFollower: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.selectOpenAdvanceSearch()),
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
            textFieldConfiguration: QuickSearchTextFieldConfiguration(
                controller: controller.searchInputController,
                autofocus: controller.autoFocus.value,
                enabled: controller.isAdvancedSearchViewOpen.isFalse,
                focusNode: controller.searchFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (keyword) {
                  final query = keyword.trim();
                  if (query.isNotEmpty) {
                    controller.saveRecentSearch(RecentSearch.now(query));
                    dashBoardController.searchEmail(context, query);
                  } else {
                    dashBoardController.clearSearchEmail();
                  }
                },
                onChanged: controller.onChangeTextSearch,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: AppLocalizations.of(context).search_emails,
                    hintStyle: const TextStyle(
                        color: AppColor.colorHintSearchBar,
                        fontSize: 16.0),
                    labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0)
                ),
                leftButton: buildIconWeb(
                    icon: SvgPicture.asset(
                        imagePaths.icSearchBar,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill),
                    onTap: () {
                      final keyword = controller.searchInputController.text.trim();
                      if (keyword.isNotEmpty) {
                        controller.saveRecentSearch(RecentSearch.now(keyword));
                        dashBoardController.searchEmail(context, keyword);
                      } else {
                        dashBoardController.clearSearchEmail();
                      }
                    }),
                clearTextButton: buildIconWeb(
                    icon: SvgPicture.asset(
                        imagePaths.icClearTextSearch,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill),
                    onTap: controller.clearTextSearch),
                rightButton: IconOpenAdvancedSearchWidget(context)
            ),
            suggestionsBoxDecoration: QuickSearchSuggestionsBoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                constraints: BoxConstraints(maxWidth: maxWidth)),
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
                dashBoardController.selectQuickSearchFilter(
                  quickSearchFilter: filterAction,
                  fromSuggestionBox: true,
                );
              }
            },
            listActionPadding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: 6),
            titleHeaderRecent: Padding(
                padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    top: 12),
                child: Text(AppLocalizations.of(context).recent,
                    style: const TextStyle(
                        fontSize: 13.0,
                        color: AppColor.colorTextButtonHeaderThread,
                        fontWeight: FontWeight.w500)
                )
            ),
            buttonShowAllResult: (context, keyword) {
              if (keyword is String) {
                return InkWell(
                  onTap: () {
                    final query = keyword.trim();
                    if (query.isNotEmpty) {
                      controller.saveRecentSearch(RecentSearch.now(query));
                      dashBoardController.searchEmail(context, query);
                    } else {
                      dashBoardController.clearSearchEmail();
                    }
                    
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Text(AppLocalizations.of(context).showingResultsFor,
                            style: const TextStyle(
                                fontSize: 13.0,
                                color: AppColor.colorTextButtonHeaderThread,
                                fontWeight: FontWeight.w500)),
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
                child: loadingWidget),
            fetchRecentActionCallback: controller.getAllRecentSearchAction,
            itemRecentBuilder: (context, recent) =>
                RecentSearchItemTileWidget(recent),
            onRecentSelected: (recent) {
              controller.searchInputController.text = recent.value;
              dashBoardController.searchEmail(context, recent.value);
            },
            suggestionsCallback: (pattern) =>
                dashBoardController.quickSearchEmails(),
            itemBuilder: (context, email) =>
                EmailQuickSearchItemTileWidget(email, dashBoardController.selectedMailbox.value),
            onSuggestionSelected: (presentationEmail) =>
                dashBoardController.dispatchAction(
                    OpenEmailDetailedFromSuggestionQuickSearchAction(
                        context,
                        presentationEmail))),
      ),
    );
  }

  Widget buildListButtonForQuickSearchForm(BuildContext context, QuickSearchFilter filter) {
    final controller = dashBoardController.searchController;

    return Obx(() {
      final isFilterSelected = dashBoardController.checkQuickSearchFilterSelected(
          quickSearchFilter: filter);

      return Chip(
        labelPadding: const EdgeInsets.only(
            top: 2,
            bottom: 2,
            right: 10),
        label: Text(
          filter.getTitle(
              context,
              receiveTimeType: controller.emailReceiveTimeType.value),
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: filter.getTextStyle(
              quickSearchFilterSelected: isFilterSelected),
        ),
        avatar: SvgPicture.asset(
            filter.getIcon(
                imagePaths,
                quickSearchFilterSelected: isFilterSelected),
            width: 16,
            height: 16,
            fit: BoxFit.fill),
        labelStyle: filter.getTextStyle(
            quickSearchFilterSelected: isFilterSelected),
        backgroundColor: filter.getBackgroundColor(
            quickSearchFilterSelected: isFilterSelected),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: filter.getBackgroundColor(
                  quickSearchFilterSelected: isFilterSelected)),
        ),
      );
    });
  }
}