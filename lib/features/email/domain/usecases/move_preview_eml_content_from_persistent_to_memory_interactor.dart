import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_preview_eml_content_from_persistent_to_memory_state.dart';

class MovePreviewEmlContentFromPersistentToMemoryInteractor {
  final EmailRepository _emailRepository;

  const MovePreviewEmlContentFromPersistentToMemoryInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(String keyStored, String content) async* {
    try {
      yield Right<Failure, Success>(MovingPreviewEmailEMLContentFromPersistentToMemory());
      await Future.wait([
        _emailRepository.removePreviewEmailEMLContentShared(keyStored),
        _emailRepository.movePreviewEMLContentFromPersistentToMemory(keyStored, content),
      ]);
      yield Right<Failure, Success>(MovePreviewEmailEMLContentFromPersistentToMemorySuccess());
    } catch (e) {
      yield Left<Failure, Success>(MovePreviewEmailEMLContentFromPersistentToMemoryFailure(e));
    }
  }
}