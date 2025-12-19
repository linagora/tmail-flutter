import 'dart:math';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe.dart';

class AiScribeModalWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final String? content;
  final List<AIScribeMenuCategory> availableCategories;
  final Offset? buttonPosition;
  final Size? buttonSize;
  final ModalPlacement? preferredPlacement;
  final ModalCrossAxisAlignment crossAxisAlignment;
  final PopupSubmenuController? submenuController;

  const AiScribeModalWidget({
    super.key,
    required this.imagePaths,
    required this.availableCategories,
    this.content,
    this.buttonPosition,
    this.buttonSize,
    this.preferredPlacement,
    this.crossAxisAlignment = ModalCrossAxisAlignment.center,
    this.submenuController,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = content?.isNotEmpty ?? false;
    final scribeLocalizations = ScribeLocalizations.of(context);
    final menuActions = availableCategories
        .map((category) => AiScribeCategoryContextMenuAction(
              category,
              scribeLocalizations,
              imagePaths,
            ))
        .toList();

    final dialogContent = PointerInterceptor(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AIScribeSizes.fieldSpacing,
        children: [
          if (hasContent)
            Flexible(
              child: AiScribeContextMenu(
                imagePaths: imagePaths,
                menuActions: menuActions,
                submenuController: submenuController,
                onActionSelected: (menuAction) => _onActionSelected(
                  context,
                  menuAction,
                ),
              ),
            ),
          MouseRegion(
            onEnter: (_) => submenuController?.hide(),
            child: AIScribeBar(
              imagePaths: imagePaths,
              onCustomPrompt: (customPrompt) {
                Navigator.of(context).pop(CustomPromptAction(customPrompt));
                submenuController?.hide();
              },
            ),
          ),
        ],
      ),
    );

    if (buttonPosition != null && buttonSize != null) {
      final maxHeightModal = hasContent
          ? AIScribeSizes.searchBarMinHeight +
              AIScribeSizes.fieldSpacing +
              min(menuActions.length * AIScribeSizes.menuItemHeight,
                  AIScribeSizes.submenuMaxHeight)
          : AIScribeSizes.searchBarMinHeight;

      final layoutResult = AnchoredModalLayoutCalculator.calculate(
        input: AnchoredModalLayoutInput(
          screenSize: MediaQuery.of(context).size,
          anchorPosition: buttonPosition!,
          anchorSize: buttonSize!,
          menuSize: Size(
            AIScribeSizes.modalMaxWidth,
            maxHeightModal,
          ),
          preferredPlacement: preferredPlacement,
          crossAxisAlignment: crossAxisAlignment,
        ),
        padding: AIScribeSizes.screenEdgePadding,
      );

      final position = layoutResult.position;

      final top = preferredPlacement == ModalPlacement.top
          ? position.dy -
              (hasContent
                  ? AIScribeSizes.modalSpacing
                  : AIScribeSizes.modalWithoutContentSpacing)
          : position.dy;

      return PointerInterceptor(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: Navigator.of(context).pop,
              ),
            ),
            PositionedDirectional(
              start: position.dx,
              top: top,
              child: dialogContent,
            ),
          ],
        ),
      );
    }

    return Center(child: dialogContent);
  }

  void _onActionSelected(
    BuildContext context,
    AiScribeContextMenuAction menuAction,
  ) {
    final navigator = Navigator.of(context);
    if (menuAction is AiScribeCategoryContextMenuAction) {
      final firstAiScribeAction = menuAction.action.actions.firstOrNull;
      if (firstAiScribeAction != null) {
        navigator.pop(PredefinedAction(firstAiScribeAction));
      } else {
        navigator.pop();
      }
    } else if (menuAction is AiScribeActionContextMenuAction) {
      navigator.pop(PredefinedAction(menuAction.action));
    } else {
      navigator.pop();
    }
  }
}
