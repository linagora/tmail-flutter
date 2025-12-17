import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scribe/scribe/ai/presentation/model/context_menu/ai_scribe_context_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/utils/context_menu/hover_submenu_controller.dart';

class AiScribeContextMenuItem extends StatefulWidget {
  final AiScribeContextMenuAction menuAction;
  final ImagePaths imagePaths;
  final ValueChanged<AiScribeContextMenuAction> onSelectAction;
  final OnHoverShowSubmenu? onHoverShowSubmenu;
  final VoidCallback? onHoverOtherItem;

  const AiScribeContextMenuItem({
    super.key,
    required this.menuAction,
    required this.imagePaths,
    required this.onSelectAction,
    this.onHoverShowSubmenu,
    this.onHoverOtherItem,
  });

  @override
  State<AiScribeContextMenuItem> createState() =>
      _AiScribeContextMenuItemState();
}

class _AiScribeContextMenuItemState extends State<AiScribeContextMenuItem> {
  GlobalKey? _itemKey;
  HoverSubmenuController? _hoverController;

  @override
  void initState() {
    super.initState();
    if (widget.menuAction.hasSubmenu) {
      _itemKey = GlobalKey();
      _hoverController = HoverSubmenuController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final childWidget = Container(
      key: _itemKey,
      height: AIScribeSizes.menuItemHeight,
      padding: AIScribeSizes.menuCategoryItemPadding,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        children: [
          if (widget.menuAction.actionIcon != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: SvgPicture.asset(
                widget.menuAction.actionIcon!,
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter:
                    AppColor.gray424244.withValues(alpha: 0.72).asFilter(),
              ),
            ),
          Flexible(
            child: Text(
              widget.menuAction.actionName,
              style: AIScribeTextStyles.menuItem,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.menuAction.hasSubmenu)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 3),
              child: SvgPicture.asset(
                widget.imagePaths.icArrowRight,
                width: 16,
                height: 16,
                fit: BoxFit.fill,
                colorFilter: AppColor.gray777778.asFilter(),
              ),
            ),
        ],
      ),
    );

    if (widget.menuAction.hasSubmenu) {
      return MouseRegion(
        onEnter: (_) {
          _hoverController?.enter();

          if (_itemKey != null) {
            widget.onHoverShowSubmenu?.call(_itemKey!);
          } else {
            widget.onHoverOtherItem?.call();
          }
        },
        onExit: (_) {
          _hoverController?.exit();
        },
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => widget.onSelectAction(widget.menuAction),
            hoverColor: AppColor.grayBackgroundColor,
            child: childWidget,
          ),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => widget.onSelectAction(widget.menuAction),
        hoverColor: AppColor.grayBackgroundColor,
        onHover: (_) {
          _hoverController?.exit();
          widget.onHoverOtherItem?.call();
        },
        child: childWidget,
      ),
    );
  }

  @override
  void dispose() {
    if (_hoverController != null) {
      _hoverController?.dispose();
      _hoverController = null;
    }
    super.dispose();
  }
}
