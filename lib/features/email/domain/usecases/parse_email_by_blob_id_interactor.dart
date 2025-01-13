import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';

class ParseEmailByBlobIdInteractor {
  final EmailRepository _emailRepository;

  const ParseEmailByBlobIdInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Id blobId) async* {
    try {
      yield Right<Failure, Success>(ParsingEmailByBlobId());

      final emailParsed = await _emailRepository.parseEmailByBlobIds(
        accountId,
        {blobId},
      );

      yield Right<Failure, Success>(ParseEmailByBlobIdSuccess(
        emailParsed.first,
        blobId,
      ));
    } catch (e) {
      yield Left<Failure, Success>(ParseEmailByBlobIdFailure(e));
    }
  }
}