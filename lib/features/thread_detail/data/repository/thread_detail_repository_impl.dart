import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/extensions/list_extensions.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';

class ThreadDetailRepositoryImpl implements ThreadDetailRepository {
  const ThreadDetailRepositoryImpl(this.threadDetailDataSource);

  final Map<DataSourceType, ThreadDetailDataSource> threadDetailDataSource;

  @override
  Future<List<EmailId>> getThreadById(
    ThreadId threadId,
    Session session,
    AccountId accountId,
    MailboxId sentMailboxId,
    String ownEmailAddress,
  ) async {
    final originalEmailIds = await threadDetailDataSource[DataSourceType.network]!
      .getThreadById(threadId, accountId);
    
    final filteredEmailIds = await Future.wait(
      originalEmailIds
        .chunks(20)
        .map((emailIds) => _filterBadEmails(
          session,
          accountId,
          emailIds,
          sentMailboxId,
          ownEmailAddress,
        ))
    );

    return filteredEmailIds.reduce((prev, curr) => prev + curr);
  }

  Future<List<EmailId>> _filterBadEmails(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MailboxId sentMailboxId,
    String ownEmailAddress,
  ) async {
    int retry = 3;
    while (retry > 0) {
      try {
        final emails = await threadDetailDataSource[DataSourceType.network]!
          .getEmailsByIds(
            session,
            accountId,
            emailIds,
            properties: Properties({
              EmailProperty.id,
              EmailProperty.mailboxIds,
              EmailProperty.from,
              EmailProperty.to,
              EmailProperty.cc,
              EmailProperty.bcc,
              EmailProperty.receivedAt,
            }),
          );
        return emails
          .where((email) => checkEmailValidForThreadDetail(
            email,
            sentMailboxId,
            ownEmailAddress,
          ))
          .toList()
          .sortWithResult(EmailComparator(
            EmailComparatorProperty.receivedAt
          )..setIsAscending(true))
          .map((e) => e.id!)
          .toList();
      } catch (e) {
        retry--;

        if (retry <= 0) rethrow;
      }
    }
    return [];
  }

  bool checkEmailValidForThreadDetail(
    Email email,
    MailboxId sentMailboxId,
    String ownEmailAddress,
  ) {
    return email.id != null && (
      !email.inSentMailbox(sentMailboxId)
      || !email.fromMe(ownEmailAddress)
    );
  }

  @override
  Future<List<Email>> getEmailsByIds(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds, {
    Properties? properties,
  }) {
    return threadDetailDataSource[DataSourceType.network]!
      .getEmailsByIds(session, accountId, emailIds, properties: properties);
  }
}