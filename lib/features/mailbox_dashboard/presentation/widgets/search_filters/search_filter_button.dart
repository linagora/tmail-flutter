
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/search_filter_button_style.dart';

typedef OnSelectSearchFilterAction = Function(
  BuildContext context,
  QuickSearchFilter searchFilter,
  {RelativeRect? buttonPosition});
typedef OnDeleteSearchFilterAction = Function(QuickSearchFilter searchFilter);

class SearchFilterButton extends StatelessWidget {

  static const int _titleCharactersMaximum = 20;

  final QuickSearchFilter searchFilter;
  final bool isSelected;
  final ImagePaths imagePaths;
  final EmailReceiveTimeType? receiveTimeType;
  final EmailSortOrderType? sortOrderType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String>? listAddressOfFrom;
  final Set<String>? listAddressOfTo;
  final UserName? userName;
  final PresentationMailbox? mailbox;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? buttonPadding;
  final OnSelectSearchFilterAction? onSelectSearchFilterAction;
  final OnDeleteSearchFilterAction? onDeleteSearchFilterAction;

  const SearchFilterButton({
    super.key,
    required this.searchFilter,
    required this.imagePaths,
    this.isSelected = false,
    this.receiveTimeType,
    this.sortOrderType,
    this.startDate,
    this.endDate,
    this.listAddressOfFrom,
    this.listAddressOfTo,
    this.userName,
    this.mailbox,
    this.backgroundColor,
    this.buttonPadding,
    this.onSelectSearchFilterAction,
    this.onDeleteSearchFilterAction,
  });

  @override
  Widget build(BuildContext context) {
    final filterTitle = searchFilter.getTitle(
      context,
      receiveTimeType: receiveTimeType,
      startDate: startDate,
      endDate: startDate,
      sortOrderType: sortOrderType,
      listAddressOfFrom: listAddressOfFrom,
      userName: userName,
      mailbox: mailbox,
      listAddressOfTo: listAddressOfTo,
    );

    final deleteButtonWidget = TMailButtonWidget.fromIcon(
      icon: imagePaths.icDeleteSelection,
      iconSize: SearchFilterButtonStyle.deleteIconSize,
      iconColor: AppColor.colorTextBody,
      padding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => onDeleteSearchFilterAction?.call(searchFilter),
    );

    final listComponentsWidget = <Widget>[
      SvgPicture.asset(
        searchFilter.getIcon(imagePaths, isSelected: isSelected),
        width: SearchFilterButtonStyle.iconSize,
        height: SearchFilterButtonStyle.iconSize,
        colorFilter: searchFilter.getIconColor(isSelected: isSelected).asFilter(),
        fit: BoxFit.fill
      ),
      const SizedBox(width: SearchFilterButtonStyle.spaceSize),
      Text(
        filterTitle.length > _titleCharactersMaximum
          ? '${filterTitle.substring(0, _titleCharactersMaximum)}...'
          : filterTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: SearchFilterButtonStyle.titleStyle,
      ),
      if (searchFilter.isArrowDownIconSupported())
        Padding(
          padding: SearchFilterButtonStyle.elementPadding,
          child: SvgPicture.asset(
            imagePaths.icDropDown,
            width: SearchFilterButtonStyle.iconSize,
            height: SearchFilterButtonStyle.iconSize,
            colorFilter: AppColor.colorTextBody.asFilter(),
            fit: BoxFit.fill
          ),
        ),
    ];

    final childItem = _buildContainerForComponents(
      children: [
        ...listComponentsWidget,
        if (isSelected) deleteButtonWidget,
      ]
    );

    if (onSelectSearchFilterAction == null) {
      return childItem;
    }

    if (!searchFilter.isOnTapWithPositionActionSupported()) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: !searchFilter.isOnTapWithPositionActionSupported()
            ? () => _onTapAction(context)
            : null,
          onTapDown: searchFilter.isOnTapWithPositionActionSupported() && !isSelected
            ? (details) => _onTapDownAction(context, details)
            : null,
          borderRadius: SearchFilterButtonStyle.borderRadius,
          child: childItem
        ),
      );
    }

    return _buildContainerForComponents(
      children: [
        InkWell(
          onTapDown: (details) => _onTapDownAction(context, details),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: listComponentsWidget
          ),
        ),
        if (isSelected) deleteButtonWidget,
      ]
    );
  }

  Widget _buildContainerForComponents({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SearchFilterButtonStyle.borderRadius,
        color: backgroundColor ?? searchFilter.getBackgroundColor(
          isFilterSelected: isSelected
        )
      ),
      padding: buttonPadding ?? SearchFilterButtonStyle.getButtonPadding(isSelected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children
      )
    );
  }

  void _onTapAction(BuildContext context) {
    onSelectSearchFilterAction?.call(context, searchFilter);
  }

  void _onTapDownAction(BuildContext context, TapDownDetails details) {
    final screenSize = MediaQuery.sizeOf(context);
    final offset = details.globalPosition;
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      screenSize.width - offset.dx,
      screenSize.height - offset.dy);

    onSelectSearchFilterAction?.call(context, searchFilter, buttonPosition: position);
  }
}