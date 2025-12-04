import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../constants/ai_prompts.dart';
import '../repository/ai_scribe_repository.dart';
import '../state/generate_ai_text_state.dart';
import '../../presentation/model/ai_action.dart';

class GenerateAITextInteractor {
  final AIScribeRepository _repository;

  GenerateAITextInteractor(this._repository);

  Future<Either<Failure, Success>> execute(
    AIAction action,
    String? selectedText,
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
