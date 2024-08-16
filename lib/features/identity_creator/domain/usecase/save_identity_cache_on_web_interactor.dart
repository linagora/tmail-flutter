import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/state/save_identity_cache_on_web_state.dart';

class SaveIdentityCacheOnWebInteractor {
  SaveIdentityCacheOnWebInteractor(this._identityCreatorRepository);

  final IdentityCreatorRepository _identityCreatorRepository;

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    {required IdentityCache identityCache}
  ) async* {
    try {
      yield Right(SavingIdentityCacheOnWeb());
      await _identityCreatorRepository.saveIdentityCacheOnWeb(
        accountId,
        userName,
        identityCache: identityCache);
      yield Right(SaveIdentityCacheOnWebSuccess());
    } catch (exception) {
      logError("$runtimeType::execute: $exception");
      yield Left(SaveIdentityCacheOnWebFailure(exception: exception));
    }
  }
}