import 'package:scribe/scribe/ai/data/datasource/ai_datasource.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/ai_response.dart';
import 'package:scribe/scribe/ai/domain/repository/ai_scribe_repository.dart';

class AIScribeRepositoryImpl implements AIScribeRepository {
  final AIDataSource _aiDataSource;

  AIScribeRepositoryImpl(this._aiDataSource);

  @override
  Future<AIResponse> generateMessage(List<AIMessage> messages) {
    return _aiDataSource.generateMessage(messages);
  }
}
