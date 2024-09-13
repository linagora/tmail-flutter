
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/filter_message_button_style.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

typedef OnSelectFilterMessageOptionAction = Function(
  BuildContext context,
  FilterMessageOption filterMessageOption,
  RelativeRect buttonPosition);
typedef OnDeleteFilterMessageOptionAction = Function(FilterMessageOption filterMessageOption);

class FilterMessageButton extends StatelessWidget {

  static const int _titleCharactersMaximum = 20;

  final FilterMessageOption filterMessageOption;
  final bool isSelected;
  final ImagePaths imagePaths;
  final OnSelectFilterMessageOptionAction? onSelectFilterMessageOptionAction;
  final OnDeleteFilterMessageOptionAction? onDeleteFilterMessageOptionAction;

  const FilterMessageButton({
    super.key,
    required this.filterMessageOption,
    required this.imagePaths,
    this.isSelected = false,
    this.onSelectFilterMessageOptionAction,
    this.onDeleteFilterMessageOptionAction,
  });

  @override
  Widget build(BuildContext context) {
    final filterMessageTitle = filterMessageOption.getTitle(context);

    final deleteButtonWidget = TMailButtonWidget.fromIcon(
      icon: imagePaths.icDeleteSelection,
      iconSize: FilterMessageButtonStyle.deleteIconSize,
      iconColor: AppColor.colorFilterMessageIcon,
      padding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => onDeleteFilterMessageOptionAction?.call(filterMessageOption),
    );

    final listComponentsWidget = [
      SvgPicture.asset(
        filterMessageOption.getIcon(imagePaths),
        width: FilterMessageButtonStyle.iconSize,
        height: FilterMessageButtonStyle.iconSize,
        colorFilter: filterMessageOption.getIconColor().asFilter(),
        fit: BoxFit.fill
      ),
      const SizedBox(width: FilterMessageButtonStyle.spaceSize),
      Text(
        filterMessageTitle.length > _titleCharactersMaximum
          ? '${filterMessageTitle.substring(0, _titleCharactersMaximum)}...'
          : filterMessageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FilterMessageButtonStyle.titleStyle,
      ),
      Padding(
        padding: FilterMessageButtonStyle.elementPadding,
        child: SvgPicture.asset(
          imagePaths.icDropDown,
          width: FilterMessageButtonStyle.arrowDownIconSize,
          height: FilterMessageButtonStyle.arrowDownIconSize,
          colorFilter: AppColor.colorFilterMessageIcon.asFilter(),
          fit: BoxFit.fill
        ),
      ),
    ];

    final childItem = _buildContainerForComponents(
      children: [
        ... listComponentsWidget,
        if (isSelected) deleteButtonWidget,
      ]
    );

    if (onSelectFilterMessageOptionAction == null) {
      return childItem;
    }

    if (!isSelected) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTapDown: (details) => _onTapDownAction(context, details),
          borderRadius: FilterMessageButtonStyle.borderRadius,
          child: childItem
        ),
      );
    }

    return _buildContainerForComponents(
      children: [
        InkWell(
          onTapDown: (details) => _onTapDownAction(context, details),
          borderRadius: FilterMessageButtonStyle.borderRadius,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: listComponentsWidget,
          ),
        ),
        if (isSelected) deleteButtonWidget,
      ]
    );
  }

  Widget _buildContainerForComponents({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: FilterMessageButtonStyle.borderRadius,
        color: filterMessageOption.getBackgroundColor(isSelected: isSelected)
      ),
      padding: FilterMessageButtonStyle.getButtonPadding(isSelected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children
      )
    );
  }

  void _onTapDownAction(BuildContext context, TapDownDetails details) {
    final screenSize = MediaQuery.sizeOf(context);
    final offset = details.globalPosition;
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      screenSize.width - offset.dx,
      screenSize.height - offset.dy);

    onSelectFilterMessageOptionAction?.call(
      context,
      filterMessageOption,
      position);
  }
}