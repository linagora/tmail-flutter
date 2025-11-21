import 'package:tmail_ui_user/features/ai/domain/model/ai_response.dart';

abstract class AIDataSource {
  Future<AIResponse> request(String prompt);
}
