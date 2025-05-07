import 'package:jmap_dart_client/jmap/account_id.dart';
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
  Future<List<EmailId>> getThreadById(
    ThreadId threadId,
    AccountId accountId
  ) {
    return Future.sync(() async {
      return threadDetailApi.getThreadById(threadId, accountId);
    }).catchError(exceptionThrower.throwException);
  }
}