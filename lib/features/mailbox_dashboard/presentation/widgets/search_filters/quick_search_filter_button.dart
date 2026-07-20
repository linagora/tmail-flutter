import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/mailbox_dashboard_view_web_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

typedef OnSelectQuickSearchFilterAction = void Function(
    BuildContext context, WidgetRef ref, QuickSearchFilter searchFilter,
    {RelativeRect? buttonPosition});
typedef OnDeleteQuickSearchFilterAction = void Function(
    WidgetRef ref, QuickSearchFilter searchFilter);

/// A single quick-search chip. Reads its state from the committed filter SSOT
/// and resolves its own DI singletons, so it stays independent of any dashboard
/// controller.
class QuickSearchFilterButton extends ConsumerWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final QuickSearchFilter searchFilter;
  final OnSelectQuickSearchFilterAction onSelectSearchFilterAction;
  final OnDeleteQuickSearchFilterAction onDeleteSearchFilterAction;

  /// Only consumed by the `fromMe` chip's selected-state check; omit otherwise.
  final String? currentUserEmail;

  QuickSearchFilterButton({
    super.key,
    required this.searchFilter,
    required this.onSelectSearchFilterAction,
    required this.onDeleteSearchFilterAction,
    this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final isSelected = searchFilter.isSelected(
      context,
      filter,
      filter.sortOrderType,
      currentUserEmail,
    );

    return SearchFilterButton(
      key: Key('${searchFilter.name}_search_filter_button'),
      searchFilter: searchFilter,
      imagePaths: _imagePaths,
      responsiveUtils: _responsiveUtils,
      isSelected: isSelected,
      receiveTimeType: filter.emailReceiveTimeType,
      startDate: filter.startDate?.value.toLocal(),
      endDate: filter.endDate?.value.toLocal(),
      sortOrderType: filter.sortOrderType,
      listAddressOfFrom: filter.from,
      listAddressOfTo: filter.to,
      mailbox: filter.mailbox,
      label: filter.label,
      buttonPadding: _buttonPadding(isSelected),
      backgroundColor: _backgroundColor(isSelected),
      isContextMenuAlignEndButton:
          searchFilter != QuickSearchFilter.labels && filter.hasActiveQuickFilter,
      onSelectSearchFilterAction: (context, searchFilter, {buttonPosition}) =>
          onSelectSearchFilterAction(
            context,
            ref,
            searchFilter,
            buttonPosition: buttonPosition,
          ),
      onDeleteSearchFilterAction: (searchFilter) =>
          onDeleteSearchFilterAction(ref, searchFilter),
    );
  }

  /// `sortBy` keeps the default padding; every other chip uses selection-aware padding.
  EdgeInsetsGeometry? _buttonPadding(bool isSelected) =>
      searchFilter == QuickSearchFilter.sortBy
          ? null
          : MailboxDashboardViewWebStyle.getSearchFilterButtonPadding(isSelected);

  /// Only `sortBy` overrides the background; other chips fall back to their own color.
  Color? _backgroundColor(bool isSelected) {
    if (searchFilter != QuickSearchFilter.sortBy) return null;
    return isSelected
        ? AppColor.primaryColor.withValues(alpha: 0.06)
        : AppColor.colorFilterMessageButton.withValues(alpha: 0.6);
  }
}
