
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';

abstract class CleanupDataSource {
  Future<bool> cleanEmailCache(CleanupRule cleanupRule);

  Future<void> saveTimeCleanEmail(DateTime lastTime);

  Future<DateTime?> getTimeCleanEmail();
}