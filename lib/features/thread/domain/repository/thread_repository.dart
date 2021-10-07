import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';

abstract class ThreadRepository {
  Stream<EmailResponse> getAllEmail(
    AccountId accountId,
    {
      int? position,
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      MailboxId? inMailboxId
    }
  );

  Stream<EmailResponse> refreshChanges(
    AccountId accountId,
    jmap.State currentState,
    {
      Set<Comparator>? sort,
      Properties? propertiesCreated,
      Properties? propertiesUpdated,
      MailboxId? inMailboxId
    }
  );
}