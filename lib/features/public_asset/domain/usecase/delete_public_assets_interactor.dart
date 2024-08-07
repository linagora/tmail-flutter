import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/public_asset/domain/repository/public_asset_repository.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/delete_public_assets_state.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';

class DeletePublicAssetsInteractor {
  DeletePublicAssetsInteractor(this._publicAssetRepository);

  final PublicAssetRepository _publicAssetRepository;

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {required List<PublicAssetId> publicAssetIds}
  ) async* {
    try {
      yield Right(DeletingPublicAssetsState());
      await _publicAssetRepository.deletePublicAssets(
        session,
        accountId,
        publicAssetIds: publicAssetIds);
      yield Right(DeletePublicAssetsSuccessState());
    } catch (exception) {
      logError('DeletePublicAssetsInteractor::execute():error: $exception');
      yield Left(DeletePublicAssetsFailureState(exception: exception));
    }
  }
}