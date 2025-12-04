import '../../domain/model/ai_response.dart';

abstract class AIDataSource {
  Future<AIResponse> request(String prompt);
}
