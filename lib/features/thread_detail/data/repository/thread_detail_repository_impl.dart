import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';

class ThreadDetailRepositoryImpl implements ThreadDetailRepository {
  const ThreadDetailRepositoryImpl(this.threadDetailDataSource);

  final Map<DataSourceType, ThreadDetailDataSource> threadDetailDataSource;

  @override
  Future<List<EmailId>> getEmailIdsByThreadId(
    ThreadId threadId,
    AccountId accountId
  ) {
    return threadDetailDataSource[DataSourceType.network]!
      .getEmailIdsByThreadId(threadId, accountId);
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