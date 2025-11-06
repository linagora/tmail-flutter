import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/download/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

class ParseEmailByBlobIdInteractor {
  final DownloadRepository _downloadRepository;

  const ParseEmailByBlobIdInteractor(this._downloadRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Session session,
    String ownEmailAddress,
    Id blobId,
  ) async* {
    try {
      yield Right<Failure, Success>(ParsingEmailByBlobId());

      final emailParsed = await _downloadRepository.parseEmailByBlobIds(
        accountId,
        {blobId},
      );

      yield Right<Failure, Success>(ParseEmailByBlobIdSuccess(
        email: emailParsed.first,
        blobId: blobId,
        session: session,
        accountId: accountId,
        ownEmailAddress: ownEmailAddress,
      ));
    } catch (e) {
      yield Left<Failure, Success>(ParseEmailByBlobIdFailure(e));
    }
  }
}
