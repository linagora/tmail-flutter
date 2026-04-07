import 'dart:async';
import 'dart:io';

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
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_mark_as_read_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/move_folder_content_isolate_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/main/exceptions/isolate_exception.dart';
import 'package:worker_manager/worker_manager.dart';

class MailboxIsolateWorker {

  final ThreadAPI _threadApi;
  final EmailAPI _emailApi;

  MailboxIsolateWorker(this._threadApi, this._emailApi);

  Future<List<EmailId>> markAsMailboxRead(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<Either<Failure, Success>> onProgressController
  ) async {
    if (PlatformInfo.isWeb || Platform.numberOfProcessors == 1) {
      return await _handleMarkAsMailboxReadActionOnMainIsolate(
        session,
        accountId,
        mailboxId,
        totalEmailUnread,
        onProgressController);
    } else {
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        throw const CanNotGetRootIsolateToken();
      }

      final args = MailboxMarkAsReadArguments(
        session,
        _threadApi,
        _emailApi,
        accountId,
        mailboxId,
        rootIsolateToken,
      );
      return await workerManager.executeWithPort<List<EmailId>, int>(
        _buildMarkAsReadClosure(args),
        onMessage: (countRead) {
          log('MailboxIsolateWorker::markAsMailboxRead(): onUpdateProgress: PERCENT ${countRead / totalEmailUnread}');
          onProgressController.add(Right(UpdatingMarkAsMailboxReadState(
            mailboxId: mailboxId,
            totalUnread: totalEmailUnread,
            countRead: countRead)));
        },
      );
    }
  }

  static Future<List<EmailId>> _handleMarkAsMailboxReadAction(
    MailboxMarkAsReadArguments args,
    SendPort sendPort,
  ) async {
    final rootIsolateToken = args.isolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await HiveCacheConfig.instance.setUp();

    final emailIdsCompleted = await _executeMarkAsMailboxRead(
      threadAPI: args.threadAPI,
      emailAPI: args.emailAPI,
      session: args.session,
      accountId: args.accountId,
      mailboxId: args.mailboxId,
      onProgress: sendPort.send,
    );
    log('MailboxIsolateWorker::_handleMarkAsMailboxRead(): TOTAL_READ: ${emailIdsCompleted.length}');
    return emailIdsCompleted;
  }

  Future<List<EmailId>> _handleMarkAsMailboxReadActionOnMainIsolate(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<Either<Failure, Success>> onProgressController,
  ) async {
    final result = await _executeMarkAsMailboxRead(
      threadAPI: _threadApi,
      emailAPI: _emailApi,
      session: session,
      accountId: accountId,
      mailboxId: mailboxId,
      onProgress: (countRead) => onProgressController.add(Right(
        UpdatingMarkAsMailboxReadState(
          mailboxId: mailboxId,
          totalUnread: totalEmailUnread,
          countRead: countRead,
        ),
      )),
    );
    log('MailboxIsolateWorker::_handleMarkAsMailboxReadActionOnMainIsolate(): TOTAL_READ: ${result.length}');
    return result;
  }

  static Future<List<EmailId>> _executeMarkAsMailboxRead({
    required ThreadAPI threadAPI,
    required EmailAPI emailAPI,
    required Session session,
    required AccountId accountId,
    required MailboxId mailboxId,
    required void Function(int countRead) onProgress,
  }) async {
    List<EmailId> emailIdsCompleted = List.empty(growable: true);
    bool mailboxHasEmails = true;
    UTCDate? lastReceivedDate;
    EmailId? lastEmailId;

    while (mailboxHasEmails) {
      final emailResponse = await threadAPI
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

      log('MailboxIsolateWorker::_executeMarkAsMailboxRead(): listEmailUnread: ${listEmailUnread?.length}');

      if (listEmailUnread == null || listEmailUnread.isEmpty) {
        mailboxHasEmails = false;
      } else {
        lastEmailId = listEmailUnread.last.id;
        lastReceivedDate = listEmailUnread.last.receivedAt;

        final result = await emailAPI.markAsRead(
          session,
          accountId,
          listEmailUnread.listEmailIds,
          ReadActions.markAsRead,
        );
        log('MailboxIsolateWorker::_executeMarkAsMailboxRead(): MARK_READ: ${result.emailIdsSuccess.length}');
        emailIdsCompleted.addAll(result.emailIdsSuccess);

        onProgress(emailIdsCompleted.length);
      }
    }
    log('MailboxIsolateWorker::_executeMarkAsMailboxRead(): TOTAL_READ: ${emailIdsCompleted.length}');
    return emailIdsCompleted;
  }

  Future<void> moveFolderContent({
    required Session session,
    required AccountId accountId,
    required MoveFolderContentRequest request,
    StreamController<Either<Failure, Success>>? onProgressController,
  }) async {
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw const CanNotGetRootIsolateToken();
    }

    final args = MoveFolderContentIsolateArguments(
      session: session,
      accountId: accountId,
      threadAPI: _threadApi,
      emailAPI: _emailApi,
      currentMailboxId: request.mailboxId,
      destinationMailboxId: request.destinationMailboxId,
      isolateToken: rootIsolateToken,
      markAsRead: request.markAsRead,
    );
    final countEmailsCompleted = await workerManager.executeWithPort<int, int>(
      _buildMoveFolderClosure(args),
      onMessage: (value) {
        log('$runtimeType::moveFolderContent(): Progress percent is ${value / request.totalEmails}');
        onProgressController?.add(
          Right<Failure, Success>(MoveFolderContentProgressState(
            request.mailboxId,
            value,
            request.totalEmails,
          )),
        );
      },
    );

    if (request.moveAction == MoveAction.moving &&
        countEmailsCompleted < request.totalEmails &&
        request.totalEmails > 0) {
      throw CannotMoveAllEmailException();
    }
  }

  static Future<List<EmailId>> Function(SendPort) _buildMarkAsReadClosure(
    MailboxMarkAsReadArguments args,
  ) => (sendPort) => _handleMarkAsMailboxReadAction(args, sendPort);

  static Future<int> Function(SendPort) _buildMoveFolderClosure(
    MoveFolderContentIsolateArguments args,
  ) => (sendPort) => _moveFolderContentIsolateMethod(args, sendPort);

  static Future<int> _moveFolderContentIsolateMethod(
    MoveFolderContentIsolateArguments args,
    SendPort sendPort,
  ) async {
    final rootIsolateToken = args.isolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await HiveCacheConfig.instance.setUp();

    int countEmailsCompleted = 0;
    bool hasEmails = true;
    Email? lastEmail;

    final threadAPI = args.threadAPI;
    final httpClient = threadAPI.httpClient;
    final session = args.session;
    final accountId = args.accountId;
    final currentMailboxId = args.currentMailboxId;
    final destinationMailboxId = args.destinationMailboxId;
    final markAsRead = args.markAsRead;

    while (hasEmails) {
      final listEmails = await threadAPI.getLatestEmails(
        httpClient: httpClient,
        session: session,
        accountId: accountId,
        mailboxId: currentMailboxId,
        lastEmail: lastEmail,
      );
      log('MailboxIsolateWorker::_moveFolderContentIsolateMethod(): Length of emails = ${listEmails.length}');
      if (listEmails.isEmpty) {
        hasEmails = false;
      } else {
        hasEmails = true;
        lastEmail = listEmails.last;

        final movedEmails = await threadAPI.moveEmailsBetweenMailboxes(
          httpClient: httpClient,
          session: session,
          accountId: accountId,
          emailIds: listEmails.listEmailIds,
          currentMailboxId: currentMailboxId,
          destinationMailboxId: destinationMailboxId,
          markAsRead: markAsRead,
        );

        countEmailsCompleted += movedEmails.emailIdsSuccess.length;
        sendPort.send(countEmailsCompleted);
      }
    }
    log('MailboxIsolateWorker::_moveFolderContentIsolateMethod(): Total emails moved = $countEmailsCompleted');
    return countEmailsCompleted;
  }
}
