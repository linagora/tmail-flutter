import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';

abstract class ThreadRepository {
  Stream<EmailsResponse> getAllEmail(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      bool getLatestChanges = true,
    }
  );

  Stream<EmailsResponse> refreshChanges(
    Session session,
    AccountId accountId,
    jmap.State currentState,
    {
      Set<Comparator>? sort,
      EmailFilter? emailFilter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
    }
  );

  Stream<EmailsResponse> loadMoreEmails(GetEmailRequest emailRequest);

  Future<List<SearchEmail>> searchEmails(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  );

  Future<List<EmailId>> emptyMailboxFolder(
    Session session,
    AccountId accountId,
    MailboxId trashMailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  );

  Future<PresentationEmail> getEmailById(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? properties}
  );

  Future<List<EmailId>> markAllAsUnreadForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailRead,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  );

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
  );

  Future<List<EmailId>> markAllAsStarredForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  );

  Future<List<EmailId>> markAllSearchAsRead(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  );

  Future<List<EmailId>> markAllSearchAsUnread(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  );

  Future<List<EmailId>> markAllSearchAsStarred(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  );

  Future<List<EmailId>> moveAllEmailSearchedToFolder(
    Session session,
    AccountId accountId,
    MailboxId destinationMailboxId,
    String destinationPath,
    SearchEmailFilter searchEmailFilter,
    {
      bool isDestinationSpamMailbox = false,
      EmailFilterCondition? moreFilterCondition,
    }
  );
}