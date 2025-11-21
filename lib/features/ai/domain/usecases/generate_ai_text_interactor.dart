import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/ai/domain/constants/ai_prompts.dart';
import 'package:tmail_ui_user/features/ai/domain/repository/ai_scribe_repository.dart';
import 'package:tmail_ui_user/features/ai/domain/state/generate_ai_text_state.dart';
import 'package:tmail_ui_user/features/ai/presentation/model/ai_scribe_menu_action.dart';

class GenerateAITextInteractor {
  final AIScribeRepository _repository;

  GenerateAITextInteractor(this._repository);

  Future<Either<Failure, Success>> execute(
    AIScribeMenuAction action,
    String selectedText,
  ) async {
    try {
      final prompt = AIPrompts.buildPrompt(action, selectedText);

      final response = await _repository.generateText(prompt);

      return Right(GenerateAITextSuccess(response));
    } catch (e) {
      return Left(GenerateAITextFailure(e));
    }
  }
}
