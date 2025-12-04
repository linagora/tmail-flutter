import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../data/datasource_impl/ai_datasource_impl.dart';
import '../../data/repository/ai_repository_impl.dart';
import '../../domain/state/generate_ai_text_state.dart';
import '../../domain/usecases/generate_ai_text_interactor.dart';
import '../model/ai_action.dart';
import '../model/ai_scribe_menu_action.dart';
import 'ai_scribe_bar.dart';
import 'ai_scribe_menu.dart';
import 'ai_scribe_suggestion.dart';

typedef AIScribeResultCallback = void Function(String result);

Future<void> showAIScribeDialog({
  required BuildContext context,
  required ImagePaths imagePaths,
  required String content,
  required AIScribeResultCallback onInsertText,
  List<AIScribeMenuCategory>? availableCategories,
  Offset? buttonPosition,
}) async {
  final hasContent = content.isNotEmpty;

  final selectedAction = await showDialog<AIAction>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      const menuWidth = 240.0;
      const barWidth = menuWidth * 2;

      final dialogContent = PointerInterceptor(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasContent) ...[
              Material(
                color: Colors.white,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: menuWidth,
                  child: AIScribeMenu(
                    onActionSelected: (action) {
                      Navigator.of(context).pop(PredefinedAction(action));
                    },
                    availableCategories: availableCategories,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Material(
              color: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: barWidth,
                child: AIScribeBar(
                  onCustomPrompt: (customPrompt) {
                    Navigator.of(context).pop(CustomPromptAction(customPrompt));
                  },
                ),
              ),
            ),
          ],
        ),
      );

      if (buttonPosition != null) {
        // Get screen size to ensure dialog stays within bounds
        final screenSize = MediaQuery.of(context).size;
        const dialogWidth = barWidth;

        // Calculate position 10px above the button
        double left = buttonPosition.dx;
        double bottom = screenSize.height - buttonPosition.dy + 10;

        // Ensure dialog doesn't go off screen horizontally
        if (left + dialogWidth > screenSize.width) {
          left = screenSize.width - dialogWidth - 16;
        }
        if (left < 16) {
          left = 16;
        }

        return Stack(
          children: [
            Positioned(
              left: left,
              bottom: bottom,
              child: dialogContent,
            ),
          ],
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
      final suggestionFuture = _executeAIRequest(selectedAction, content);
      final title = selectedAction.label;

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
        // Get screen size to ensure modal stays within bounds
        final screenSize = MediaQuery.of(context).size;
        // Use responsive width: 90% on mobile, max 500px on larger screens
        final modalWidth = screenSize.width < 600 ? screenSize.width * 0.9 : 500.0;
        const modalHeight = 400.0;

        // Calculate position 10px above the button
        double left = buttonPosition.dx;
        double bottom = screenSize.height - buttonPosition.dy + 10;

        // Ensure modal doesn't go off screen horizontally
        if (left + modalWidth > screenSize.width) {
          left = screenSize.width - modalWidth - 16;
        }
        if (left < 16) {
          left = 16;
        }

        // Ensure modal doesn't go off screen vertically
        if (bottom + modalHeight > screenSize.height) {
          bottom = screenSize.height - modalHeight - 16;
        }
        if (bottom < 16) {
          bottom = 16;
        }

        return Stack(
          children: [
            Positioned(
              left: left,
              bottom: bottom,
              child: modalContent,
            ),
          ],
        );
      }

      return Center(child: modalContent);
    },
  );
}

Future<String> _executeAIRequest(
  AIAction action,
  String content,
) async {
  final dio = Dio();
  final dataSource = AIDataSourceImpl(dio: dio);
  final repository = AIScribeRepositoryImpl(dataSource);
  final interactor = GenerateAITextInteractor(repository);

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