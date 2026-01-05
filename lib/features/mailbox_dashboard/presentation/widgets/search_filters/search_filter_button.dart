import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/search_filter_button_style.dart';

typedef OnSelectSearchFilterAction = Function(
    BuildContext context, QuickSearchFilter searchFilter,
    {RelativeRect? buttonPosition});
typedef OnDeleteSearchFilterAction = Function(QuickSearchFilter searchFilter);

class SearchFilterButton extends StatefulWidget {
  static const int _titleCharactersMaximum = 20;

  final QuickSearchFilter searchFilter;
  final bool isSelected;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final EmailReceiveTimeType? receiveTimeType;
  final EmailSortOrderType? sortOrderType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String>? listAddressOfFrom;
  final Set<String>? listAddressOfTo;
  final PresentationMailbox? mailbox;
  final Label? label;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? buttonPadding;
  final bool isContextMenuAlignEndButton;
  final OnSelectSearchFilterAction? onSelectSearchFilterAction;
  final OnDeleteSearchFilterAction? onDeleteSearchFilterAction;

  const SearchFilterButton({
    super.key,
    required this.searchFilter,
    required this.imagePaths,
    required this.responsiveUtils,
    this.isSelected = false,
    this.isContextMenuAlignEndButton = true,
    this.receiveTimeType,
    this.sortOrderType,
    this.startDate,
    this.endDate,
    this.listAddressOfFrom,
    this.listAddressOfTo,
    this.mailbox,
    this.label,
    this.backgroundColor,
    this.buttonPadding,
    this.onSelectSearchFilterAction,
    this.onDeleteSearchFilterAction,
  });

  @override
  State<SearchFilterButton> createState() => _SearchFilterButtonState();
}

class _SearchFilterButtonState extends State<SearchFilterButton> {
  final GlobalKey _buttonKey = GlobalKey();
  final layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final filterTitle = widget.searchFilter.getTitle(
      context,
      receiveTimeType: widget.receiveTimeType,
      startDate: widget.startDate,
      endDate: widget.startDate,
      sortOrderType: widget.sortOrderType,
      listAddressOfFrom: widget.listAddressOfFrom,
      mailbox: widget.mailbox,
      label: widget.label,
      listAddressOfTo: widget.listAddressOfTo,
    );

    final deleteButtonWidget = TMailButtonWidget.fromIcon(
      icon: widget.imagePaths.icDeleteSelection,
      iconSize: SearchFilterButtonStyle.deleteIconSize,
      iconColor: AppColor.colorTextBody,
      padding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => widget.onDeleteSearchFilterAction?.call(
        widget.searchFilter,
      ),
    );

    final listComponentsWidget = <Widget>[
      SvgPicture.asset(
          widget.searchFilter.getIcon(
            widget.imagePaths,
            isSelected: widget.isSelected,
          ),
          width: SearchFilterButtonStyle.iconSize,
          height: SearchFilterButtonStyle.iconSize,
          colorFilter: widget.searchFilter
              .getIconColor(
                isSelected: widget.isSelected,
              )
              .asFilter(),
          fit: BoxFit.fill),
      const SizedBox(width: SearchFilterButtonStyle.spaceSize),
      Text(
        filterTitle.length > SearchFilterButton._titleCharactersMaximum
            ? '${filterTitle.substring(
                0,
                SearchFilterButton._titleCharactersMaximum,
              )}...'
            : filterTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: SearchFilterButtonStyle.titleStyle,
      ),
      if (widget.searchFilter.isArrowDownIconSupported())
        Padding(
          padding: SearchFilterButtonStyle.elementPadding,
          child: SvgPicture.asset(
            widget.imagePaths.icDropDown,
            width: SearchFilterButtonStyle.iconSize,
            height: SearchFilterButtonStyle.iconSize,
            colorFilter: AppColor.colorTextBody.asFilter(),
            fit: BoxFit.fill,
          ),
        ),
    ];

    if (widget.onSelectSearchFilterAction == null) {
      return _buildContainerForComponents(
        children: [
          ...listComponentsWidget,
          if (widget.isSelected) deleteButtonWidget,
        ],
      );
    } else if (!_isOnTapWithPositionActionSupported()) {
      return CompositedTransformTarget(
        link: layerLink,
        child: Material(
          key: _buttonKey,
          type: MaterialType.transparency,
          child: InkWell(
            onTap: !_isOnTapWithPositionActionSupported()
                ? () => _onTapAction(context)
                : null,
            onTapDown: _isOnTapWithPositionActionSupported() && !widget.isSelected
                ? (details) => _onTapDownAction(context, details)
                : null,
            borderRadius: SearchFilterButtonStyle.borderRadius,
            child: _buildContainerForComponents(
              children: [
                ...listComponentsWidget,
                if (widget.isSelected) deleteButtonWidget,
              ],
            ),
          ),
        ),
      );
    } else {
      return _buildContainerForComponents(
        key: _buttonKey,
        children: [
          InkWell(
            onTapDown: (details) => _onTapDownAction(context, details),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: listComponentsWidget,
            ),
          ),
          if (widget.isSelected) deleteButtonWidget,
        ],
      );
    }
  }

  bool _isOnTapWithPositionActionSupported() {
    return widget.searchFilter.isOnTapWithPositionActionSupported(
      context,
      widget.responsiveUtils,
    );
  }

  Widget _buildContainerForComponents({
    required List<Widget> children,
    Key? key,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: SearchFilterButtonStyle.borderRadius,
        color: widget.backgroundColor ??
            widget.searchFilter
                .getBackgroundColor(isSelected: widget.isSelected),
      ),
      padding: widget.buttonPadding ??
          SearchFilterButtonStyle.getButtonPadding(
            widget.isSelected,
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  void _onTapAction(BuildContext context) {
    widget.onSelectSearchFilterAction?.call(context, widget.searchFilter);
  }

  void _onTapDownAction(BuildContext context, TapDownDetails details) {
    RelativeRect? position;

    final buttonBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;

    if (buttonBox == null || overlayBox == null) {
      final screenSize = MediaQuery.sizeOf(context);
      final offset = details.globalPosition;
      position = RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      );
    } else {
      final buttonPosition = buttonBox.localToGlobal(
        Offset.zero,
        ancestor: overlayBox,
      );
      final buttonSize = buttonBox.size;
      final dX = widget.isContextMenuAlignEndButton
        ? buttonPosition.dx + buttonSize.width
        : buttonPosition.dx;

      position = RelativeRect.fromRect(
        Rect.fromLTWH(
          dX,
          buttonPosition.dy + buttonSize.height + 8,
          0,
          0,
        ),
        Offset.zero & overlayBox.size,
      );
    }

    widget.onSelectSearchFilterAction?.call(
      context,
      widget.searchFilter,
      buttonPosition: position,
    );
  }
}
