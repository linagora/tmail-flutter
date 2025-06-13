import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/filter_message_button_style.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

typedef OnSelectFilterMessageOptionAction = Function(BuildContext context,
    FilterMessageOption filterMessageOption, RelativeRect buttonPosition);
typedef OnDeleteFilterMessageOptionAction = Function(
    FilterMessageOption filterMessageOption);

class FilterMessageButton extends StatefulWidget {
  static const int _titleCharactersMaximum = 20;

  final FilterMessageOption filterMessageOption;
  final bool isSelected;
  final ImagePaths imagePaths;
  final OnSelectFilterMessageOptionAction onSelectFilterMessageOptionAction;
  final OnDeleteFilterMessageOptionAction onDeleteFilterMessageOptionAction;

  const FilterMessageButton({
    super.key,
    required this.filterMessageOption,
    required this.imagePaths,
    this.isSelected = false,
    required this.onSelectFilterMessageOptionAction,
    required this.onDeleteFilterMessageOptionAction,
  });

  @override
  State<FilterMessageButton> createState() => _FilterMessageButtonState();
}

class _FilterMessageButtonState extends State<FilterMessageButton> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final filterMessageTitle = widget.filterMessageOption.getTitle(context);

    final deleteButtonWidget = TMailButtonWidget.fromIcon(
      icon: widget.imagePaths.icDeleteSelection,
      iconSize: FilterMessageButtonStyle.deleteIconSize,
      iconColor: AppColor.colorFilterMessageIcon,
      padding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => widget.onDeleteFilterMessageOptionAction
          .call(widget.filterMessageOption),
    );

    final listComponentsWidget = [
      SvgPicture.asset(
        widget.filterMessageOption.getIcon(widget.imagePaths),
        width: FilterMessageButtonStyle.iconSize,
        height: FilterMessageButtonStyle.iconSize,
        colorFilter: widget.filterMessageOption.getIconColor().asFilter(),
        fit: BoxFit.fill,
      ),
      const SizedBox(width: FilterMessageButtonStyle.spaceSize),
      Text(
        filterMessageTitle.length > FilterMessageButton._titleCharactersMaximum
            ? '${filterMessageTitle.substring(
                0,
                FilterMessageButton._titleCharactersMaximum,
              )}...'
            : filterMessageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FilterMessageButtonStyle.titleStyle,
      ),
      Padding(
        padding: FilterMessageButtonStyle.elementPadding,
        child: SvgPicture.asset(
          widget.imagePaths.icDropDown,
          width: FilterMessageButtonStyle.arrowDownIconSize,
          height: FilterMessageButtonStyle.arrowDownIconSize,
          colorFilter: AppColor.colorFilterMessageIcon.asFilter(),
          fit: BoxFit.fill,
        ),
      ),
    ];

    final childItem = _buildContainerForComponents(
      children: [
        ...listComponentsWidget,
        if (widget.isSelected) deleteButtonWidget,
      ],
    );

    if (widget.isSelected) {
      return _buildContainerForComponents(
        key: _buttonKey,
        children: [
          InkWell(
            onTapDown: (details) => _onTapDownAction(context, details),
            borderRadius: FilterMessageButtonStyle.borderRadius,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: listComponentsWidget,
            ),
          ),
          if (widget.isSelected) deleteButtonWidget,
        ],
      );
    } else {
      return Material(
        key: _buttonKey,
        type: MaterialType.transparency,
        child: InkWell(
          onTapDown: (details) => _onTapDownAction(context, details),
          borderRadius: FilterMessageButtonStyle.borderRadius,
          child: childItem,
        ),
      );
    }
  }

  Widget _buildContainerForComponents({
    required List<Widget> children,
    Key? key,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: FilterMessageButtonStyle.borderRadius,
        color: widget.filterMessageOption.getBackgroundColor(
          isSelected: widget.isSelected,
        ),
      ),
      padding: FilterMessageButtonStyle.getButtonPadding(widget.isSelected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
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
      position = RelativeRect.fromRect(
        Rect.fromLTWH(
          buttonPosition.dx,
          buttonPosition.dy + buttonSize.height + 8,
          0,
          0,
        ),
        Offset.zero & overlayBox.size,
      );
    }

    widget.onSelectFilterMessageOptionAction.call(
      context,
      widget.filterMessageOption,
      position,
    );
  }
}
