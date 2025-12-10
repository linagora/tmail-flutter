import 'dart:async';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

class AIScribeMenu extends StatefulWidget {
  final Function(AIScribeMenuAction) onActionSelected;
  final bool useSubmenuItemStyle;
  final List<AIScribeMenuCategory>? availableCategories;
  final ImagePaths imagePaths;

  const AIScribeMenu({
    super.key,
    required this.onActionSelected,
    required this.imagePaths,
    this.useSubmenuItemStyle = true,
    this.availableCategories,
  });

  @override
  State<AIScribeMenu> createState() => _AIScribeMenuContentState();
}

class _AIScribeMenuContentState extends State<AIScribeMenu> {
  AIScribeMenuCategory? _hoveredCategory;
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _submenuOverlay;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeSubmenu();
    super.dispose();
  }

  void _removeSubmenu() {
    _submenuOverlay?.remove();
    _submenuOverlay = null;
  }

  void _showSubmenu(AIScribeMenuCategory category) {
    if (!category.hasSubmenu) return;

    _removeSubmenu();

    // Get the entire menu's bounds
    final menuRenderBox = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if(menuRenderBox == null) return;

    final menuPosition = menuRenderBox.localToGlobal(Offset.zero);
    final menuSize = menuRenderBox.size;

    _submenuOverlay = OverlayEntry(
      builder: (context) => _SubmenuPanel(
        category: category,
        position: menuPosition,
        parentSize: menuSize,
        onActionSelected: (action) {
          _closeTimer?.cancel();
          _removeSubmenu();
          widget.onActionSelected(action);
        },
        onHover: _cancelClose,
        onDismiss: () {
          setState(() {
            _hoveredCategory = null;
          });
          _removeSubmenu();
        },
      ),
    );

    Overlay.of(context).insert(_submenuOverlay!);
  }

  void _handleCategoryHover(AIScribeMenuCategory category, bool isHovering) {
    if (isHovering) {
      _closeTimer?.cancel();
      _closeTimer = null;

      setState(() {
        _hoveredCategory = category;
        _showSubmenu(category);
      });
    } else {
      // Delay closing to allow mouse to reach submenu
      _closeTimer?.cancel();
      _closeTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && _hoveredCategory == category) {
          setState(() {
            _hoveredCategory = null;
            _removeSubmenu();
          });
        }
      });
    }
  }

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.availableCategories ?? AIScribeMenuCategory.values;
    return Column(
      key: _menuKey,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: categories.map(_buildCategoryItem).toList(),
    );
  }

  Widget _buildCategoryItem(AIScribeMenuCategory category) {
    if (category.hasSubmenu) {
      return Container(
        child: _buildMenuItem(
          label: category.getLabel(context),
          iconPath: category.getIconPath(widget.imagePaths),
          hasSubmenu: true,
          isHovered: _hoveredCategory == category,
          onHover: (isHovering) => _handleCategoryHover(category, isHovering),
        ),
      );
    } else {
      // For categories without submenu (like Correct Grammar)
      return _buildMenuItem(
        label: category.getLabel(context),
        iconPath: category.getIconPath(widget.imagePaths),
        onTap: () {
          if (category.actions.isNotEmpty) {
            widget.onActionSelected(category.actions.first);
          }
        },
      );
    }
  }

  Widget _buildMenuItem({
    required String label,
    required String iconPath,
    VoidCallback? onTap,
    void Function(bool)? onHover,
    bool hasSubmenu = false,
    bool isHovered = false
  }) {
    return SizedBox(
      height: AIScribeSizes.menuItemHeight,
      child: MouseRegion(
        onEnter: onHover != null ? (_) => onHover(true) : null,
        onExit: onHover != null ? (_) => onHover(false) : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AIScribeSizes.menuItemBorderRadius),
          child: Padding(
            padding: AIScribeSizes.menuItemPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              SvgPicture.asset(
                iconPath,
                width: AIScribeSizes.iconSize,
                height: AIScribeSizes.iconSize,
                colorFilter: AIScribeColors.svgColorFilter,
              ),
              const SizedBox(width: AIScribeSizes.fieldSpacing),
                Expanded(
                  child: Text(
                    label,
                    style: AIScribeTextStyles.menuItem,
                  ),
                ),
                if (hasSubmenu)
                  const Icon(
                    Icons.chevron_right,
                    size: AIScribeSizes.iconSize,
                    color: AIScribeColors.textPrimary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Submenu panel that appears to the right of the main menu
class _SubmenuPanel extends StatefulWidget {
  final AIScribeMenuCategory category;
  final Offset position;
  final Size parentSize;
  final Function(AIScribeMenuAction) onActionSelected;
  final VoidCallback onHover;
  final VoidCallback onDismiss;

  const _SubmenuPanel({
    required this.category,
    required this.position,
    required this.parentSize,
    required this.onActionSelected,
    required this.onHover,
    required this.onDismiss,
  });

  @override
  State<_SubmenuPanel> createState() => _SubmenuPanelState();
}

class _SubmenuPanelState extends State<_SubmenuPanel> {
  @override
  Widget build(BuildContext context) {
    final submenuHeight = widget.category.actions.length * AIScribeSizes.menuItemHeight;

    // Position submenu to the right of the parent item
    final left = widget.position.dx + widget.parentSize.width + AIScribeSizes.submenuSpacing;
    final top = widget.position.dy + widget.parentSize.height - submenuHeight;

    final screenSize = MediaQuery.of(context).size;
    // If we exceed screen to the right, we position left instead of right
    final adjustedLeft = (left + AIScribeSizes.menuWidth > screenSize.width)
        ? widget.position.dx - AIScribeSizes.menuWidth - AIScribeSizes.submenuSpacing
        : left;

    // If we exceed screen to the top, we position at top
    final adjustedTop = (top < 0.0)
      ? 0.0
      : top;

    return Stack(
      children: [
        Positioned(
          left: adjustedLeft,
          top: adjustedTop,
          child: MouseRegion(
            onEnter: (_) => widget.onHover(),
            onExit: (_) => widget.onDismiss(),
            child: PointerInterceptor(
              child: Material(
                color: Colors.white,
                elevation: AIScribeSizes.dialogElevation,
                borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
                child: Container(
                  width: AIScribeSizes.menuWidth,
                  constraints: const BoxConstraints(maxHeight: AIScribeSizes.submenuMaxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.category.actions.map((action) {
                      return SizedBox(
                        height: AIScribeSizes.menuItemHeight,
                        child: InkWell(
                          onTap: () => widget.onActionSelected(action),
                          borderRadius: BorderRadius.circular(AIScribeSizes.menuItemBorderRadius),
                          child: Padding(
                            padding: AIScribeSizes.menuItemPadding,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                action.getLabel(context),
                                style: AIScribeTextStyles.menuItem,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
