import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/context_item_receive_time_type_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/context_item_sort_order_type_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_date_filter_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/popup_menu_item_sort_order_type_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef _PopupActionBuilder<T> = PopupMenuItemAction<T> Function(T action);
typedef _ContextActionBuilder<T> = ContextMenuItemAction<T> Function(T action);
typedef _MenuActionCallback<T> = void Function(
  WidgetRef ref,
  BuildContext context,
  T action,
);

class SearchFilterSelectionActionDelegate {
  final SearchEmailController controller;

  const SearchFilterSelectionActionDelegate({
    required this.controller,
  });

  void onSelectSearchFilterAction(
    SearchFilterSelectionActionRequest request,
  ) {
    switch (request.searchFilter) {
      case QuickSearchFilter.dateTime:
        _selectDateTimeSearchFilter(request);
        break;
      case QuickSearchFilter.sortBy:
        _selectSortBySearchFilter(request);
        break;
      case QuickSearchFilter.from:
        _selectContactSearchFilter(request, PrefixEmailAddress.from);
        break;
      case QuickSearchFilter.hasAttachment:
        controller.selectHasAttachmentSearchFilter(request.ref);
        break;
      case QuickSearchFilter.to:
        _selectContactSearchFilter(request, PrefixEmailAddress.to);
        break;
      case QuickSearchFilter.folder:
        controller.selectMailboxForSearchFilter(
          request.ref,
          request.searchEmailFilter.mailbox,
        );
        break;
      case QuickSearchFilter.starred:
        controller.selectKeywordsSearchFilter(
          request.ref,
          KeyWordIdentifier.emailFlagged,
        );
        break;
      case QuickSearchFilter.unread:
        controller.selectUnreadSearchFilter(request.ref);
        break;
      case QuickSearchFilter.events:
        controller.selectNotIncludeEventsSearchFilter(request.ref);
        break;
      case QuickSearchFilter.labels:
        _selectLabelsSearchFilter(request);
        break;
      case QuickSearchFilter.last7Days:
      case QuickSearchFilter.fromMe:
        break;
    }
  }

  @visibleForTesting
  bool handlesSearchFilter(QuickSearchFilter searchFilter) =>
      _handledSearchFilters.contains(searchFilter);

  static const Set<QuickSearchFilter> _handledSearchFilters = {
    QuickSearchFilter.dateTime,
    QuickSearchFilter.sortBy,
    QuickSearchFilter.from,
    QuickSearchFilter.hasAttachment,
    QuickSearchFilter.to,
    QuickSearchFilter.folder,
    QuickSearchFilter.starred,
    QuickSearchFilter.unread,
    QuickSearchFilter.events,
    QuickSearchFilter.labels,
    QuickSearchFilter.last7Days,
    QuickSearchFilter.fromMe,
  };

  void _selectDateTimeSearchFilter(
    SearchFilterSelectionActionRequest request,
  ) {
    final appLocalizations = AppLocalizations.of(request.context);
    final selectedReceiveTime = request.searchEmailFilter.emailReceiveTimeType;

    _selectMenuFilter<EmailReceiveTimeType>(
      request: request,
      values: EmailReceiveTimeType.valuesForSearch,
      bottomSheetKey: const Key('date_time_filter_context_menu'),
      popupActionBuilder: (timeType) => PopupMenuItemDateFilterAction(
        timeType,
        selectedReceiveTime,
        appLocalizations,
        controller.imagePaths,
      ),
      contextActionBuilder: (timeType) => ContextItemReceiveTimeTypeAction(
        timeType,
        selectedReceiveTime,
        appLocalizations,
        controller.imagePaths,
      ),
      onSelected: controller.selectReceiveTimeQuickSearchFilter,
    );
  }

  void _selectSortBySearchFilter(
    SearchFilterSelectionActionRequest request,
  ) {
    final appLocalizations = AppLocalizations.of(request.context);
    final selectedSortOrder = request.searchEmailFilter.sortOrderType;

    _selectMenuFilter<EmailSortOrderType>(
      request: request,
      values: EmailSortOrderType.values,
      bottomSheetKey: const Key('sort_filter_context_menu'),
      popupActionBuilder: (sortType) => PopupMenuItemSortOrderTypeAction(
        sortType,
        selectedSortOrder,
        appLocalizations,
        controller.imagePaths,
      ),
      contextActionBuilder: (sortType) => ContextItemSortOrderTypeAction(
        sortType,
        selectedSortOrder,
        appLocalizations,
        controller.imagePaths,
      ),
      onSelected: (ref, context, action) =>
          controller.selectSortOrderQuickSearchFilter(ref, action),
    );
  }

  void _selectContactSearchFilter(
    SearchFilterSelectionActionRequest request,
    PrefixEmailAddress prefixEmailAddress,
  ) {
    controller.selectContactForSearchFilter(
      request.ref,
      request.context,
      prefixEmailAddress,
    );
  }

  void _selectLabelsSearchFilter(
    SearchFilterSelectionActionRequest request,
  ) {
    final listLabels = controller.mailboxDashBoardController.labelController.labels;
    final selectedLabel = request.searchEmailFilter.label;

    controller.openLabelsFilterModal(
      context: request.context,
      position: request.buttonPosition,
      labels: listLabels,
      selectedLabel: selectedLabel,
      imagePaths: controller.imagePaths,
      onSelectLabelsActions: (newLabel) =>
        controller.onSelectLabelFilter(request.ref, newLabel),
    );
  }

  void _selectMenuFilter<T>({
    required SearchFilterSelectionActionRequest request,
    required Iterable<T> values,
    required Key bottomSheetKey,
    required _PopupActionBuilder<T> popupActionBuilder,
    required _ContextActionBuilder<T> contextActionBuilder,
    required _MenuActionCallback<T> onSelected,
  }) {
    final buttonPosition = request.buttonPosition;
    if (buttonPosition != null) {
      _openPopupMenuFilter(
        ref: request.ref,
        context: request.context,
        position: buttonPosition,
        values: values,
        popupActionBuilder: popupActionBuilder,
        onSelected: onSelected,
      );
      return;
    }

    final contextMenuActions = values.map(contextActionBuilder).toList();
    controller.openBottomSheetContextMenuAction(
      key: bottomSheetKey,
      context: request.context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) {
        popBack();
        onSelected(
          request.ref,
          request.context,
          (menuAction as ContextMenuItemAction<T>).action,
        );
      },
    );
  }

  void _openPopupMenuFilter<T>({
    required WidgetRef ref,
    required BuildContext context,
    required RelativeRect position,
    required Iterable<T> values,
    required _PopupActionBuilder<T> popupActionBuilder,
    required _MenuActionCallback<T> onSelected,
  }) {
    final popupMenuItems = values.map((action) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: popupActionBuilder(action),
          menuActionClick: (_) {
            popBack();
            onSelected(ref, context, action);
          },
        ),
      );
    }).toList();

    controller.openPopupMenuAction(context, position, popupMenuItems);
  }
}

class SearchFilterSelectionActionRequest {
  final WidgetRef ref;
  final BuildContext context;
  final QuickSearchFilter searchFilter;
  final SearchEmailFilter searchEmailFilter;
  final RelativeRect? buttonPosition;

  const SearchFilterSelectionActionRequest({
    required this.ref,
    required this.context,
    required this.searchFilter,
    required this.searchEmailFilter,
    this.buttonPosition,
  });
}
