
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';

class CleanupRepositoryImpl extends CleanupRepository {

  final CleanupDataSource cleanupDataSource;

  CleanupRepositoryImpl(this.cleanupDataSource);

  @override
  Future<void> cleanEmailCache(CleanupRule cleanupRule) async {
    final isSuccess = await cleanupDataSource.cleanEmailCache(cleanupRule);
    if (isSuccess) {
      await cleanupDataSource.saveTimeCleanEmail(DateTime.now());
    }
  }
}