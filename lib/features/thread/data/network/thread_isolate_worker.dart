import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/thread/data/model/empty_mailbox_folder_arguments.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/main/exceptions/isolate_exception.dart';
import 'package:worker_manager/worker_manager.dart';

class ThreadIsolateWorker {
  final ThreadAPI _threadAPI;
  final EmailAPI _emailAPI;
  final Executor _isolateExecutor;

  ThreadIsolateWorker(this._threadAPI, this._emailAPI, this._isolateExecutor);

  Future<bool> emptyMailboxFolder(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
  ) async {
    if (PlatformInfo.isWeb) {
      return _emptyMailboxFolderOnWeb(session, accountId, mailboxId);
    } else {
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        throw CanNotGetRootIsolateToken();
      }

      final result = await _isolateExecutor.execute(
        arg1: EmptyMailboxFolderArguments(
          session,
          _threadAPI,
          _emailAPI,
          accountId,
          mailboxId,
          rootIsolateToken
        ),
        fun1: _emptyMailboxFolderAction
      );

      return result;
    }
  }

  static Future<bool> _emptyMailboxFolderAction(
    EmptyMailboxFolderArguments args,
    TypeSendPort sendPort
  ) async {
    try {
      final rootIsolateToken = args.isolateToken;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      await HiveCacheConfig.instance.setUp();

      bool batchResult = true;
      var hasEmails = true;

      while (hasEmails) {
        final emptyMailboxResponse = await args.threadAPI.deleteEmailsBaseOnQuery(
          args.session,
          args.accountId,
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: EmailFilterCondition(inMailbox: args.mailboxId),
        );
        batchResult = !batchResult ? batchResult : emptyMailboxResponse.isSuccess;
        hasEmails = emptyMailboxResponse.deletedCount > 0;
      }
      return batchResult;
    } catch (e) {
      logError('ThreadIsolateWorker::_emptyMailboxFolderAction(): ERROR: $e');
      rethrow;
    }
  }

  Future<bool> _emptyMailboxFolderOnWeb(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
  ) async {
    bool batchResult = true;
    try {
      var hasEmails = true;

      while (hasEmails) {
        final emptyMailboxResponse = await _threadAPI.deleteEmailsBaseOnQuery(
          session, 
          accountId,
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: EmailFilterCondition(inMailbox: mailboxId),
        );
        batchResult = !batchResult ? batchResult : emptyMailboxResponse.isSuccess;
        hasEmails = emptyMailboxResponse.deletedCount > 0;
      }
    } catch (e) {
      batchResult = false;
      log('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): ERROR: $e');
    }
    return batchResult;
  }
}
