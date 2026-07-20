import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mailbox_dashboard_view_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/quick_search_filter_button.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Filter bar shown on the search-result view of the dashboard.
/// Not used by the search suggestion view.
class QuickSearchFilterBar extends ConsumerWidget {
  final _controller = Get.find<MailboxDashBoardController>();

  final OnSelectQuickSearchFilterAction onSelectSearchFilterAction;
  final OnDeleteQuickSearchFilterAction onDeleteSearchFilterAction;

  QuickSearchFilterBar({
    super.key,
    required this.onSelectSearchFilterAction,
    required this.onDeleteSearchFilterAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchViewState = ref.watch(searchViewStateProvider);
    final searchFilter = ref.watch(searchFilterProvider);
    return Obx(() {
      final isThreadRoute =
          _controller.dashboardRoute.value == DashboardRoutes.thread;
      if (!searchViewState.isSearchEmailRunning || !isThreadRoute) {
        return const SizedBox.shrink();
      }
      return _buildActiveFilterBar(context, searchFilter);
    });
  }

  Widget _buildActiveFilterBar(
    BuildContext context,
    SearchEmailFilter searchFilter,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: _buildFilterList(context)),
          _buildTrailingButton(context, searchFilter),
        ],
      ),
    );
  }

  Widget _buildFilterList(BuildContext context) {
    final filters = _visibleFilters();
    return SizedBox(
      height: 45,
      child: ScrollbarListView(
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
          scrollbars: false,
        ),
        scrollController: _controller.listSearchFilterScrollController,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsetsDirectional.only(bottom: 10),
          controller: _controller.listSearchFilterScrollController,
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              if (i > 0) MailboxDashboardViewWebStyle.searchFilterSizeBoxMargin,
              _buildFilterButton(filters[i]),
            ],
          ],
        ),
      ),
    );
  }

  /// The chips shown while a thread search is active, in display order. `labels`
  /// only appears when the account has labels to filter by.
  List<QuickSearchFilter> _visibleFilters() {
    final showLabels = _controller.isLabelAvailable &&
        _controller.labelController.labels.isNotEmpty;
    return [
      QuickSearchFilter.folder,
      if (showLabels) QuickSearchFilter.labels,
      QuickSearchFilter.from,
      QuickSearchFilter.to,
      QuickSearchFilter.dateTime,
      QuickSearchFilter.hasAttachment,
      QuickSearchFilter.starred,
      QuickSearchFilter.unread,
      QuickSearchFilter.events,
    ];
  }

  Widget _buildFilterButton(QuickSearchFilter searchFilter) {
    return QuickSearchFilterButton(
      searchFilter: searchFilter,
      onSelectSearchFilterAction: onSelectSearchFilterAction,
      onDeleteSearchFilterAction: onDeleteSearchFilterAction,
    );
  }

  Widget _buildTrailingButton(
    BuildContext context,
    SearchEmailFilter searchFilter,
  ) {
    final hasFilterApplied = searchFilter.isApplied ||
        _controller.filterMessageOption.value != FilterMessageOption.all;

    return hasFilterApplied
        ? _trailingTextButton(
            text: AppLocalizations.of(context).clearFilter,
            onTap: _controller.clearAllSearchFilterApplied,
          )
        : _trailingTextButton(
            text: AppLocalizations.of(context).advancedSearch,
            onTap: _controller.openAdvancedSearchView,
          );
  }

  Widget _trailingTextButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return TMailButtonWidget.fromText(
      text: text,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsetsDirectional.only(start: 8),
      borderRadius: 10,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        color: AppColor.primaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      onTapActionCallback: onTap,
    );
  }
}
