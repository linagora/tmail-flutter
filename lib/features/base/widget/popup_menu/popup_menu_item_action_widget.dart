import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/email_action_type.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';

class PopupMenuItemActionWidget extends StatefulWidget {
  final PopupMenuItemAction menuAction;
  final OnPopupMenuActionClick menuActionClick;
  final OnHoverShowSubmenu? onHoverShowSubmenu;
  final VoidCallback? onHoverOtherItem;

  const PopupMenuItemActionWidget({
    super.key,
    required this.menuAction,
    required this.menuActionClick,
    this.onHoverShowSubmenu,
    this.onHoverOtherItem,
  });

  @override
  State<PopupMenuItemActionWidget> createState() =>
      _PopupMenuItemActionWidgetState();
}

class _PopupMenuItemActionWidgetState extends State<PopupMenuItemActionWidget> {
  GlobalKey? _itemKey;
  ValueNotifier<bool>? _hoverItemNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.menuAction is PopupMenuItemEmailAction) {
      _itemKey = GlobalKey();
      _hoverItemNotifier = ValueNotifier(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;
    Widget? selectedIconWidget;
    bool isSelected = false;

    if (widget.menuAction is PopupMenuItemActionRequiredIcon) {
      final specificMenuAction =
          widget.menuAction as PopupMenuItemActionRequiredIcon;
      iconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: SvgPicture.asset(
          specificMenuAction.actionIcon,
          width: specificMenuAction.actionIconSize,
          height: specificMenuAction.actionIconSize,
          colorFilter: specificMenuAction.actionIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
    } else if (widget.menuAction is PopupMenuItemActionRequiredSelectedIcon) {
      final specificMenuAction =
          widget.menuAction as PopupMenuItemActionRequiredSelectedIcon;
      selectedIconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: specificMenuAction.selectedIconSize,
          height: specificMenuAction.selectedIconSize,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected =
          specificMenuAction.selectedAction == widget.menuAction.action;
    } else if (widget.menuAction is PopupMenuItemActionRequiredFull) {
      final specificMenuAction =
          widget.menuAction as PopupMenuItemActionRequiredFull;
      iconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: SvgPicture.asset(
          specificMenuAction.actionIcon,
          width: specificMenuAction.actionIconSize,
          height: specificMenuAction.actionIconSize,
          colorFilter: specificMenuAction.actionIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      selectedIconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: specificMenuAction.selectedIconSize,
          height: specificMenuAction.selectedIconSize,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected =
          specificMenuAction.selectedAction == widget.menuAction.action;
    } else if (widget.menuAction
        is PopupMenuItemActionRequiredIconWithMultipleSelected) {
      final specificMenuAction = widget.menuAction
          as PopupMenuItemActionRequiredIconWithMultipleSelected;
      iconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: SvgPicture.asset(
          specificMenuAction.actionIcon,
          width: specificMenuAction.actionIconSize,
          height: specificMenuAction.actionIconSize,
          colorFilter: specificMenuAction.actionIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      selectedIconWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: SvgPicture.asset(
          specificMenuAction.selectedIcon,
          width: specificMenuAction.selectedIconSize,
          height: specificMenuAction.selectedIconSize,
          colorFilter: specificMenuAction.selectedIconColor.asFilter(),
          fit: BoxFit.fill,
        ),
      );
      isSelected =
          specificMenuAction.selectedActions.contains(widget.menuAction.action);
    }

    if (widget.menuAction is PopupMenuItemEmailAction &&
        widget.menuAction.action == EmailActionType.labelAs) {
      final specificMenuAction = widget.menuAction as PopupMenuItemEmailAction;

      return PointerInterceptor(
        child: MouseRegion(
          onEnter: (_) {
            if (_hoverItemNotifier != null) {
              _hoverItemNotifier?.value = true;
            }
            if (_itemKey != null) {
              widget.onHoverShowSubmenu?.call(_itemKey!);
            } else {
              widget.onHoverOtherItem?.call();
            }
          },
          onExit: (_) {
            if (_hoverItemNotifier != null) {
              _hoverItemNotifier?.value = false;
            }
          },
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => specificMenuAction.onClick(widget.menuActionClick),
              hoverColor: AppColor.popupMenuItemHovered,
              child: Container(
                key: _itemKey,
                height: 48,
                width: double.infinity,
                padding: specificMenuAction.itemPadding,
                child: Row(
                  children: [
                    if (iconWidget != null) iconWidget,
                    Expanded(
                      child: Text(
                        specificMenuAction.actionName,
                        style: ThemeUtils.textStyleBodyBody3(
                          color: specificMenuAction.actionNameColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected && selectedIconWidget != null)
                      selectedIconWidget,
                    if (_hoverItemNotifier != null)
                      ValueListenableBuilder(
                        valueListenable: _hoverItemNotifier!,
                        builder: (_, value, __) {
                          if (value) {
                            return Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 16),
                              child: SvgPicture.asset(
                                specificMenuAction.hoverIcon,
                                width: specificMenuAction.hoverIconSize,
                                height: specificMenuAction.hoverIconSize,
                                colorFilter: specificMenuAction.hoverIconColor
                                    .asFilter(),
                                fit: BoxFit.fill,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return PointerInterceptor(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => widget.menuAction.onClick(widget.menuActionClick),
          hoverColor: AppColor.popupMenuItemHovered,
          onHover: (_) {
            if (_hoverItemNotifier != null) {
              _hoverItemNotifier?.value = false;
            }
            widget.onHoverOtherItem?.call();
          },
          child: Container(
            key: _itemKey,
            height: 48,
            width: double.infinity,
            padding: widget.menuAction.itemPadding,
            child: Row(
              children: [
                if (iconWidget != null) iconWidget,
                Expanded(
                  child: Text(
                    widget.menuAction.actionName,
                    style: ThemeUtils.textStyleBodyBody3(
                      color: widget.menuAction.actionNameColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected && selectedIconWidget != null)
                  selectedIconWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_hoverItemNotifier != null) {
      _hoverItemNotifier?.dispose();
      _hoverItemNotifier = null;
    }
    super.dispose();
  }
}
