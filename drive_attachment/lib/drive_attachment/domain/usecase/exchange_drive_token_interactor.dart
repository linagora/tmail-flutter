import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:drive_attachment/drive_attachment/domain/repository/drive_attachment_repository.dart';
import 'package:drive_attachment/drive_attachment/domain/state/drive_intent_state.dart';

class ExchangeDriveTokenInteractor {
  final DriveAttachmentRepository _repository;

  ExchangeDriveTokenInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(Uri platformUrl, String oidcIdToken) async* {
    try {
      yield Right(ExchangingDriveToken());
      final token = await _repository.exchangeToken(platformUrl, oidcIdToken);
      yield Right(ExchangeDriveTokenSuccess(token));
    } catch (e) {
      yield Left(ExchangeDriveTokenFailure(e));
    }
  }
}
