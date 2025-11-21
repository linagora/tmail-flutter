import 'package:tmail_ui_user/features/ai/domain/model/ai_response.dart';

abstract class AIScribeRepository {
  Future<AIResponse> generateText(String prompt);
}
