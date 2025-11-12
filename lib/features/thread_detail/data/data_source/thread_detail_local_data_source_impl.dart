import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ThreadDetailLocalDataSourceImpl implements ThreadDetailDataSource {
  const ThreadDetailLocalDataSourceImpl(
    this._preferencesSettingManager,
    this._exceptionThrower,
  );

  final PreferencesSettingManager _preferencesSettingManager;
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
      final threadConfig = await _preferencesSettingManager.getThreadConfig();
      return threadConfig.isEnabled;
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}