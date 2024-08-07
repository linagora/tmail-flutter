import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/create_public_asset_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';

class CreatePublicAssetInteractor {
  CreatePublicAssetInteractor(this._publicAssetRepository);

  final PublicAssetRepository _publicAssetRepository;

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      required Id blobId,
      required IdentityId? identityId
    }
  ) async* {
    try {
      yield Right<Failure, Success>(CreatingPublicAssetState());
      final publicAsset = await _publicAssetRepository.createPublicAsset(
        session,
        accountId,
        blobId: blobId,
        identityId: identityId);
      yield Right<Failure, Success>(CreatePublicAssetSuccessState(publicAsset));
    } catch (exception) {
      logError('CreatePublicAssetInteractor::execute():error: $exception');
      yield Left<Failure, Success>(CreatePublicAssetFailureState(exception: exception));
    }
  }
}