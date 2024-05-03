import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
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
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/thread/data/model/empty_mailbox_folder_arguments.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/exceptions/thread_exceptions.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';
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
    final rootIsolateToken = args.isolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await HiveCacheConfig.instance.setUp();

    List<EmailId> emailListCompleted = List.empty(growable: true);
    try {
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
          properties: Properties({EmailProperty.id}));

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
          emailListCompleted.addAll(listEmailIdDeleted);
        } else {
          hasEmails = false;
        }
      }
    } catch (e) {
      logError('ThreadIsolateWorker::_emptyMailboxFolderAction(): ERROR: $e');
    }
    log('ThreadIsolateWorker::_emptyMailboxFolderAction(): TOTAL_REMOVE: ${emailListCompleted.length}');
    return emailListCompleted;
  }

  Future<List<EmailId>> _emptyMailboxFolderOnWeb(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
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
          properties: Properties({EmailProperty.id})
        ).then((response) => _removeDuplicatedLatestEmailFromEmailResponse(
          emailsResponse: response,
          latestEmailId: lastEmail?.id
        ));
        final newEmailList = emailsResponse.emailList ?? <Email>[];
        log('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): ${newEmailList.length}');
        if (newEmailList.isNotEmpty) {
          lastEmail = newEmailList.last;
          hasEmails = true;
          final listEmailIdDeleted = await _emailAPI.deleteMultipleEmailsPermanently(
            session,
            accountId,
            newEmailList.listEmailIds);
          emailListCompleted.addAll(listEmailIdDeleted);
        } else {
          hasEmails = false;
        }
      }
    } catch (e) {
      logError('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): ERROR: $e');
    }
    log('ThreadIsolateWorker::_emptyMailboxFolderOnWeb(): TOTAL_REMOVE: ${emailListCompleted.length}');
    return emailListCompleted;
  }

  Future<List<EmailId>> markAllAsUnreadForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailRead,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) async {
    List<EmailId> emailIdListCompleted = List.empty(growable: true);
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
            before: lastReceivedDate
          ),
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(false)
          ),
          properties: Properties({
            EmailProperty.id,
            EmailProperty.receivedAt,
          })
        ).then((response) => _removeDuplicatedLatestEmailFromEmailResponse(
          emailsResponse: response,
          latestEmailId: lastEmailId
        ));
        final listEmailRead = emailResponse.emailList;
        log('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails: LIST_EMAIL_READ = ${listEmailRead?.length}');
        if (listEmailRead == null || listEmailRead.isEmpty) {
          mailboxHasEmails = false;
        } else {
          lastEmailId = listEmailRead.last.id;
          lastReceivedDate = listEmailRead.last.receivedAt;

          final listEmailId = await _emailAPI.markAsRead(
            session,
            accountId,
            listEmailRead,
            ReadActions.markAsUnread
          );
          log('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails(): MARK_UNREAD: ${listEmailId.length}');
          emailIdListCompleted.addAll(listEmailId);
          onProgressController.add(
            dartz.Right(MarkAllAsUnreadSelectionAllEmailsUpdating(
              totalRead: totalEmailRead,
              countUnread: emailIdListCompleted.length
            ))
          );
        }
      }
    } catch (e) {
      logError('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails(): ERROR: $e');
    }
    log('ThreadIsolateWorker::markAllAsUnreadForSelectionAllEmails(): TOTAL_UNREAD: ${emailIdListCompleted.length}');
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
    List<EmailId> emailIdListCompleted = List.empty(growable: true);
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
            inMailbox: currentMailboxId,
            before: lastReceivedDate
          ),
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(false)
          ),
          properties: Properties({
            EmailProperty.id,
            EmailProperty.receivedAt,
          })
        ).then((response) => _removeDuplicatedLatestEmailFromEmailResponse(
          emailsResponse: response,
          latestEmailId: lastEmailId
        ));
        final listEmail = emailResponse.emailList;
        log('ThreadIsolateWorker::moveAllSelectionAllEmails: LIST_EMAIL = ${listEmail?.length}');
        if (listEmail == null || listEmail.isEmpty) {
          mailboxHasEmails = false;
        } else {
          lastEmailId = listEmail.last.id;
          lastReceivedDate = listEmail.last.receivedAt;

          final listEmailId = await _emailAPI.moveSelectionAllEmailsToFolder(
            session,
            accountId,
            currentMailboxId,
            destinationMailboxId,
            listEmail.listEmailIds,
            isDestinationSpamMailbox: isDestinationSpamMailbox
          );
          log('ThreadIsolateWorker::moveAllSelectionAllEmails(): MOVED: ${listEmailId.length}');
          emailIdListCompleted.addAll(listEmailId);
          onProgressController.add(
            dartz.Right(MoveAllSelectionAllEmailsUpdating(
              total: totalEmails,
              countMoved: emailIdListCompleted.length
            ))
          );
        }
      }
    } catch (e) {
      logError('ThreadIsolateWorker::moveAllSelectionAllEmails(): ERROR: $e');
    }
    log('ThreadIsolateWorker::moveAllSelectionAllEmails(): TOTAL_MOVED: ${emailIdListCompleted.length}');
    return emailIdListCompleted;
  }

  Future<List<EmailId>> deleteAllPermanentlyEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  ) async {
    List<EmailId> emailIdListCompleted = List.empty(growable: true);
    try {
      bool mailboxHasEmails = true;

      while (mailboxHasEmails) {
        final listResult = await _threadAPI.deleteAllPermanentlyEmails(
          session,
          accountId,
          mailboxId
        );

        if (listResult.value1.isNotEmpty) {
          mailboxHasEmails = true;
        } else {
          mailboxHasEmails = false;
        }

        if (listResult.value2.isNotEmpty) {
          emailIdListCompleted.addAll(listResult.value2);

          onProgressController.add(
            dartz.Right(MoveAllSelectionAllEmailsUpdating(
              total: totalEmails,
              countMoved: emailIdListCompleted.length
            ))
          );
        }
      }
    } catch (e) {
      logError('ThreadIsolateWorker::deleteAllPermanentlyEmails(): ERROR: $e');
    }
    log('ThreadIsolateWorker::deleteAllPermanentlyEmails(): TOTAL_DELETED_PERMANENTLY: ${emailIdListCompleted.length}');
    return emailIdListCompleted;
  }

  Future<List<EmailId>> markAllAsStarredForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) async {
    List<EmailId> emailIdListCompleted = List.empty(growable: true);
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
            notKeyword: KeyWordIdentifier.emailFlagged.value,
            before: lastReceivedDate
          ),
          sort: <Comparator>{}..add(
            EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(false)
          ),
          properties: Properties({
            EmailProperty.id,
            EmailProperty.receivedAt,
          })
        ).then((response) => _removeDuplicatedLatestEmailFromEmailResponse(
          emailsResponse: response,
          latestEmailId: lastEmailId
        ));
        final listEmails = emailResponse.emailList;

        if (listEmails == null || listEmails.isEmpty) {
          mailboxHasEmails = false;
        } else {
          lastEmailId = listEmails.last.id;
          lastReceivedDate = listEmails.last.receivedAt;

          final listResult = await _emailAPI.markAsStar(
            session,
            accountId,
            listEmails,
            MarkStarAction.markStar
          );

          emailIdListCompleted.addAll(listResult.listEmailIds);
          onProgressController.add(
            dartz.Right(MarkAllAsStarredSelectionAllEmailsUpdating(
              total: totalEmails,
              countStarred: emailIdListCompleted.length
            ))
          );
        }
      }
    } catch (e) {
      logError('ThreadIsolateWorker::markAllAsStarredForSelectionAllEmails(): ERROR: $e');
    }
    return emailIdListCompleted;
  }

  EmailsResponse _removeDuplicatedLatestEmailFromEmailResponse({
    required EmailsResponse emailsResponse,
    EmailId? latestEmailId,
  }) {
    List<Email> listEmails = emailsResponse.emailList ?? [];
    if (listEmails.isNotEmpty && latestEmailId != null) {
      listEmails = listEmails
        .where((email) => email.id != latestEmailId)
        .toList();

      return EmailsResponse(emailList: listEmails, state: emailsResponse.state);
    } else {
      return emailsResponse;
    }
  }
}
