import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_eml_content_in_memory_state.dart';

class GetPreviewEmlContentInMemoryInteractor {
  final EmailRepository _emailRepository;

  const GetPreviewEmlContentInMemoryInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(String keyStored) async* {
    try {
      yield Right<Failure, Success>(GettingPreviewEMLContentInMemory());
      final previewEMLContent = await _emailRepository.getPreviewEMLContentInMemory(keyStored);
      yield Right<Failure, Success>(GetPreviewEMLContentInMemorySuccess(previewEMLContent));
    } catch (e) {
      yield Left<Failure, Success>(GetPreviewEMLContentInMemoryFailure(e));
    }
  }
}