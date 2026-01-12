import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeMobileActionsBottomSheet extends StatefulWidget {
  final ImagePaths imagePaths;
  final List<AIScribeMenuCategory> availableCategories;

  const AiScribeMobileActionsBottomSheet({
    super.key,
    required this.imagePaths,
    required this.availableCategories,
  });

  @override
  State<AiScribeMobileActionsBottomSheet> createState() =>
      _AiScribeMobileActionsBottomSheetState();
}

class _AiScribeMobileActionsBottomSheetState
    extends State<AiScribeMobileActionsBottomSheet> {
  AiScribeCategoryContextMenuAction? _selectedCategory;

  void _onActionSelected(AiScribeContextMenuAction menuAction) {
    if (menuAction is AiScribeActionContextMenuAction) {
      Navigator.of(context).pop(PredefinedAction(menuAction.action));
    }
  }

  void _onCustomPromptSubmit(String prompt) {
    Navigator.of(context).pop(CustomPromptAction(prompt));
  }

  void _onCategorySelected(AiScribeCategoryContextMenuAction category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _goBackToCategories() {
    setState(() {
      _selectedCategory = null;
    });
  }

  Widget _buildHeader(BuildContext context, ScribeLocalizations localizations) {
    return Container(
      padding: AIScribeSizes.suggestionHeaderPadding,
      child: Row(
        children: [
          if (_selectedCategory != null)
            GestureDetector(
              onTap: _goBackToCategories,
              child: Padding(
                padding: AIScribeSizes.backIconPadding,
                child: Icon(
                  Icons.chevron_left,
                  size: AIScribeSizes.aiAssistantIcon,
                  color: AppColor.gray424244.withValues(alpha: 0.72),
                ),
              ),
            ),
          Expanded(
            child: Text(
              _selectedCategory?.actionName ?? localizations.aiAssistant,
              style: AIScribeTextStyles.suggestionTitle,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 24,
            ),
            color: AppColor.gray424244.withValues(alpha: 0.72),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuListView(List<AiScribeCategoryContextMenuAction> menuActions) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: menuActions.length,
      itemBuilder: (context, index) {
        final menuAction = menuActions[index];
        return AiScribeMobileActionsItem(
          menuAction: menuAction,
          imagePaths: widget.imagePaths,
          onCategorySelected: _onCategorySelected,
          onActionSelected: _onActionSelected,
        );
      },
    );
  }

  Widget _buildSubmenuListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _selectedCategory!.submenuActions?.length ?? 0,
      itemBuilder: (context, index) {
        final submenuAction = _selectedCategory!.submenuActions![index];
        return AiScribeSubmenuItem(
          menuAction: submenuAction,
          onSelectAction: _onActionSelected,
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColor.colorDividerComposer,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
            left: 16.0,
            right: 16.0,
            top: 8.0,
          ),
          child: AIScribeBar(
            onCustomPrompt: _onCustomPromptSubmit,
            imagePaths: widget.imagePaths,
            boxShadow: const [],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ScribeLocalizations.of(context);
    final menuActions = widget.availableCategories
        .map((category) => AiScribeCategoryContextMenuAction(
              category,
              localizations,
              widget.imagePaths,
            ))
        .toList();

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AIScribeColors.background,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, localizations),
                  Flexible(
                    child: _selectedCategory == null
                        ? _buildMenuListView(menuActions)
                        : _buildSubmenuListView(),
                  ),
                ],
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }
}
