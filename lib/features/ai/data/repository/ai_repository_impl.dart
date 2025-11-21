import 'package:tmail_ui_user/features/ai/data/datasource/ai_datasource.dart';
import 'package:tmail_ui_user/features/ai/domain/model/ai_response.dart';
import 'package:tmail_ui_user/features/ai/domain/repository/ai_scribe_repository.dart';

class AIScribeRepositoryImpl implements AIScribeRepository {
  final AIDataSource _dataSource;

  AIScribeRepositoryImpl(this._dataSource);

  @override
  Future<AIResponse> generateText(String prompt) async {
    return await _dataSource.request(prompt);
  }
}
