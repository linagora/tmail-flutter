import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LocalSpamReportDataSourceImpl extends SpamReportDataSource {
  final PreferencesSettingManager _preferencesSettingManager;
  final ExceptionThrower _exceptionThrower;

  LocalSpamReportDataSourceImpl(
    this._preferencesSettingManager,
    this._exceptionThrower,
  );

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    return Future.sync(() async {
      final spamReportConfig = await _preferencesSettingManager.getSpamReportConfig();
      return DateTime.fromMillisecondsSinceEpoch(
        spamReportConfig.lastTimeDismissedMilliseconds,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> storeLastTimeDismissedSpamReported(
    DateTime lastTimeDismissedSpamReported,
  ) async {
    return Future.sync(() async {
      return await _preferencesSettingManager.updateSpamReport(
        lastTimeDismissedMilliseconds:
            lastTimeDismissedSpamReported.millisecondsSinceEpoch,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> deleteLastTimeDismissedSpamReported() {
    return Future.sync(() async {
      return await _preferencesSettingManager.updateSpamReport(
        lastTimeDismissedMilliseconds: 0,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<UnreadSpamEmailsResponse> findNumberOfUnreadSpamEmails(
    Session session,
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  ) {
    throw UnimplementedError();
  }

  @override
  Future<SpamReportState> getSpamReportState() {
    return Future.sync(() async {
      final spamReportConfig =
        await _preferencesSettingManager.getSpamReportConfig();
      return spamReportConfig.spamReportState;
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> storeSpamReportState(SpamReportState spamReportState) {
    return Future.sync(() async {
      return await _preferencesSettingManager.updateSpamReport(
        isEnabled: spamReportState == SpamReportState.enabled,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<Mailbox> getSpamMailboxCached(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }
}
