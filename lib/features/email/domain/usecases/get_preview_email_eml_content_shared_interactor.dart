import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_content_shared_state.dart';

class GetPreviewEmailEMLContentSharedInteractor {
  final EmailRepository _emailRepository;

  const GetPreviewEmailEMLContentSharedInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(String keyStored) async* {
    try {
      yield Right<Failure, Success>(GettingPreviewEmailEMLContentShared());

      final previewEMLContent = await _emailRepository
        .getPreviewEmailEMLContentShared(keyStored);

      yield Right<Failure, Success>(GetPreviewEmailEMLContentSharedSuccess(previewEMLContent));
    } catch (e) {
      yield Left<Failure, Success>(GetPreviewEmailEMLContentSharedFailure(e));
    }
  }
}