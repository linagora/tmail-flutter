import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:drive_attachment/drive_attachment/domain/repository/drive_attachment_repository.dart';
import 'package:drive_attachment/drive_attachment/domain/state/drive_intent_state.dart';

class CreateDriveIntentInteractor {
  final DriveAttachmentRepository _repository;

  CreateDriveIntentInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(Uri platformUrl, String accessToken) async* {
    try {
      yield Right(CreatingDriveIntent());
      final intent = await _repository.createIntent(platformUrl, accessToken);
      yield Right(CreateDriveIntentSuccess(intent));
    } catch (e) {
      yield Left(CreateDriveIntentFailure(e));
    }
  }
}
