import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/state/remove_identity_cache_on_web_state.dart';

class RemoveIdentityCacheOnWebInteractor {
  RemoveIdentityCacheOnWebInteractor(this._identityCreatorRepository);

  final IdentityCreatorRepository _identityCreatorRepository;

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(RemovingIdentityCacheOnWeb());
      await _identityCreatorRepository.removeIdentityCacheOnWeb();

      yield Right(RemoveIdentityCacheOnWebSuccess());
    } catch (exception) {
      logError("$runtimeType::execute: $exception");
      yield Left(RemoveIdentityCacheOnWebFailure(exception: exception));
    }
  }
}