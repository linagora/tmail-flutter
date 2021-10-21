
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/data/utils/cleanup_constant.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';

class CleanupDataSourceImpl extends CleanupDataSource {

  final EmailCacheManager emailCacheManager;
  final SharedPreferences sharedPreferences;

  CleanupDataSourceImpl(this.emailCacheManager, this.sharedPreferences);

  @override
  Future<bool> cleanEmailCache(CleanupRule cleanupRule) {
    return Future.sync(() async {
      return await emailCacheManager.clean(cleanupRule);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> saveTimeCleanEmail(DateTime lastTime) {
    return Future.sync(() async {
      await sharedPreferences.setString(CleanupConstant.keyTimeCleanupEmail, lastTime.toIso8601String());
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<DateTime?> getTimeCleanEmail() {
    return Future.sync(() async {
      final lastTime = sharedPreferences.getString(CleanupConstant.keyTimeCleanupEmail);
      return DateTime.tryParse(lastTime ?? '');
    }).catchError((error) {
      throw error;
    });
  }
}