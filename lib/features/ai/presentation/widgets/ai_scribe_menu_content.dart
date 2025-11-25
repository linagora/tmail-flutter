import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:tmail_ui_user/features/ai/presentation/styles/ai_scribe_styles.dart';

/// Shared content for AI assistant menu used by both web and mobile
class AIScribeMenuContent extends StatefulWidget {
  final Function(AIScribeMenuAction) onActionSelected;
  final bool useSubmenuItemStyle;

  const AIScribeMenuContent({
    super.key,
    required this.onActionSelected,
    this.useSubmenuItemStyle = true,
  });

  @override
  State<AIScribeMenuContent> createState() => _AIScribeMenuContentState();
}

class _AIScribeMenuContentState extends State<AIScribeMenuContent> {
  AIScribeMenuCategory? _expandedCategory;

  void _toggleCategory(AIScribeMenuCategory category) {
    _expandedCategory = _expandedCategory == category ? null : category;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AIScribeMenuCategory.values.map((category) {
        return _buildCategoryItem(category);
      }).toList(),
    );
  }

  Widget _buildCategoryItem(AIScribeMenuCategory category) {
    if (category.hasSubmenu) {
      final isExpanded = _expandedCategory == category;

      final content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMenuItem(
            label: category.label,
            hasSubmenu: true,
            isExpanded: isExpanded,
            onTap: () => _toggleCategory(category),
          ),
          if (isExpanded)
            Container(
              color: widget.useSubmenuItemStyle
                  ? AIScribeColors.submenuBackground
                  : null,
              padding: widget.useSubmenuItemStyle
                  ? null
                  : const EdgeInsets.only(left: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: category.actions.map((action) {
                  return _buildMenuItem(
                    label: action.label,
                    isSubmenuItem: widget.useSubmenuItemStyle,
                    onTap: () => widget.onActionSelected(action),
                  );
                }).toList(),
              ),
            ),
        ],
      );

      return content;
    } else {
      // For categories without submenu (like Summarize)
      return _buildMenuItem(
        label: category.label,
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
    bool isExpanded = false,
    bool isSubmenuItem = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSubmenuItem
              ? AIScribeSizes.submenuItemPadding
              : AIScribeSizes.menuItemPadding,
          vertical: AIScribeSizes.menuItemVerticalPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: isSubmenuItem
                    ? AIScribeTextStyles.submenuItem
                    : AIScribeTextStyles.menuItem,
              ),
            ),
            if (hasSubmenu)
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: AIScribeSizes.iconSize,
                color: AIScribeColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
