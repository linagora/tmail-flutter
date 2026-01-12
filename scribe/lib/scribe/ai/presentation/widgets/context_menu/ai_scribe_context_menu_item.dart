import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

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
        child: AiScribeMenuItem(
          itemKey: _itemKey,
          menuAction: widget.menuAction,
          onSelectAction: widget.onSelectAction,
          imagePaths: widget.imagePaths,
        )
      );
    }

    return AiScribeMenuItem(
      itemKey: _itemKey,
      menuAction: widget.menuAction,
      onSelectAction: widget.onSelectAction,
      imagePaths: widget.imagePaths,
      onHover: (_) {
          _hoverController?.exit();
          widget.onHoverOtherItem?.call();
        }
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
