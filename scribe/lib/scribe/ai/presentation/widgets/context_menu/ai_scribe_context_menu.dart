import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/presentation/model/context_menu/ai_scribe_context_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/utils/context_menu/popup_submenu_controller.dart';
import 'package:scribe/scribe/ai/presentation/widgets/context_menu/ai_scribe_context_menu_item.dart';
import 'package:scribe/scribe/ai/presentation/widgets/context_menu/ai_scribe_submenu.dart';

class AiScribeContextMenu extends StatefulWidget {
  final ImagePaths imagePaths;
  final List<AiScribeContextMenuAction> menuActions;
  final ValueChanged<AiScribeContextMenuAction> onActionSelected;
  final PopupSubmenuController? submenuController;

  const AiScribeContextMenu({
    super.key,
    required this.imagePaths,
    required this.menuActions,
    required this.onActionSelected,
    this.submenuController,
  });

  @override
  State<AiScribeContextMenu> createState() =>
      _AiScribeContextMenuContentState();
}

class _AiScribeContextMenuContentState extends State<AiScribeContextMenu> {
  final GlobalKey _contextMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _contextMenuKey,
      width: AIScribeSizes.contextMenuWidth,
      constraints: const BoxConstraints(
        maxHeight: AIScribeSizes.submenuMaxHeight,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(AIScribeSizes.menuRadius),
        ),
        color: AIScribeColors.background,
        boxShadow: AIScribeShadows.modal,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        shrinkWrap: true,
        padding: AIScribeSizes.contextMenuPadding,
        itemCount: widget.menuActions.length,
        itemBuilder: (context, index) {
          final menuAction = widget.menuActions[index];
          return AiScribeContextMenuItem(
            menuAction: menuAction,
            imagePaths: widget.imagePaths,
            onSelectAction: (menuAction) {
              widget.submenuController?.hide();
              widget.onActionSelected(menuAction);
            },
            onHoverShowSubmenu: (itemKey) =>
                menuAction.submenuActions?.isNotEmpty == true
                    ? _showSubmenu(
                        context: context,
                        itemKey: itemKey,
                        contextMenuKey: _contextMenuKey,
                        actions: menuAction.submenuActions!,
                      )
                    : null,
            onHoverOtherItem: widget.submenuController?.hide,
          );
        },
      ),
    );
  }

  Rect? _generateRectByKey(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;
    final renderBox = renderObject;

    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  void _showSubmenu({
    required BuildContext context,
    required GlobalKey itemKey,
    required GlobalKey contextMenuKey,
    required List<AiScribeContextMenuAction> actions,
  }) {
    final itemRect = _generateRectByKey(itemKey);
    final contextMenuRect = _generateRectByKey(contextMenuKey);

    if (itemRect == null || contextMenuRect == null) {
      return;
    }

    widget.submenuController?.show(
      context: context,
      anchor: itemRect,
      anchorMenu: contextMenuRect,
      submenuMaxHeight: AIScribeSizes.submenuMaxHeight,
      submenuWidth: AIScribeSizes.submenuWidth,
      menuFieldSpacing: AIScribeSizes.fieldSpacing,
      submenu: AiScribeSubmenu(
        menuActions: actions,
        onSelectAction: (action) {
          widget.submenuController?.hide();
          widget.onActionSelected(action);
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.submenuController?.dispose();
    super.dispose();
  }
}
