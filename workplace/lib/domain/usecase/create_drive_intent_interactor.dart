import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import '../entity/workplace_intent_access_mode.dart';
import '../entity/workplace_intent_config.dart';
import '../repository/workplace_repository.dart';
import '../state/workplace_intent_state.dart';

class CreateDriveIntentInteractor {
  final WorkplaceRepository _repository;

  CreateDriveIntentInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(
    Uri platformUrl,
    WorkplaceIntentAccessMode accessMode, {
    required WorkplaceIntentConfig config,
  }) async* {
    try {
      yield Right(CreatingWorkplaceIntent());
      final intent = await _repository.createIntent(
        platformUrl: platformUrl,
        accessMode: accessMode,
        config: config,
      );
      yield Right(CreateWorkplaceIntentSuccess(intent));
    } catch (e) {
      yield Left(CreateWorkplaceIntentFailure(exception: e));
    }
  }
}
