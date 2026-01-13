import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeMobileActionsBottomSheet extends StatefulWidget {
  final ImagePaths imagePaths;
  final List<AIScribeMenuCategory> availableCategories;
  final String? content;

  const AiScribeMobileActionsBottomSheet({
    super.key,
    required this.imagePaths,
    required this.availableCategories,
    this.content,
  });

  @override
  State<AiScribeMobileActionsBottomSheet> createState() =>
      _AiScribeMobileActionsBottomSheetState();
}

class _AiScribeMobileActionsBottomSheetState
    extends State<AiScribeMobileActionsBottomSheet> {
  final ValueNotifier<AiScribeCategoryContextMenuAction?> _selectedCategory =
      ValueNotifier(null);

  void _onActionSelected(AiScribeContextMenuAction menuAction) {
    if (menuAction is AiScribeActionContextMenuAction) {
      Navigator.of(context).pop(PredefinedAction(menuAction.action));
    }
  }

  void _onCustomPromptSubmit(String prompt) {
    Navigator.of(context).pop(CustomPromptAction(prompt));
  }

  void _onCategorySelected(AiScribeCategoryContextMenuAction category) {
    _selectedCategory.value = category;
  }

  void _goBackToCategories() {
    _selectedCategory.value = null;
  }

  Widget _buildHeader(BuildContext context, ScribeLocalizations localizations) {
    return Container(
      padding: AIScribeSizes.suggestionHeaderPadding,
      child: Row(
        children: [
          ValueListenableBuilder<AiScribeCategoryContextMenuAction?>(
            valueListenable: _selectedCategory,
            builder: (context, selectedCategory, _) {
              return selectedCategory != null
                ? TMailButtonWidget.fromIcon(
                  icon: widget.imagePaths.icArrowBackIos,
                  backgroundColor: Colors.transparent,
                  iconSize: AIScribeSizes.bottomsheetIcon,
                  iconColor: AIScribeColors.bottomsheetIcon,
                  padding: AIScribeSizes.backIconPadding,
                  onTapActionCallback: _goBackToCategories
                )
                : const SizedBox.shrink();
            },
          ),
          Expanded(
            child: ValueListenableBuilder<AiScribeCategoryContextMenuAction?>(
              valueListenable: _selectedCategory,
              builder: (context, selectedCategory, _) {
                return Text(
                  selectedCategory?.actionName ?? localizations.aiAssistant,
                  style: AIScribeTextStyles.suggestionTitle,
                );
              },
            ),
          ),
          TMailButtonWidget.fromIcon(
            icon: widget.imagePaths.icCloseDialog,
            backgroundColor: Colors.transparent,
            iconSize: AIScribeSizes.bottomsheetIcon,
            iconColor: AIScribeColors.bottomsheetIcon,
            onTapActionCallback: () => Navigator.of(context).pop()
          )
        ],
      ),
    );
  }

  Widget _buildMenuListView(List<AiScribeCategoryContextMenuAction> menuActions) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
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
    return ValueListenableBuilder<AiScribeCategoryContextMenuAction?>(
      valueListenable: _selectedCategory,
      builder: (context, selectedCategory, _) {
        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: selectedCategory?.submenuActions?.length ?? 0,
          itemBuilder: (context, index) {
            final submenuAction = selectedCategory!.submenuActions![index];
            return AiScribeSubmenuItem(
              menuAction: submenuAction,
              onSelectAction: _onActionSelected,
            );
          },
        );
      },
    );
  }

  Widget _buildTextCard(BuildContext context) {
    final displayText = widget.content;

    if (displayText == null || displayText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: AIScribeSizes.contentCardMargin,
      constraints: const BoxConstraints(
        maxHeight: AIScribeSizes.contentCardMaxHeight,
      ),
      decoration: BoxDecoration(
        color: AIScribeColors.background,
        borderRadius: BorderRadius.circular(AIScribeSizes.contentCardRadius),
        boxShadow: AIScribeShadows.contentCard,
      ),
      child: SingleChildScrollView(
        padding: AIScribeSizes.contentCardPadding,
        child: Text(
          displayText,
          style: AIScribeTextStyles.contentCard,
        ),
      ),
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
  void dispose() {
    _selectedCategory.dispose();
    super.dispose();
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
    
    final hasContent = widget.content?.isNotEmpty ?? false;

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
                  _buildTextCard(context),
                  if(hasContent)
                    Flexible(
                      child: ValueListenableBuilder<AiScribeCategoryContextMenuAction?>(
                        valueListenable: _selectedCategory,
                        builder: (context, selectedCategory, _) {
                          return selectedCategory == null
                              ? _buildMenuListView(menuActions)
                              : _buildSubmenuListView();
                        },
                      ),
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
