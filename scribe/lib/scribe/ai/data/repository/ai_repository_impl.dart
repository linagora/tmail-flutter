import '../datasource/ai_datasource.dart';
import '../../domain/model/ai_response.dart';
import '../../domain/repository/ai_scribe_repository.dart';

class AIScribeRepositoryImpl implements AIScribeRepository {
  final AIDataSource _dataSource;

  AIScribeRepositoryImpl(this._dataSource);

  @override
  Future<AIResponse> generateText(String prompt) async {
    return await _dataSource.request(prompt);
  }
}
