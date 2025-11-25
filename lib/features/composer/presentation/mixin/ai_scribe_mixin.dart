import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/ai/data/datasource_impl/ai_datasource_impl.dart';
import 'package:tmail_ui_user/features/ai/data/repository/ai_repository_impl.dart';
import 'package:tmail_ui_user/features/ai/domain/state/generate_ai_text_state.dart';
import 'package:tmail_ui_user/features/ai/domain/usecases/generate_ai_text_interactor.dart';
import 'package:tmail_ui_user/features/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';

mixin AIScribeMixin {
  final selectedText = Rxn<String>();
  final aiScribeSuggestion = Rxn<String>();

  RichTextMobileTabletController? get richTextMobileTabletController;
  RichTextWebController? get richTextWebController;

  GenerateAITextInteractor _createSelectionAIInteractor() {
    final dio = Dio();
    final dataSource = AIDataSourceImpl(dio: dio);
    final repository = AIScribeRepositoryImpl(dataSource);
    return GenerateAITextInteractor(repository);
  }

  void handleTextSelection(String? text) {
    selectedText.value = text;
  }

  void handleAIScribeActionClick(AIScribeMenuAction action) async {
    final selection = selectedText.value;
    if (selection != null && selection.isNotEmpty) {
      try {
        final interactor = _createSelectionAIInteractor();
        final result = await interactor.execute(action, selection);

        result.fold(
          (failure) {
            log('AIScribeMixin::handleAIScribeActionClick: Error = $failure');
          },
          (success) {
            if (success is GenerateAITextSuccess) {
              log('AIScribeMixin::handleAIScribeActionClick: AI response = ${success.response.result}');
              aiScribeSuggestion.value = success.response.result;
            }
          },
        );
      } catch (e) {
        log('AIScribeMixin::handleAIScribeActionClick: Error = $e');
      }
    }
  }

  void insertAIScribeSuggestion() {
    final value = aiScribeSuggestion.value;
    if (value != null && value.isNotEmpty) {
      final htmlContent = value.replaceAll('\n', '<br>');

      if (PlatformInfo.isWeb) {
        richTextWebController?.editorController.insertHtml(htmlContent);
      } else {
        richTextMobileTabletController?.htmlEditorApi?.insertHtml(htmlContent);
      }
    }

    closeAIScribeSuggestionModal();
  }

  void closeAIScribeSuggestionModal() {
    aiScribeSuggestion.value = null;
  }
}
