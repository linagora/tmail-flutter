import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/remove_preview_email_eml_content_shared_state.dart';

class RemovePreviewEmailEmlContentSharedInteractor {
  final EmailRepository _emailRepository;

  const RemovePreviewEmailEmlContentSharedInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(String keyStored) async* {
    try {
      yield Right<Failure, Success>(RemovingPreviewEmailEMLContentShared());
      await _emailRepository.removePreviewEmailEMLContentShared(keyStored);
      yield Right<Failure, Success>(RemovePreviewEmailEMLContentSharedSuccess());
    } catch (e) {
      yield Left<Failure, Success>(RemovePreviewEmailEMLContentSharedFailure(e));
    }
  }
}