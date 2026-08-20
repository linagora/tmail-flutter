import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/labels/label_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SidebarLabelItem extends StatelessWidget {

  final Label label;
  final ImagePaths imagePaths;
  final bool isSelected;
  final bool shouldAskReadOnly;
  final OnOpenLabelCallback onOpenLabelCallback;
  final OnOpenLabelContextMenuAction? onOpenContextMenu;
  final OnLongPressLabelItemAction? onLongPressLabelItemAction;

  const SidebarLabelItem({
    super.key,
    required this.label,
    required this.imagePaths,
    required this.onOpenLabelCallback,
    this.isSelected = false,
    this.shouldAskReadOnly = false,
    this.onOpenContextMenu,
    this.onLongPressLabelItemAction,
  });

  @override
  Widget build(BuildContext context) {
    final row = LinagoraSidebarItem(
      label: label.safeDisplayName,
      leading: _buildLeadingIcon(context, imagePaths),
      hoverTrailing: _buildContextMenuAction(context, imagePaths),
      active: isSelected,
      onTap: () => onOpenLabelCallback(label),
    );

    if (!_isLongPressActive) return row;

    return GestureDetector(
      onLongPress: () => onLongPressLabelItemAction?.call(label),
      child: row,
    );
  }

  Widget _buildLeadingIcon(BuildContext context, ImagePaths imagePaths) {
    final style = LinagoraSidebarStyle.of(context);
    final iconSize = style.itemIconSize;

    return SvgPicture.asset(
      imagePaths.icLabel,
      width: iconSize,
      height: iconSize,
      colorFilter: (label.backgroundColor ?? style.foreground).asFilter(),
      fit: BoxFit.contain,
    );
  }

  Widget? _buildContextMenuAction(BuildContext context, ImagePaths imagePaths) {
    if (!_isContextMenuAllowed) return null;

    final style = LinagoraSidebarStyle.of(context);

    return LinagoraSidebarItemActions(
      actions: [
        LinagoraSidebarItemActionEntry(
          id: _SidebarLabelActionId.more,
          child: LinagoraSidebarMenuAction(
            semanticLabel: AppLocalizations.of(context).more,
            onPressed: (details) => onOpenContextMenu?.call(
              label,
              details.belowMenuAnchor(Directionality.of(context)),
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
      ],
    );
  }

  bool get _isActionAllowed => !shouldAskReadOnly || !label.isReadOnly;

  bool get _isContextMenuAllowed =>
      onOpenContextMenu != null && _isActionAllowed;

  bool get _isLongPressActive {
    if (onLongPressLabelItemAction == null) return false;
    if (!PlatformInfo.isWebTouchDevice && !PlatformInfo.isMobile) return false;
    return _isActionAllowed;
  }
}

enum _SidebarLabelActionId { more }
