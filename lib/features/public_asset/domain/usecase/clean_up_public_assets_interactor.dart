import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/list_extension.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/domain/extensions/string_to_public_asset_extension.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/clean_up_public_assets_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/add_identity_to_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/remove_identity_from_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';

class CleanUpPublicAssetsInteractor {
  CleanUpPublicAssetsInteractor(
    this.removeIdentityFromPublicAssetsInteractor,
    this.deletePublicAssetsInteractor,
    this.addIdentityToPublicAssetsInteractor);

  final RemoveIdentityFromPublicAssetsInteractor removeIdentityFromPublicAssetsInteractor;
  final DeletePublicAssetsInteractor deletePublicAssetsInteractor;
  final AddIdentityToPublicAssetsInteractor addIdentityToPublicAssetsInteractor;

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    {
      required IdentityId identityId,
      required IdentityActionType identityActionType,
      required PublicAssetsInIdentityArguments publicAssetsInIdentityArguments,
    }
  ) async* {
    try {
      yield Right(CleaningUpPublicAssetsState());

      final publicAssetIds = _filterPublicAssetsIdsForCleanUp(
        identityId,
        identityActionType,
        publicAssetsInIdentityArguments);

      await Rx.merge<Either<Failure, Success>>([
        if (publicAssetIds.publicAssetsIdsToBeDereferenced.isNotEmpty)
          removeIdentityFromPublicAssetsInteractor.execute(
            session,
            accountId,
            identityId: identityId,
            publicAssetIds: publicAssetIds.publicAssetsIdsToBeDereferenced),
        if (publicAssetIds.publicAssetsIdsToBeDestroyed.isNotEmpty)
          deletePublicAssetsInteractor.execute(
            session,
            accountId,
            publicAssetIds: publicAssetIds.publicAssetsIdsToBeDestroyed),
        if (publicAssetIds.publicAssetsIdsToBeReferenced.isNotEmpty)
          addIdentityToPublicAssetsInteractor.execute(
            session,
            accountId,
            identityId: identityId,
            publicAssetIds: publicAssetIds.publicAssetsIdsToBeReferenced),
      ]).last;

      yield Right(CleanUpPublicAssetsSuccessState());

    } catch (exception) {
      logError('CleanUpPublicAssetsInteractor::execute():error: $exception');
      yield Left(CleanUpPublicAssetsFailureState(exception: exception));
    }
  }

  ({
    List<PublicAssetId> publicAssetsIdsToBeDestroyed,
    List<PublicAssetId> publicAssetsIdsToBeReferenced,
    List<PublicAssetId> publicAssetsIdsToBeDereferenced, 
  }) _filterPublicAssetsIdsForCleanUp(
    IdentityId identityId,
    IdentityActionType identityActionType,
    PublicAssetsInIdentityArguments publicAssetsInIdentityArguments,
  ) {
    final htmlSignature = publicAssetsInIdentityArguments.htmlSignature;
    final publicAssetIdsInSignature = htmlSignature.publicAssetIdsFromHtmlContent;
    log('CleanUpPublicAssetsInteractor::publicAssetIdsInSignature: $publicAssetIdsInSignature');
    final preExistingPublicAssetIds = publicAssetsInIdentityArguments.preExistingPublicAssetIds;
    log('CleanUpPublicAssetsInteractor::preExistingPublicAssetIds: $preExistingPublicAssetIds');
    final newlyPickedPublicAssetIds = publicAssetsInIdentityArguments.newlyPickedPublicAssetIds;
    log('CleanUpPublicAssetsInteractor::newlyPickedPublicAssetIds: $newlyPickedPublicAssetIds');

    final deletedPreExistingPublicAssetIds = List<PublicAssetId>.from(preExistingPublicAssetIds);
    final notIncludedNewlyPickedPublicAssetIds = List<PublicAssetId>.from(newlyPickedPublicAssetIds);
    final pastedPublicAssetIds = <PublicAssetId>[];
    final newPublicAssetsIdsInSignature = <PublicAssetId>[];

    for (var id in publicAssetIdsInSignature) {
      deletedPreExistingPublicAssetIds.remove(id);
      notIncludedNewlyPickedPublicAssetIds.remove(id);
      
      if (preExistingPublicAssetIds.notContains(id)
        && newlyPickedPublicAssetIds.notContains(id)
      ) {
        pastedPublicAssetIds.add(id);
      }

      if (identityActionType == IdentityActionType.create 
        && newlyPickedPublicAssetIds.contains(id)
      ) {
        newPublicAssetsIdsInSignature.add(id);
      }
    }

    log('CleanUpPublicAssetsInteractor::deletedpreExistingPublicAssetIds: $deletedPreExistingPublicAssetIds');
    log('CleanUpPublicAssetsInteractor::notIncludednewlyPickedPublicAssetIds: $notIncludedNewlyPickedPublicAssetIds');
    log('CleanUpPublicAssetsInteractor::pastedPublicAssetIds: $pastedPublicAssetIds');
    log('CleanUpPublicAssetsInteractor::newPublicAssetsIdsInSignature: $newPublicAssetsIdsInSignature');

    return (
      publicAssetsIdsToBeDestroyed: notIncludedNewlyPickedPublicAssetIds,
      publicAssetsIdsToBeReferenced: pastedPublicAssetIds + newPublicAssetsIdsInSignature,
      publicAssetsIdsToBeDereferenced: deletedPreExistingPublicAssetIds,
    );
  }
}