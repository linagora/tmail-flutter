import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

class AIScribeMenu extends StatefulWidget {
  final Function(AIScribeMenuAction) onActionSelected;
  final bool useSubmenuItemStyle;
  final List<AIScribeMenuCategory>? availableCategories;

  const AIScribeMenu({
    super.key,
    required this.onActionSelected,
    this.useSubmenuItemStyle = true,
    this.availableCategories,
  });

  @override
  State<AIScribeMenu> createState() => _AIScribeMenuContentState();
}

class _AIScribeMenuContentState extends State<AIScribeMenu> {
  AIScribeMenuCategory? _hoveredCategory;
  final Map<AIScribeMenuCategory, GlobalKey> _categoryKeys = {};
  OverlayEntry? _submenuOverlay;

  @override
  void initState() {
    super.initState();
    final categories = widget.availableCategories ?? AIScribeMenuCategory.values;
    for (final category in categories) {
      _categoryKeys[category] = GlobalKey();
    }
  }

  @override
  void dispose() {
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

    final renderBox = _categoryKeys[category]?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _submenuOverlay = OverlayEntry(
      builder: (context) => _SubmenuPanel(
        category: category,
        position: position,
        parentSize: size,
        onActionSelected: (action) {
          _removeSubmenu();
          widget.onActionSelected(action);
        },
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

  void _handleCategoryClick(AIScribeMenuCategory category) {
    setState(() {
      // Toggle submenu - close if already open, open if closed
      if (_hoveredCategory == category) {
        _hoveredCategory = null;
        _removeSubmenu();
      } else {
        _hoveredCategory = category;
        _showSubmenu(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.availableCategories ?? AIScribeMenuCategory.values;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: categories.map((category) {
        return _buildCategoryItem(category);
      }).toList(),
    );
  }

  Widget _buildCategoryItem(AIScribeMenuCategory category) {
    if (category.hasSubmenu) {
      return Container(
        key: _categoryKeys[category],
        child: _buildMenuItem(
          label: category.getLabel(context),
          hasSubmenu: true,
          isHovered: _hoveredCategory == category,
          onTap: () => _handleCategoryClick(category),
        ),
      );
    } else {
      // For categories without submenu (like Correct Grammar)
      return _buildMenuItem(
        label: category.getLabel(context),
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
    required VoidCallback onTap,
    bool hasSubmenu = false,
    bool isHovered = false,
    bool isSubmenuItem = false,
  }) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSubmenuItem
                ? AIScribeSizes.submenuItemPadding
                : AIScribeSizes.menuItemPadding,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  color: AIScribeColors.textSecondary,
                ),
            ],
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
  final VoidCallback onDismiss;

  const _SubmenuPanel({
    required this.category,
    required this.position,
    required this.parentSize,
    required this.onActionSelected,
    required this.onDismiss,
  });

  @override
  State<_SubmenuPanel> createState() => _SubmenuPanelState();
}

class _SubmenuPanelState extends State<_SubmenuPanel> {
  @override
  Widget build(BuildContext context) {
    const submenuWidth = 180.0;
    const gap = 8.0;

    // Position submenu to the right of the parent item
    final left = widget.position.dx + widget.parentSize.width + gap;
    final top = widget.position.dy;

    // Get screen size to ensure submenu stays within bounds
    final screenSize = MediaQuery.of(context).size;
    final adjustedLeft = (left + submenuWidth > screenSize.width)
        ? widget.position.dx - submenuWidth - gap // Show on left if no room on right
        : left;

    return Stack(
      children: [
        // Invisible barrier to close submenu when clicking outside
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        // Submenu content
        Positioned(
          left: adjustedLeft,
          top: top,
          child: PointerInterceptor(
            child: Material(
              color: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: submenuWidth,
                constraints: const BoxConstraints(maxHeight: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.category.actions.map((action) {
                    return SizedBox(
                      height: 48,
                      child: InkWell(
                        onTap: () => widget.onActionSelected(action),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
      ],
    );
  }
}
