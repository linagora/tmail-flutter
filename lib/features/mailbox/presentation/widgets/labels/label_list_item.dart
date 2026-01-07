import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/trailing_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/labels/label_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_icon_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_name_widget.dart';

class LabelListItem extends StatefulWidget {
  final Label label;
  final ImagePaths imagePaths;
  final bool isDesktop;
  final bool isMobileResponsive;
  final OnOpenLabelContextMenuAction? onOpenContextMenu;
  final OnLongPressLabelItemAction? onLongPressLabelItemAction;

  const LabelListItem({
    super.key,
    required this.label,
    required this.imagePaths,
    this.isDesktop = false,
    this.isMobileResponsive = false,
    this.onOpenContextMenu,
    this.onLongPressLabelItemAction,
  });

  @override
  State<LabelListItem> createState() => _LabelListItemState();
}

class _LabelListItemState extends State<LabelListItem> {
  bool _isContextMenuVisible = false;
  bool _isItemHovered = false;

  late final BorderRadius _borderRadius;
  late final EdgeInsetsGeometry _itemPadding;
  late final double _itemHeight;
  late final double _iconSpacing;

  @override
  void initState() {
    super.initState();

    final isDesktop = widget.isDesktop;

    _borderRadius = BorderRadius.all(
      Radius.circular(
        isDesktop
            ? MailboxItemWidgetStyles.borderRadius
            : MailboxItemWidgetStyles.mobileBorderRadius,
      ),
    );

    _itemPadding = EdgeInsetsDirectional.symmetric(
      horizontal: isDesktop
          ? MailboxItemWidgetStyles.itemPadding
          : MailboxItemWidgetStyles.mobileItemPadding,
    );

    _itemHeight = isDesktop
        ? MailboxItemWidgetStyles.height
        : MailboxItemWidgetStyles.mobileHeight;

    _iconSpacing = isDesktop
        ? MailboxItemWidgetStyles.labelIconSpace
        : MailboxItemWidgetStyles.mobileLabelIconSpace;
  }

  bool get _isMenuButtonVisible => _isContextMenuVisible || _isItemHovered;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: _borderRadius,
        onHover: _handleHoverChanged,
        onTap: () {},
        onLongPress: PlatformInfo.isWebTouchDevice || PlatformInfo.isMobile
          ? () => widget.onLongPressLabelItemAction?.call(widget.label)
          : null,
        child: Container(
          height: _itemHeight,
          padding: _itemPadding,
          decoration: BoxDecoration(borderRadius: _borderRadius),
          child: Row(
            children: [
              _LabelIcon(
                icon: widget.imagePaths.icTag,
                color: widget.label.backgroundColor,
                spacing: _iconSpacing,
              ),
              Expanded(
                child: LabelNameWidget(
                  name: widget.label.safeDisplayName,
                  isDesktop: widget.isDesktop,
                ),
              ),
              _ContextMenuButton(
                visible: _isMenuButtonVisible,
                backgroundColor: _menuButtonBackgroundColor(context),
                imagePaths: widget.imagePaths,
                onTap: _handleMenuTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _menuButtonBackgroundColor(BuildContext context) {
    if (_isContextMenuVisible) {
      return Theme.of(context).colorScheme.outline.withValues(alpha: 0.08);
    }
    return TrailingMailboxItemWidgetStyles.menuIconBackgroundColor;
  }

  void _handleHoverChanged(bool hovered) {
    if (_isItemHovered == hovered) return;

    setState(() {
      _isItemHovered = hovered;
    });
  }

  void _setContextMenuVisible(bool visible) {
    if (_isContextMenuVisible == visible) return;

    setState(() {
      _isContextMenuVisible = visible;
    });
  }

  void _handleMenuTap(RelativeRect position) {
    if (!widget.isMobileResponsive) {
      _setContextMenuVisible(true);
    }

    widget.onOpenContextMenu?.call(widget.label, position).whenComplete(() {
      if (mounted && !widget.isMobileResponsive) {
        _setContextMenuVisible(false);
      }
    });
  }
}

class _LabelIcon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double spacing;

  const _LabelIcon({
    required this.icon,
    required this.color,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return LabelIconWidget(
      icon: icon,
      color: color,
      padding: EdgeInsetsDirectional.only(end: spacing),
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  final bool visible;
  final Color backgroundColor;
  final ImagePaths imagePaths;
  final ValueChanged<RelativeRect> onTap;

  const _ContextMenuButton({
    required this.visible,
    required this.backgroundColor,
    required this.imagePaths,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !visible,
      child: TMailButtonWidget.fromIcon(
        margin: TrailingMailboxItemWidgetStyles.menuIconMargin,
        icon: imagePaths.icMoreVertical,
        iconSize: TrailingMailboxItemWidgetStyles.menuIconSize,
        padding: TrailingMailboxItemWidgetStyles.menuIconPadding,
        backgroundColor: backgroundColor,
        onTapActionAtPositionCallback: onTap,
      ),
    );
  }
}
