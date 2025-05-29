import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/local_setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/local_setting_options_extensions.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ThreadDetailLocalDataSourceImpl implements ThreadDetailDataSource {
  const ThreadDetailLocalDataSourceImpl(
    this._localSettingCacheManager,
    this._exceptionThrower,
  );

  final LocalSettingCacheManager _localSettingCacheManager;
  final ExceptionThrower _exceptionThrower;

  @override
  Future<List<EmailId>> getThreadById(ThreadId threadId, AccountId accountId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> getEmailsByIds(Session session, AccountId accountId, List<EmailId> emailIds, {Properties? properties}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> getThreadDetailStatus() {
    return Future.sync(() async {
      final localSetting = await _localSettingCacheManager.get();
      return localSetting.threadDetailEnabled ?? false;
    }).catchError(_exceptionThrower.throwException);
  }
}