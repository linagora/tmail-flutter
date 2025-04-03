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
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
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

  Future<List<EmailId>> emptyTrashFolder(
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

  Future<List<EmailId>> emptySpamFolder(
    Session session,
    AccountId accountId,
    MailboxId spamMailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  );

  Future<void> clearEmailCacheAndStateCache(AccountId accountId, Session session);
}