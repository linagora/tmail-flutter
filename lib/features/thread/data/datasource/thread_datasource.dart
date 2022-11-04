import 'dart:async';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

abstract class ThreadDataSource {
  Future<EmailsResponse> getAllEmail(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  );

  Future<EmailChangeResponse> getChanges(
    AccountId accountId,
    State sinceState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  );

  Future<List<Email>> getAllEmailCache({MailboxId? inMailboxId, Set<Comparator>? sort, FilterMessageOption? filterOption, UnsignedInt? limit});

  Future<void> update({List<Email>? updated, List<Email>? created, List<EmailId>? destroyed});

  Future<List<EmailId>> emptyTrashFolder(
      AccountId accountId,
      MailboxId mailboxId,
      Future<void> Function(List<EmailId>? newDestroyed) updateDestroyedEmailCache,
  );

  Future<PresentationEmail> getEmailById(AccountId accountId, EmailId emailId, {Properties? properties});
}