import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_mark_as_read_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/main/exceptions/isolate_exception.dart';
import 'package:worker_manager/worker_manager.dart';

class MailboxIsolateWorker {

  final ThreadAPI _threadApi;
  final EmailAPI _emailApi;
  final Executor _isolateExecutor;

  MailboxIsolateWorker(this._threadApi, this._emailApi, this._isolateExecutor);

  Future<List<EmailId>> markAsMailboxRead(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<Either<Failure, Success>> onProgressController
  ) async {
    if (PlatformInfo.isWeb) {
      return _handleMarkAsMailboxReadActionOnWeb(
        session,
        accountId,
        mailboxId,
        totalEmailUnread,
        onProgressController);
    } else {
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        throw CanNotGetRootIsolateToken();
      }

      final result = await _isolateExecutor.execute(
          arg1: MailboxMarkAsReadArguments(
            session,
            _threadApi,
            _emailApi,
            accountId,
            mailboxId,
            rootIsolateToken
          ),
          fun1: _handleMarkAsMailboxReadAction,
          notification: (value) {
            if (value is List<EmailId>) {
              log('MailboxIsolateWorker::markAsMailboxRead(): onUpdateProgress: PERCENT ${value.length / totalEmailUnread}');
              onProgressController.add(Right(UpdatingMarkAsMailboxReadState(
                mailboxId: mailboxId,
                totalUnread: totalEmailUnread,
                countRead: value.length)));
            }
          });
      return result;
    }
  }

  static Future<List<EmailId>> _handleMarkAsMailboxReadAction(
      MailboxMarkAsReadArguments args,
      TypeSendPort sendPort
  ) async {
    final rootIsolateToken = args.isolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await HiveCacheConfig.instance.setUp();

    List<EmailId> emailIdsCompleted = List.empty(growable: true);
    try {
      bool mailboxHasEmails = true;
      UTCDate? lastReceivedDate;
      EmailId? lastEmailId;

      while (mailboxHasEmails) {
        final emailResponse = await args.threadAPI
            .getAllEmail(
              args.session,
              args.accountId,
              limit: UnsignedInt(30),
              filter: EmailFilterCondition(
                    inMailbox: args.mailboxId,
                    notKeyword: KeyWordIdentifier.emailSeen.value,
                    before: lastReceivedDate),
              sort: <Comparator>{}..add(
                EmailComparator(EmailComparatorProperty.receivedAt)
                  ..setIsAscending(false)),
              properties: Properties({
                  EmailProperty.id,
                  EmailProperty.keywords,
                  EmailProperty.receivedAt,
                }))
            .then((response) {
              var listEmails = response.emailList;
              if (listEmails != null && listEmails.isNotEmpty && lastEmailId != null) {
                listEmails = listEmails
                  .where((email) => email.id != lastEmailId)
                  .toList();
              }
              return EmailsResponse(emailList: listEmails, state: response.state);
            });
        final listEmailUnread = emailResponse.emailList;

        log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): listEmailUnread: ${listEmailUnread?.length}');

        if (listEmailUnread == null || listEmailUnread.isEmpty) {
          mailboxHasEmails = false;
        } else {
          lastEmailId = listEmailUnread.last.id;
          lastReceivedDate = listEmailUnread.last.receivedAt;

          final result = await args.emailAPI.markAsRead(
            args.session,
            args.accountId,
            listEmailUnread.listEmailIds,
            ReadActions.markAsRead);

          log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): MARK_READ: ${result.length}');
          emailIdsCompleted.addAll(result);
          sendPort.send(emailIdsCompleted);
        }
      }
    } catch (e) {
      log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): ERROR: $e');
    }
    log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): TOTAL_READ: ${emailIdsCompleted.length}');
    return emailIdsCompleted;
  }

  Future<List<EmailId>> _handleMarkAsMailboxReadActionOnWeb(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<Either<Failure, Success>> onProgressController
  ) async {
    List<EmailId> emailIdsCompleted = List.empty(growable: true);
    try {
      bool mailboxHasEmails = true;
      UTCDate? lastReceivedDate;
      EmailId? lastEmailId;

      while (mailboxHasEmails) {
        final emailResponse = await _threadApi
            .getAllEmail(
              session,
              accountId,
              limit: UnsignedInt(30),
              filter: EmailFilterCondition(
                inMailbox: mailboxId,
                notKeyword: KeyWordIdentifier.emailSeen.value,
                before: lastReceivedDate),
              sort: <Comparator>{}..add(
                    EmailComparator(EmailComparatorProperty.receivedAt)
                      ..setIsAscending(false)),
              properties: Properties({
                  EmailProperty.id,
                  EmailProperty.keywords,
                  EmailProperty.receivedAt,
              })
            ).then((response) {
              var listEmails = response.emailList;
              if (listEmails != null && listEmails.isNotEmpty && lastEmailId != null) {
                listEmails = listEmails
                  .where((email) => email.id != lastEmailId)
                  .toList();
            }
              return EmailsResponse(emailList: listEmails, state: response.state);
            });
        final listEmailUnread = emailResponse.emailList;

        log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): listEmailUnread: ${listEmailUnread?.length}');

        if (listEmailUnread == null || listEmailUnread.isEmpty) {
          mailboxHasEmails = false;
        } else {
          lastEmailId = listEmailUnread.last.id;
          lastReceivedDate = listEmailUnread.last.receivedAt;

          final result = await _emailApi.markAsRead(
            session,
            accountId,
            listEmailUnread.listEmailIds,
            ReadActions.markAsRead,
          );
          log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): MARK_READ: ${result.length}');
          emailIdsCompleted.addAll(result);

          onProgressController.add(Right(UpdatingMarkAsMailboxReadState(
              mailboxId: mailboxId,
              totalUnread: totalEmailUnread,
              countRead: emailIdsCompleted.length)));
        }
      }
    } catch (e) {
      log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): ERROR: $e');
    }
    log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): TOTAL_READ: ${emailIdsCompleted.length}');
    return emailIdsCompleted;
  }
}
