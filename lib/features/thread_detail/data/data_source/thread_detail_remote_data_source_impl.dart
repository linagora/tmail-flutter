import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread_detail/data/data_source/thread_detail_data_source.dart';
import 'package:tmail_ui_user/features/thread_detail/data/network/thread_detail_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ThreadDetailRemoteDataSourceImpl implements ThreadDetailDataSource {
  const ThreadDetailRemoteDataSourceImpl(
    this.threadDetailApi,
    this.exceptionThrower,
  );

  final ThreadDetailApi threadDetailApi;
  final ExceptionThrower exceptionThrower;

  @override
  Future<List<EmailId>> getEmailIdsByThreadId(
    ThreadId threadId,
    AccountId accountId
  ) {
    return Future.sync(() async {
      return threadDetailApi.getThread(threadId, accountId);
    }).catchError(exceptionThrower.throwException);
  }

  @override
  Future<List<Email>> getEmailsByIds(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds, {
    Properties? properties,
  }) {
    return Future.sync(() async {
      return threadDetailApi.getEmailsByIds(
        session,
        accountId,
        emailIds,
        properties: properties,
      );
    }).catchError(exceptionThrower.throwException);
  }
}