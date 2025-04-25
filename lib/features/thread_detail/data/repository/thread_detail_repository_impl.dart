import 'package:collection/collection.dart';
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/extensions/list_extensions.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';

class ThreadDetailRepositoryImpl implements ThreadDetailRepository {
  const ThreadDetailRepositoryImpl(this.threadDetailDataSource);

  final Map<DataSourceType, ThreadDetailDataSource> threadDetailDataSource;

  @override
  Future<List<EmailId>> getEmailIdsByThreadId(
    ThreadId threadId,
    Session session,
    AccountId accountId,
    MailboxId sentMailboxId,
    String ownEmailAddress,
  ) async {
    final originalEmailIds = await threadDetailDataSource[DataSourceType.network]!
      .getEmailIdsByThreadId(threadId, accountId);
    
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
          .where((email) => email.id != null && (
            !emailInSentMailbox(email, sentMailboxId)
            || !emailFromMe(email, ownEmailAddress)
            || !emailToMe(email, ownEmailAddress)
          ))
          .sorted((a, b) => a.receivedAt == null || b.receivedAt == null
            ? 0
            : a.receivedAt!.value.compareTo(b.receivedAt!.value)
          )
          .map((e) => e.id!)
          .toList();
      } catch (e) {
        retry--;
      }
    }
    return [];
  }

  bool emailInSentMailbox(Email email, MailboxId sentMailboxId) {
    return email.mailboxIds?[sentMailboxId] == true;
  }

  bool emailFromMe(Email email, String ownEmailAddress) {
    return email.from?.any(
      (emailAdress) => emailAdress.email == ownEmailAddress
    ) == true;
  }

  bool emailToMe(Email email, String ownEmailAddress) {
    final to = email.to ?? {};
    final cc = email.cc ?? {};
    final bcc = email.bcc ?? {};

    return {...to, ...cc, ...bcc}.any(
      (emailAdress) => emailAdress.email == ownEmailAddress
    ) == true;
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