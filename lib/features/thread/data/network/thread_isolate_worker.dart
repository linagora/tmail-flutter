import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart' as dartz;
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
import 'package:tmail_ui_user/features/thread/data/model/empty_mailbox_folder_arguments.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/exceptions/thread_exceptions.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';
import 'package:tmail_ui_user/main/exceptions/isolate_exception.dart';
import 'package:worker_manager/worker_manager.dart';

class ThreadIsolateWorker {
  final ThreadAPI _threadAPI;
  final EmailAPI _emailAPI;
  final Executor _isolateExecutor;

  ThreadIsolateWorker(this._threadAPI, this._emailAPI, this._isolateExecutor);

  Future<List<EmailId>> emptyMailboxFolder(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) async {
    if (PlatformInfo.isWeb) {
      return _emptyMailboxFolderOnWeb(session, accountId, mailboxId, totalEmails, onProgressController);
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
        fun1: _emptyMailboxFolderAction,
        notification: (value) {
          if (value is List<EmailId>) {
            log('ThreadIsolateWorker::emptyMailboxFolder(): processed ${value.length} - totalEmails $totalEmails');
            onProgressController.add(Right<Failure, Success>(EmptyingFolderState(
              mailboxId, value.length, totalEmails
            )));
          }
        },
      );

      if (result.isEmpty) {
        throw NotFoundEmailsDeletedException();
      } else {
        return result;
      }
    }
  }

  static Future<List<EmailId>> _emptyMailboxFolderAction(
    EmptyMailboxFolderArguments args,
    TypeSendPort sendPort
  ) async {
    try {
      final rootIsolateToken = args.isolateToken;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      await HiveCacheConfig.instance.setUp();

      List<EmailId> emailListCompleted = List.empty(growable: true);

      var hasEmails = true;
      Email? lastEmail;

      while (hasEmails) {
        final emailsResponse = await args.threadAPI.getAllEmail(
          args.session,
          args.accountId,
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: EmailFilterCondition(inMailbox: args.mailboxId, before: lastEmail?.receivedAt),
          properties: Properties({
            EmailProperty.id,
            EmailProperty.receivedAt
          }),
        );

        var newEmailList = emailsResponse.emailList ?? <Email>[];
        if (lastEmail != null) {
          newEmailList = newEmailList.where((email) => email.id != lastEmail!.id).toList();
        }

        log('ThreadIsolateWorker::_emptyMailboxFolderAction(): ${newEmailList.length}');

        if (newEmailList.isNotEmpty) {
          lastEmail = newEmailList.last;
          hasEmails = true;
          final listEmailIdDeleted = await args.emailAPI.deleteMultipleEmailsPermanently(
            args.session,
            args.accountId,
            newEmailList.listEmailIds);
          emailListCompleted.addAll(listEmailIdDeleted.emailIdsSuccess);
          sendPort.send(emailListCompleted);
        } else {
          hasEmails = false;
        }
      }
      log('ThreadIsolateWorker::_emptyMailboxFolderAction(): TOTAL_REMOVE: ${emailListCompleted.length}');
      return emailListCompleted;
    } catch (e) {
      logError('ThreadIsolateWorker::_emptyMailboxFolderAction(): ERROR: $e');
      rethrow;
    }
  }

  Future<List<EmailId>> _emptyMailboxFolderOnWeb(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) async {
    List<EmailId> emailListCompleted = List.empty(growable: true);
    try {
      var hasEmails = true;
      Email? lastEmail;

      while (hasEmails) {
        final emailsResponse = await _threadAPI.getAllEmail(
          session,
          accountId,
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: EmailFilterCondition(inMailbox: mailboxId, before: lastEmail?.receivedAt),
          properties: Properties({
            EmailProperty.id,
            EmailProperty.receivedAt
          }),
        );

        var newEmailList = emailsResponse.emailList ?? <Email>[];
        if (lastEmail != null) {
          newEmailList = newEmailList.where((email) => email.id != lastEmail!.id).toList();
        }

        log('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): ${newEmailList.length}');

        if (newEmailList.isNotEmpty) {
          lastEmail = newEmailList.last;
          hasEmails = true;
          final listEmailIdDeleted = await _emailAPI.deleteMultipleEmailsPermanently(
            session,
            accountId,
            newEmailList.listEmailIds);
          emailListCompleted.addAll(listEmailIdDeleted.emailIdsSuccess);

          onProgressController.add(Right<Failure, Success>(EmptyingFolderState(
            mailboxId, emailListCompleted.length, totalEmails
          )));
        } else {
          hasEmails = false;
        }
      }
    } catch (e) {
      log('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): ERROR: $e');
    }
    log('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): TOTAL_REMOVE: ${emailListCompleted.length}');
    return emailListCompleted;
  }

  Future<List<EmailId>> markAllAsUnreadForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailRead,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  ) async {
    List<EmailId> emailIdListCompleted = [];

    try {
      bool mailboxHasEmails = true;
      UTCDate? lastReceivedDate;
      EmailId? lastEmailId;

      while (mailboxHasEmails) {
        final emailResponse = await _threadAPI.getAllEmail(
          session,
          accountId,
          limit: UnsignedInt(30),
          filter: EmailFilterCondition(
            inMailbox: mailboxId,
            hasKeyword: KeyWordIdentifier.emailSeen.value,
            before: lastReceivedDate,
          ),
          sort: <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(false)),
          properties: Properties({EmailProperty.id, EmailProperty.receivedAt}),
        );

        final listEmailRead = emailResponse.emailList;

        if (listEmailRead == null || listEmailRead.isEmpty) {
          mailboxHasEmails = false;
          break;
        }

        if (lastEmailId != null) {
          listEmailRead.removeWhere((email) => email.id == lastEmailId);
        }

        lastEmailId = listEmailRead.last.id;
        lastReceivedDate = listEmailRead.last.receivedAt;

        final result = await _emailAPI.markAsRead(
          session,
          accountId,
          listEmailRead.listEmailIds,
          ReadActions.markAsUnread,
        );

        log('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails():MARK_UNREAD: ${result.emailIdsSuccess.length}');
        emailIdListCompleted.addAll(result.emailIdsSuccess);

        onProgressController.add(
          dartz.Right(MarkAllAsUnreadSelectionAllEmailsUpdating(
            mailboxId: mailboxId,
            totalRead: totalEmailRead,
            countUnread: emailIdListCompleted.length,
          )),
        );
      }
    } catch (e) {
      logError('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails():ERROR: $e');
    }
    log('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails():TOTAL_UNREAD: ${emailIdListCompleted.length}');
    return emailIdListCompleted;
  }

  Future<List<EmailId>> moveAllSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId currentMailboxId,
    MailboxId destinationMailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
    {
      bool isDestinationSpamMailbox = false
    }
  ) async {
    List<EmailId> emailIdListCompleted = [];

    try {
      bool hasMoreEmails = true;
      UTCDate? lastReceivedDate;
      EmailId? lastEmailId;

      while (hasMoreEmails) {
        final emailResponse = await _threadAPI.getAllEmail(
          session,
          accountId,
          limit: UnsignedInt(30),
          filter: EmailFilterCondition(
            inMailbox: currentMailboxId,
            before: lastReceivedDate,
          ),
          sort: {EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(false)},
          properties: Properties({
            EmailProperty.id,
            EmailProperty.receivedAt,
          }),
        );

        List<Email> listEmails = emailResponse.emailList ?? [];

        if (lastEmailId != null) {
          listEmails.removeWhere((email) => email.id == lastEmailId);
        }

        log('ThreadIsolateWorker::moveAllSelectionAllEmails: LIST_EMAIL = ${listEmails.length}');

        if (listEmails.isEmpty) {
          hasMoreEmails = false;
          break;
        }

        lastEmailId = listEmails.last.id;
        lastReceivedDate = listEmails.last.receivedAt;

        final movedEmailIds = await _emailAPI.moveSelectionAllEmailsToFolder(
          session,
          accountId,
          currentMailboxId,
          destinationMailboxId,
          listEmails.listEmailIds,
          isDestinationSpamMailbox: isDestinationSpamMailbox,
        );

        log('ThreadIsolateWorker::moveAllSelectionAllEmails(): MOVED: ${movedEmailIds.length}');
        emailIdListCompleted.addAll(movedEmailIds);

        onProgressController.add(
          dartz.Right(MoveAllSelectionAllEmailsUpdating(
            total: totalEmails,
            countMoved: emailIdListCompleted.length,
          )),
        );
      }
    } catch (e) {
      log('ThreadIsolateWorker::moveAllSelectionAllEmails(): ERROR: $e');
    }

    log('ThreadIsolateWorker::moveAllSelectionAllEmails(): TOTAL_MOVED: ${emailIdListCompleted.length}');
    return emailIdListCompleted;
  }
}
