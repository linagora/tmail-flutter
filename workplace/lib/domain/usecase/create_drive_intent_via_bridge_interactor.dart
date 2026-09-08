import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import '../entity/workplace_intent_config.dart';
import '../repository/workplace_bridge_repository.dart';
import '../state/workplace_intent_state.dart';

class CreateDriveIntentViaBridgeInteractor {
  final WorkplaceBridgeRepository _repository;

  CreateDriveIntentViaBridgeInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(WorkplaceIntentConfig config) async* {
    try {
      yield Right(CreatingWorkplaceIntent());
      final intent = await _repository.createIntent(config);
      yield Right(CreateWorkplaceIntentSuccess(intent));
    } catch (e) {
      yield Left(CreateWorkplaceIntentFailure(exception: e));
    }
  }
}
