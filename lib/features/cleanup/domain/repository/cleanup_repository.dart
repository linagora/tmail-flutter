import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';

abstract class CleanupRepository {
  Future<void> cleanEmailCache(CleanupRule cleanupRule);
}
