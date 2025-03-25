import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/label_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/trailing_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/empty_mailbox_popup_dialog_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_expand_button.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/trailing_mailbox_item_widget.dart';

class LabelMailboxItemWidget extends StatefulWidget {

  final GlobalKey itemKey;
  final MailboxNode mailboxNode;
  final bool showTrailing;
  final bool isItemHovered;
  final bool isSelected;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;
  final OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback;
  final OnClickExpandMailboxNodeAction? onClickExpandMailboxNodeAction;

  const LabelMailboxItemWidget({
    super.key,
    required this.itemKey,
    required this.mailboxNode,
    this.showTrailing = true,
    this.isItemHovered = false,
    this.isSelected = false,
    this.onMenuActionClick,
    this.onEmptyMailboxActionCallback,
    this.onClickExpandMailboxNodeAction,
  });

  @override
  State<LabelMailboxItemWidget> createState() => _LabelMailboxItemWidgetState();
}

class _LabelMailboxItemWidgetState extends State<LabelMailboxItemWidget> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  
  bool _popupVisible = false;
  bool _morePopupMenuVisible = false;

  @override
  Widget build(BuildContext context) {
    final displayNameWidget = TextOverflowBuilder(
      widget.mailboxNode.item.getDisplayName(context),
      style: _displayNameTextStyle,
    );

    final nameWithExpandIcon = Row(
      children: [
        if (widget.mailboxNode.hasChildren())
          Flexible(child: displayNameWidget)
        else
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: displayNameWidget,
            ),
          ),
        if (widget.mailboxNode.hasChildren())
          MailboxExpandButton(
            itemKey: widget.itemKey,
            mailboxNode: widget.mailboxNode,
            imagePaths: _imagePaths,
            responsiveUtils: _responsiveUtils,
            onExpandFolderActionClick: widget.onClickExpandMailboxNodeAction,
          ),
      ],
    );

    if (!widget.showTrailing) {
      if (widget.mailboxNode.item.isTeamMailboxes) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            nameWithExpandIcon,
            TextOverflowBuilder(
              widget.mailboxNode.item.emailTeamMailBoxes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
                color: LabelMailboxItemWidgetStyles.teamMailboxEmailTextColor,
                fontWeight: LabelMailboxItemWidgetStyles.labelFolderTextFontWeight,
              ),
            ),
          ],
        );
      } else {
        return nameWithExpandIcon;
      }
    }

    final trailingWidget = TrailingMailboxItemWidget(
      mailboxNode: widget.mailboxNode,
      responsiveUtils: _responsiveUtils,
      imagePaths: _imagePaths,
      isItemHovered: widget.isItemHovered,
      isShowMoreButton: _shouldShowMorePopupMenu,
    );

    final childWidget = Row(
      children: [
        Expanded(child: nameWithExpandIcon),
        if (_showCleanButton(context))
          Offstage(
            offstage: !_shouldShowPopup,
            child: EmptyMailboxPopupDialogWidget(
              mailboxNode: widget.mailboxNode,
              onEmptyMailboxActionCallback: (mailboxNode) {
                _onPopupVisibleChange(false);
                widget.onEmptyMailboxActionCallback?.call(mailboxNode);
              },
              onPopupVisibleChange: _onPopupVisibleChange,
            ),
          ),
        if (_showCleanButton(context) && !_shouldShowMorePopupMenu)
          const Padding(
            padding: TrailingMailboxItemWidgetStyles.menuIconPadding,
            child: SizedBox(width: TrailingMailboxItemWidgetStyles.menuIconSize),
          ),
        if (_showMoreButton(context))
          Offstage(
            offstage: !_shouldShowMorePopupMenu,
            child: TMailButtonWidget.fromIcon(
              margin: _responsiveUtils.isDesktop(context) &&
                      widget.mailboxNode.item.allowedHasEmptyAction
                  ? EdgeInsets.zero
                  : TrailingMailboxItemWidgetStyles.menuIconMargin,
              icon: _imagePaths.icMoreVertical,
              iconSize: widget.mailboxNode.item.isTeamMailboxes
                  ? 17
                  : TrailingMailboxItemWidgetStyles.menuIconSize,
              padding: widget.mailboxNode.item.isTeamMailboxes
                  ? const EdgeInsets.all(3)
                  : TrailingMailboxItemWidgetStyles.menuIconPadding,
              backgroundColor: _morePopupMenuVisible
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)
                  : TrailingMailboxItemWidgetStyles.menuIconBackgroundColor,
              onTapActionAtPositionCallback: (position) {
                  if (!_responsiveUtils.isScreenWithShortestSide(context)) {
                    _onMorePopupMenuVisibleChange(true);
                  }

                  widget.onMenuActionClick
                      ?.call(position, widget.mailboxNode)
                      .whenComplete(() {
                        if (context.mounted &&
                            !_responsiveUtils.isScreenWithShortestSide(context)) {
                          _onMorePopupMenuVisibleChange(false);
                        }
                      });
              },
            ),
          ),
        trailingWidget,
      ],
    );

    if (widget.mailboxNode.item.isTeamMailboxes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          childWidget,
          TextOverflowBuilder(
            widget.mailboxNode.item.emailTeamMailBoxes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
              color: LabelMailboxItemWidgetStyles.teamMailboxEmailTextColor,
              fontWeight: LabelMailboxItemWidgetStyles.labelFolderTextFontWeight,
            ),
          ),
        ],
      );
    } else {
      return childWidget;
    }
  }

  void _onPopupVisibleChange(bool visible) {
    if (_popupVisible != visible) {
      setState(() => _popupVisible = visible);
    }
  }

  void _onMorePopupMenuVisibleChange(bool visible) {
    if (_morePopupMenuVisible != visible) {
      setState(() => _morePopupMenuVisible = visible);
    }
  }

  bool get _shouldShowPopup => widget.isItemHovered || _popupVisible;

  bool get _shouldShowMorePopupMenu =>
      widget.isItemHovered || _morePopupMenuVisible;

  bool _showCleanButton(BuildContext context) {
    return _responsiveUtils.isWebDesktop(context) &&
        widget.mailboxNode.item.allowedHasEmptyAction;
  }

  bool _showMoreButton(BuildContext context) => PlatformInfo.isWeb;

  TextStyle get _displayNameTextStyle {
    if (widget.isSelected) {
      return ThemeUtils.textStyleInter700(
        color: _responsiveUtils.isDesktop(context) ? null : AppColor.iconFolder,
        fontSize: 14,
      );
    } else {
      return _responsiveUtils.isWebDesktop(context)
        ? ThemeUtils.textStyleBodyBody3(color: Colors.black)
        : ThemeUtils.textStyleInter500();
    }
  }
}