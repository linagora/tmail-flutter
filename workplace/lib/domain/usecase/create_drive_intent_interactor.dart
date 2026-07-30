import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import '../entity/workplace_action_config.dart';
import '../entity/workplace_theme.dart';
import '../repository/workplace_repository.dart';
import '../state/workplace_intent_state.dart';

class CreateDriveIntentInteractor {
  final WorkplaceRepository _repository;

  CreateDriveIntentInteractor(this._repository);

  Stream<Either<Failure, Success>> execute(
    Uri platformUrl,
    String accessToken, {
    required WorkplaceActionConfig addAsLink,
    WorkplaceActionConfig? addAsAttachment,
    required WorkplaceTheme theme,
  }) async* {
    try {
      yield Right(CreatingWorkplaceIntent());
      final intent = await _repository.createIntent(
        platformUrl: platformUrl,
        accessToken: accessToken,
        addAsLink: addAsLink,
        addAsAttachment: addAsAttachment,
        theme: theme,
      );
      yield Right(CreateWorkplaceIntentSuccess(intent));
    } catch (e) {
      yield Left(CreateWorkplaceIntentFailure(exception: e));
    }
  }
}
