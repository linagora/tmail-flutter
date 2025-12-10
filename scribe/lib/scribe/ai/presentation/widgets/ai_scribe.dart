import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:scribe/scribe/ai/domain/state/generate_ai_text_state.dart';
import 'package:scribe/scribe/ai/domain/usecases/generate_ai_text_interactor.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:scribe/scribe/ai/presentation/widgets/ai_scribe_bar.dart';
import 'package:scribe/scribe/ai/presentation/widgets/ai_scribe_menu.dart';
import 'package:scribe/scribe/ai/presentation/widgets/ai_scribe_suggestion.dart';

typedef AIScribeResultCallback = void Function(String result);

Future<void> showAIScribeDialog({
  required BuildContext context,
  required ImagePaths imagePaths,
  required String content,
  required AIScribeResultCallback onInsertText,
  required GenerateAITextInteractor interactor,
  List<AIScribeMenuCategory>? availableCategories,
  Offset? buttonPosition,
}) async {
  final hasContent = content.isNotEmpty;

  final selectedAction = await showDialog<AIAction>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final dialogContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasContent) ...[
            Material(
              color: Colors.white,
              elevation: AIScribeSizes.dialogElevation,
              borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
              child: SizedBox(
                width: AIScribeSizes.menuWidth,
                child: AIScribeMenu(
                  onActionSelected: (action) {
                    Navigator.of(context).pop(PredefinedAction(action));
                  },
                  imagePaths: imagePaths,
                  availableCategories: availableCategories,
                ),
              ),
            ),
            const SizedBox(height: AIScribeSizes.fieldSpacing),
          ],
          Material(
            color: Colors.white,
            elevation: AIScribeSizes.dialogElevation,
            borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
            child: SizedBox(
              width: AIScribeSizes.barWidth,
              child: AIScribeBar(
                onCustomPrompt: (customPrompt) {
                  Navigator.of(context).pop(CustomPromptAction(customPrompt));
                },
                imagePaths: imagePaths
              ),
            ),
          ),
        ],
      );

      if (buttonPosition != null) {
        final categories = availableCategories ?? AIScribeMenuCategory.values;
        final modalHeight = hasContent
            ? (categories.length * AIScribeSizes.menuItemHeight) + AIScribeSizes.fieldSpacing + AIScribeSizes.barHeight
            : AIScribeSizes.barHeight;

        final position = calculateModalPosition(
          context: context,
          buttonPosition: buttonPosition,
          modalWidth: AIScribeSizes.barWidth,
          modalHeight: modalHeight,
        );

        return PointerInterceptor(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned(
                  left: position.left,
                  bottom: position.bottom,
                  child: dialogContent,
                ),
              ],
            ),
          ),
        );
      }

      return Center(child: dialogContent);
    },
  );

  if (selectedAction == null) {
    log('showAIScribeDialog: No action selected');
    return;
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final suggestionFuture = _executeAIRequest(interactor, selectedAction, content);
      final title = selectedAction.getLabel(context);

      final modalContent = AIScribeSuggestion(
        title: title,
        suggestionFuture: suggestionFuture,
        onClose: () => Navigator.of(context).pop(),
        onInsert: (result) {
          onInsertText(result);
          Navigator.of(context).pop();
        },
        imagePaths: imagePaths,
      );

      if (buttonPosition != null) {
        final screenSize = MediaQuery.of(context).size;
        final modalWidth = screenSize.width < AIScribeSizes.mobileBreakpoint
            ? screenSize.width * AIScribeSizes.mobileWidthPercentage
            : AIScribeSizes.modalMaxWidthLargeScreen;

        final position = calculateModalPosition(
          context: context,
          buttonPosition: buttonPosition,
          modalWidth: modalWidth,
          modalHeight: AIScribeSizes.modalMaxHeight,
        );

        return PointerInterceptor(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
           behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned(
                  left: position.left,
                  bottom: position.bottom,
                  child: modalContent,
                ),
              ],
            ),
          ),
        );
      }

      return Center(child: modalContent);
    },
  );
}

double calculateMenuDialogHeight({
  required bool hasContent,
  required int categoryCount,
}) {
  return hasContent
      ? (categoryCount * AIScribeSizes.menuItemHeight) + AIScribeSizes.fieldSpacing + AIScribeSizes.barHeight
      : AIScribeSizes.barHeight;
}

({double left, double bottom}) calculateModalPosition({
  required BuildContext context,
  required Offset buttonPosition,
  required double modalWidth,
  double? modalHeight,
}) {
  final screenSize = MediaQuery.of(context).size;

  // Calculate position above the button
  double left = buttonPosition.dx;
  double bottom = screenSize.height - buttonPosition.dy + AIScribeSizes.fieldSpacing;

  // Ensure modal doesn't go off screen horizontally
  if (left + modalWidth > screenSize.width) {
    left = screenSize.width - modalWidth - AIScribeSizes.screenEdgePadding;
  }
  if (left < AIScribeSizes.screenEdgePadding) {
    left = AIScribeSizes.screenEdgePadding;
  }

  // Ensure modal doesn't go off screen vertically (if height is provided)
  if (modalHeight != null) {
    if (bottom + modalHeight > screenSize.height) {
      bottom = screenSize.height - modalHeight - AIScribeSizes.screenEdgePadding;
    }
    if (bottom < AIScribeSizes.screenEdgePadding) {
      bottom = AIScribeSizes.screenEdgePadding;
    }
  }

  return (left: left, bottom: bottom);
}

Future<String> _executeAIRequest(
  GenerateAITextInteractor interactor,
  AIAction action,
  String content,
) async {
  final result = await interactor.execute(action, content);

  return result.fold(
    (failure) {
      throw Exception('Failed to generate AI response: $failure');
    },
    (success) {
      if (success is GenerateAITextSuccess) {
        return success.response.result;
      } else {
        throw Exception('Unexpected success state: $success');
      }
    },
  );
}