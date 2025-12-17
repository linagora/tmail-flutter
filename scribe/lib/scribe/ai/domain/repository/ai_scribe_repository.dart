import 'package:scribe/scribe/ai/domain/model/ai_response.dart';

abstract class AIScribeRepository {
  Future<AIResponse> generateMessage(String prompt);
}
