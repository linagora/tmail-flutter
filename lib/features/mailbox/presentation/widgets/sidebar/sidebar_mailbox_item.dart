import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSidebarMailboxExpandAction = void Function(MailboxNode mailboxNode);

enum _SidebarMailboxActionId { clean, more }

class SidebarMailboxItem extends StatelessWidget {

  final MailboxNode mailboxNode;
  final ImagePaths imagePaths;
  final bool isWebDesktop;
  final PresentationMailbox? mailboxNodeSelected;
  final bool isHighlighted;
  final bool isDraggingMailbox;
  final OnClickOpenMailboxNodeAction? onOpenMailboxFolderClick;
  final OnSidebarMailboxExpandAction? onExpandFolderActionClick;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;
  final OnDragEmailToMailboxAccepted? onDragItemAccepted;
  final OnLongPressMailboxNodeAction? onLongPressMailboxNodeAction;
  final OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback;

  const SidebarMailboxItem({
    super.key,
    required this.mailboxNode,
    required this.imagePaths,
    required this.isWebDesktop,
    this.mailboxNodeSelected,
    this.isHighlighted = false,
    this.isDraggingMailbox = false,
    this.onOpenMailboxFolderClick,
    this.onExpandFolderActionClick,
    this.onMenuActionClick,
    this.onDragItemAccepted,
    this.onLongPressMailboxNodeAction,
    this.onEmptyMailboxActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = mailboxNode.hasChildren();
    final actions = _buildActions(context);

    final row = LinagoraSidebarItem(
      label: mailboxNode.item.getDisplayName(context),
      leading: _isIconDisplayed ? _buildLeadingIcon(context, imagePaths) : null,
      supportingText: mailboxNode.item.isTeamMailboxes
        ? mailboxNode.item.emailTeamMailBoxes
        : null,
      badgeLabel: _badgeLabel,
      hoverTrailing: actions,
      expanded: hasChildren ? mailboxNode.expandMode.isExpanded : null,
      onExpandTogglePressed: hasChildren
          ? (_) => onExpandFolderActionClick?.call(mailboxNode)
          : null,
      expandToggleLabel: hasChildren
        ? mailboxNode.expandMode.getTooltipMessage(AppLocalizations.of(context))
        : null,
      scrollIntoViewOnExpand: hasChildren,
      active: _isActive,
      onTap: () => onOpenMailboxFolderClick?.call(mailboxNode),
    );

    return _withTreeIndent(
      context,
      _withLongPress(
        _withDropTarget(row, isWebDesktop),
        isWebDesktop,
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, ImagePaths imagePaths) {
    final style = LinagoraSidebarStyle.of(context);

    return SvgPicture.asset(
      mailboxNode.item.getMailboxIcon(imagePaths),
      width: style.itemIconSize,
      height: style.itemIconSize,
      colorFilter: (_isActive ? style.activeForeground : style.foreground)
          .asFilter(),
      fit: BoxFit.contain,
    );
  }

  Widget? _buildActions(BuildContext context) {
    final showCleanAction =
        isWebDesktop && mailboxNode.allowedHasEmptyAction;
    final showMoreAction = PlatformInfo.isWeb;

    if (!showCleanAction && !showMoreAction) return null;

    return LinagoraSidebarItemActions(
      actions: buildSidebarMailboxItemActions(
        context,
        mailboxNode: mailboxNode,
        imagePaths: imagePaths,
        showCleanAction: showCleanAction,
        showMoreAction: showMoreAction,
        onEmptyMailboxActionCallback: onEmptyMailboxActionCallback,
        onMenuActionClick: onMenuActionClick,
      ),
    );
  }

  Widget _withLongPress(Widget child, bool isWebDesktop) {
    if (onLongPressMailboxNodeAction == null || isWebDesktop) return child;
    if (PlatformInfo.isWeb && PlatformInfo.isCanvasKit) return child;

    return GestureDetector(
      onLongPress: () => onLongPressMailboxNodeAction?.call(mailboxNode),
      child: child,
    );
  }

  Widget _withTreeIndent(BuildContext context, Widget child) {
    final indent = LinagoraSidebarIndent.of(context);
    if (indent == 0) return child;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent),
      child: LinagoraSidebarIndent(indent: 0, child: child),
    );
  }

  Widget _withDropTarget(Widget child, bool isWebDesktop) {
    if (!_canAcceptDrop(isWebDesktop)) return child;

    return LinagoraSidebarItemDropTarget<List<PresentationEmail>>(
      onDrop: _onDropEmails,
      child: child,
    );
  }

  void _onDropEmails(
    LinagoraSidebarItemDropDetails<List<PresentationEmail>> details,
  ) {
    onDragItemAccepted?.call(details.data, mailboxNode.item);
  }

  bool _canAcceptDrop(bool isWebDesktop) =>
      isWebDesktop &&
      onDragItemAccepted != null &&
      !mailboxNode.item.isActionRequired;

  bool get _isSelected => mailboxNodeSelected?.id == mailboxNode.item.id;

  bool get _isActive {
    if (isDraggingMailbox && mailboxNode.item.isActionRequired) return false;
    return _isSelected || isHighlighted;
  }

  String? get _badgeLabel {
    final item = mailboxNode.item;
    // Trash and Spam use the trailing slot for Clean on desktop. The previous
    // sidebar deliberately hid their total count rather than swapping it with
    // a badge as the row hover state changed. Their unread count is already
    // excluded by [allowedToDisplayCountOfUnreadEmails].
    if (item.isTrash || item.isSpam) return null;
    if (item.allowedToDisplayCountOfUnreadEmails) {
      return item.countUnReadEmailsAsString;
    }
    if (item.allowedToDisplayCountOfTotalEmails) {
      return item.countTotalEmailsAsString;
    }
    return null;
  }

  bool get _isIconDisplayed =>
      mailboxNode.item.isPersonal || mailboxNode.item.hasParentId();
}

List<LinagoraSidebarItemActionEntry> buildSidebarMailboxItemActions(
  BuildContext context, {
  required MailboxNode mailboxNode,
  required ImagePaths imagePaths,
  required bool showCleanAction,
  required bool showMoreAction,
  OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback,
  OnClickOpenMenuMailboxNodeAction? onMenuActionClick,
}) {
  final appLocalizations = AppLocalizations.of(context);
  final style = LinagoraSidebarStyle.of(context);

  return [
    if (showCleanAction)
      LinagoraSidebarItemActionEntry(
        id: _SidebarMailboxActionId.clean,
        child: LinagoraSidebarPopoverAction(
          semanticLabel: appLocalizations.clean,
          modalSemanticLabel: appLocalizations.clearFolder,
          overlayWrapper: (child) => PointerInterceptor(child: child),
          popoverBuilder: (context, close) => LinagoraSidebarConfirmPopover(
            title: appLocalizations.clearFolder,
            message: appLocalizations.messageEmptyFolderDialog(
              mailboxNode.item.getDisplayName(context),
            ),
            cancelLabel: appLocalizations.cancel,
            confirmLabel: appLocalizations.clean,
            closeSemanticLabel: appLocalizations.close,
            maxHeight: MediaQuery.sizeOf(context).height,
            confirmButtonVariant:
                LinagoraSidebarConfirmButtonVariant.primary,
            onCancel: close,
            onConfirm: () {
              close();
              onEmptyMailboxActionCallback?.call(mailboxNode);
            },
          ),
          child: Text(appLocalizations.clean, maxLines: 1),
        ),
      ),
    if (showMoreAction)
      LinagoraSidebarItemActionEntry(
        id: _SidebarMailboxActionId.more,
        child: LinagoraSidebarMenuAction(
          key: const ValueKey(UiKeys.mailboxMoreActionButton),
          semanticLabel: appLocalizations.more,
          onPressed: (details) => onMenuActionClick?.call(
            details.belowMenuAnchor(Directionality.of(context)),
            mailboxNode,
          ),
          child: SvgPicture.asset(
            imagePaths.icMoreVertical,
            width: style.itemIconSize,
            height: style.itemIconSize,
            colorFilter: style.trailingForeground.asFilter(),
            fit: BoxFit.contain,
          ),
        ),
      ),
  ];
}
