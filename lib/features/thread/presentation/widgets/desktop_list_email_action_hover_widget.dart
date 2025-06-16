import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DesktopListEmailActionHoverWidget extends StatefulWidget {
  final PresentationEmail presentationEmail;
  final bool isHovered;
  final bool canDeletePermanently;
  final bool isSearchEmailRunning;
  final PresentationMailbox? mailboxContain;
  final OnPressEmailActionClick? emailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  const DesktopListEmailActionHoverWidget({
    super.key,
    required this.presentationEmail,
    required this.isHovered,
    required this.canDeletePermanently,
    required this.isSearchEmailRunning,
    required this.mailboxContain,
    required this.emailActionClick,
    required this.onMoreActionClick,
  });

  @override
  State<DesktopListEmailActionHoverWidget> createState() =>
      _DesktopListEmailActionHoverWidgetState();
}

class _DesktopListEmailActionHoverWidgetState
    extends State<DesktopListEmailActionHoverWidget> with BaseEmailItemTile {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  bool _popupMenuVisible = false;

  @override
  Widget build(BuildContext context) {
    final listActionWidget = [
      if (widget.isHovered) ...[
        TMailButtonWidget.fromIcon(
          icon: _imagePaths.icOpenInNewTab,
          iconColor: ItemEmailTileStyles.actionIconColor,
          iconSize: _getIconSize(),
          padding: _getPaddingIcon(context),
          backgroundColor: Colors.transparent,
          tooltipMessage: AppLocalizations.of(context).openInNewTab,
          onTapActionCallback: () => widget.emailActionClick?.call(
            EmailActionType.openInNewTab,
            widget.presentationEmail,
          ),
        ),
        if (!widget.presentationEmail.isDraft)
          TMailButtonWidget.fromIcon(
            icon: widget.presentationEmail.hasRead
                ? _imagePaths.icUnread
                : _imagePaths.icRead,
            iconColor: ItemEmailTileStyles.actionIconColor,
            iconSize: _getIconSize(),
            padding: _getPaddingIcon(context),
            backgroundColor: Colors.transparent,
            tooltipMessage: widget.presentationEmail.hasRead
                ? AppLocalizations.of(context).mark_as_unread
                : AppLocalizations.of(context).mark_as_read,
            onTapActionCallback: () => widget.emailActionClick?.call(
              widget.presentationEmail.hasRead
                  ? EmailActionType.markAsUnread
                  : EmailActionType.markAsRead,
              widget.presentationEmail,
            ),
          ),
        if (widget.mailboxContain != null &&
            widget.mailboxContain?.isDrafts == false) ...[
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icMove,
            iconColor: ItemEmailTileStyles.actionIconColor,
            iconSize: _getIconSize(),
            padding: _getPaddingIcon(context),
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).move,
            onTapActionCallback: () => widget.emailActionClick?.call(
              EmailActionType.moveToMailbox,
              widget.presentationEmail,
            ),
          ),
        ],
        TMailButtonWidget.fromIcon(
          icon: _imagePaths.icDeleteComposer,
          iconColor: ItemEmailTileStyles.actionIconColor,
          iconSize: 16,
          padding: _getPaddingIcon(context),
          backgroundColor: Colors.transparent,
          tooltipMessage: widget.canDeletePermanently
              ? AppLocalizations.of(context).delete_permanently
              : AppLocalizations.of(context).move_to_trash,
          onTapActionCallback: () => widget.emailActionClick?.call(
            widget.canDeletePermanently
                ? EmailActionType.deletePermanently
                : EmailActionType.moveToTrash,
            widget.presentationEmail,
          ),
        ),
      ],
      if (_shouldShowPopupMenu) ...[
        TMailButtonWidget.fromIcon(
          icon: _imagePaths.icMoreVertical,
          iconColor: ItemEmailTileStyles.actionIconColor,
          iconSize: _getIconSize(),
          padding: _getPaddingIcon(context),
          backgroundColor: _popupMenuVisible
              ? Theme.of(context).colorScheme.outline.withOpacity(0.08)
              : Colors.transparent,
          tooltipMessage: AppLocalizations.of(context).more,
          onTapActionAtPositionCallback: (position) {
            if (_responsiveUtils.isScreenWithShortestSide(context)) {
              widget.onMoreActionClick?.call(widget.presentationEmail, null);
            } else {
              _onPopupMenuVisibleChange(true);

              widget.onMoreActionClick
                  ?.call(widget.presentationEmail, position)
                  .whenComplete(() => _onPopupMenuVisibleChange(false));
            }
          },
        ),
        const SizedBox(width: 16),
      ] else ...[
        buildMailboxContain(
          context,
          widget.isSearchEmailRunning,
          widget.presentationEmail,
        ),
        if (widget.presentationEmail.hasAttachment == true)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: buildIconAttachment(),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 20, start: 8),
          child: buildDateTime(context, widget.presentationEmail),
        ),
      ]
    ];

    if (listActionWidget.isEmpty) return const SizedBox.shrink();

    return Row(children: listActionWidget);
  }

  double _getIconSize() => 18;

  EdgeInsets _getPaddingIcon(BuildContext context) {
    return const EdgeInsets.all(5);
  }

  bool get _shouldShowPopupMenu => widget.isHovered || _popupMenuVisible;

  void _onPopupMenuVisibleChange(bool visible) {
    if (_popupMenuVisible != visible && mounted) {
      setState(() {
        _popupMenuVisible = visible;
      });
    }
  }
}
