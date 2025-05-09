import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';

class GetEmailsByIdsInteractor {
  const GetEmailsByIdsInteractor(this._threadDetailRepository);

  final ThreadDetailRepository _threadDetailRepository;

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds, {
    Properties? properties,
  }) async* {
    try {
      yield Right(GettingEmailsByIds());
      final result = await _threadDetailRepository.getEmailsByIds(
        session,
        accountId,
        emailIds,
        properties: properties,
      );
      yield Right(GetEmailsByIdsSuccess(
        result.map((e) => e.toPresentationEmail()).toList(),
      ));
    } catch (e) {
      logError('GetEmailsByIdsInteractor::execute(): Exception: $e');
      yield Left(GetEmailsByIdsFailure(
        exception: e,
        onRetry: execute(session, accountId, emailIds, properties: properties),
      ));
    }
  }
}