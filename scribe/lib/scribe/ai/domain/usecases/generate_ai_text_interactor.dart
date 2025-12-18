import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:scribe/scribe/ai/domain/constants/ai_prompts.dart';
import 'package:scribe/scribe/ai/domain/repository/ai_scribe_repository.dart';
import 'package:scribe/scribe/ai/domain/state/generate_ai_text_state.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';

class GenerateAITextInteractor {
  final AIScribeRepository _repository;

  GenerateAITextInteractor(this._repository);

  Future<Either<Failure, Success>> execute(
    AIAction action,
    String? selectedText,
  ) async {
    try {
      final prompt = AIPrompts.buildPrompt(action, selectedText);
      final response = await _repository.generateMessage(prompt);
      return Right(GenerateAITextSuccess(response));
    } catch (e) {
      return Left(GenerateAITextFailure(e));
    }
  }
}
