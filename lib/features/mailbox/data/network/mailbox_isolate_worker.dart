import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_mark_as_read_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:worker_manager/worker_manager.dart';

class MailboxIsolateWorker {

  final ThreadAPI _threadApi;
  final EmailAPI _emailApi;
  final Executor _isolateExecutor;

  MailboxIsolateWorker(this._threadApi, this._emailApi, this._isolateExecutor);

  Future<List<Email>> markAsMailboxRead(
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<Either<Failure, Success>> onProgressController
  ) async {
    if (BuildUtils.isWeb) {
      return _handleMarkAsMailboxReadActionOnWeb(
          accountId,
          mailboxId,
          totalEmailUnread,
          onProgressController);
    } else {
      final result = await _isolateExecutor.execute(
          arg1: MailboxMarkAsReadArguments(
              _threadApi,
              _emailApi,
              accountId,
              mailboxId),
          fun1: _handleMarkAsMailboxReadAction,
          notification: (value) {
            if (value is List<Email>) {
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

  static Future<List<Email>> _handleMarkAsMailboxReadAction(
      MailboxMarkAsReadArguments args,
      TypeSendPort sendPort
  ) async {
    List<Email> emailListCompleted = List.empty(growable: true);
    try {
      bool mailboxHasEmails = true;
      UTCDate? lastReceivedDate;
      EmailId? lastEmailId;

      while (mailboxHasEmails) {
        final emailResponse = await args.threadAPI
            .getAllEmail(args.accountId,
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
              args.accountId,
              listEmailUnread,
              ReadActions.markAsRead);

          log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): MARK_READ: ${result.length}');
          emailListCompleted.addAll(result);
          sendPort.send(emailListCompleted);
        }
      }
    } catch (e) {
      log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): ERROR: $e');
    }
    log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): TOTAL_READ: ${emailListCompleted.length}');
    return emailListCompleted;
  }

  Future<List<Email>> _handleMarkAsMailboxReadActionOnWeb(
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<Either<Failure, Success>> onProgressController
  ) async {
    List<Email> emailListCompleted = List.empty(growable: true);
    try {
      bool mailboxHasEmails = true;
      UTCDate? lastReceivedDate;
      EmailId? lastEmailId;

      while (mailboxHasEmails) {
        final emailResponse = await _threadApi
            .getAllEmail(accountId,
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

        log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): listEmailUnread: ${listEmailUnread?.length}');

        if (listEmailUnread == null || listEmailUnread.isEmpty) {
          mailboxHasEmails = false;
        } else {
          lastEmailId = listEmailUnread.last.id;
          lastReceivedDate = listEmailUnread.last.receivedAt;

          final result = await _emailApi.markAsRead(
              accountId, listEmailUnread, ReadActions.markAsRead);
          log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): MARK_READ: ${result.length}');
          emailListCompleted.addAll(result);

          onProgressController.add(Right(UpdatingMarkAsMailboxReadState(
              mailboxId: mailboxId,
              totalUnread: totalEmailUnread,
              countRead: emailListCompleted.length)));
        }
      }
    } catch (e) {
      log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): ERROR: $e');
    }
    log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnWeb(): TOTAL_READ: ${emailListCompleted.length}');
    return emailListCompleted;
  }
}
