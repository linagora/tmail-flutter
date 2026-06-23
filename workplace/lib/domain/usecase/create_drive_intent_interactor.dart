import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import '../repository/workplace_repository.dart';
import '../state/workplace_intent_state.dart';

class CreateDriveIntentInteractor {
  final WorkplaceRepository _repository;

  CreateDriveIntentInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(
    Uri platformUrl,
    String accessToken, {
    required String addAsLink,
    required String addAsAttachment,
  }) async* {
    try {
      yield Right(CreatingWorkplaceIntent());
      final intent = await _repository.createIntent(
        platformUrl,
        accessToken,
        addAsLink: addAsLink,
        addAsAttachment: addAsAttachment,
      );
      yield Right(CreateWorkplaceIntentSuccess(intent));
    } catch (e) {
      yield Left(CreateWorkplaceIntentFailure(exception: e));
    }
  }
}
