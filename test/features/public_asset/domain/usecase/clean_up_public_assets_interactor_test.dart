import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/add_identity_to_public_assets_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/delete_public_assets_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/remove_identity_from_public_assets_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/add_identity_to_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/clean_up_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/remove_identity_from_public_assets_interactor.dart';

import 'clean_up_public_assets_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<RemoveIdentityFromPublicAssetsInteractor>(),
  MockSpec<DeletePublicAssetsInteractor>(),
  MockSpec<AddIdentityToPublicAssetsInteractor>(),
  MockSpec<Session>(),
  MockSpec<AccountId>(),
])
void main() {
  final removeIdentityFromPublicAssetsInteractor = MockRemoveIdentityFromPublicAssetsInteractor();
  final deletePublicAssetsInteractor = MockDeletePublicAssetsInteractor();
  final addIdentityToPublicAssetsInteractor = MockAddIdentityToPublicAssetsInteractor();
  final cleanUpPublicAssetsInteractor = CleanUpPublicAssetsInteractor(
    removeIdentityFromPublicAssetsInteractor,
    deletePublicAssetsInteractor,
    addIdentityToPublicAssetsInteractor,
  );

  group('clean up public assets interactor test:', () {
    final session = MockSession();
    final accountId = MockAccountId();

    test(
      'should destroy unused public assets '
      'when there are picked public assets that are deleted',
    () async {
      // arrange
      final identityId = IdentityId(Id('id-1'));
      const identityActionType = IdentityActionType.edit;
      final toBeUsedPublicAssetId = Id('public-asset-1');
      final toBeDeletedPublicAssetId = Id('public-asset-2');
      final newlyPickedPublicAssetIds = [toBeUsedPublicAssetId, toBeDeletedPublicAssetId];
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${toBeUsedPublicAssetId.value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: [],
        newlyPickedPublicAssetIds: newlyPickedPublicAssetIds);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verify(
        deletePublicAssetsInteractor.execute(
          session,
          accountId,
          publicAssetIds: [toBeDeletedPublicAssetId])
      ).called(1);
      verifyNever(
        removeIdentityFromPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verifyNever(
        addIdentityToPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
    });

    test(
      'should remove reference of unused public assets '
      'when there are existing public assets that are deleted',
    () async {
      // arrange
      final identityId = IdentityId(Id('id-1'));
      const identityActionType = IdentityActionType.edit;
      final toBeUsedPublicAssetId = Id('public-asset-1');
      final toBeDeletedPublicAssetId = Id('public-asset-2');
      final preExistingPublicAssetIds = [toBeUsedPublicAssetId, toBeDeletedPublicAssetId];
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${toBeUsedPublicAssetId.value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: preExistingPublicAssetIds,
        newlyPickedPublicAssetIds: []);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verifyNever(
        deletePublicAssetsInteractor.execute(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verify(
        removeIdentityFromPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: [toBeDeletedPublicAssetId])
      ).called(1);
      verifyNever(
        addIdentityToPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
    });

    test(
      'should add reference to public assets '
      'when there are new public assets '
      'and identity action is create',
    () async {
      // arrange
      final identityId = IdentityId(Id('id-1'));
      const identityActionType = IdentityActionType.create;
      final newlyPickedPublicAssetIds = [Id('public-asset-1')];
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${newlyPickedPublicAssetIds[0].value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: [],
        newlyPickedPublicAssetIds: newlyPickedPublicAssetIds);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verifyNever(
        deletePublicAssetsInteractor.execute(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verifyNever(
        removeIdentityFromPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verify(
        addIdentityToPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: newlyPickedPublicAssetIds)
      );
    });

    test(
      'should add reference to public assets '
      'when there are new public assets '
      'and those new public assets are pasted to signature',
    () async {
      // arrange
      const identityActionType = IdentityActionType.create;
      final identityId = IdentityId(Id('id-1'));
      final pastedPublicAssetId = Id('public-asset-1');
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${pastedPublicAssetId.value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: [],
        newlyPickedPublicAssetIds: []);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verifyNever(
        deletePublicAssetsInteractor.execute(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verifyNever(
        removeIdentityFromPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verify(
        addIdentityToPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: [pastedPublicAssetId])
      );
    });

    test(
      'should do nothing '
      'when there is no new public assets '
      'and there is no change in old public assets '
      'and there is no pasted public assets in signature',
    () async {
      // arrange
      const identityActionType = IdentityActionType.create;
      final identityId = IdentityId(Id('id-1'));
      final oldPublicAssetId = Id('public-asset-1');
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${oldPublicAssetId.value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: [oldPublicAssetId],
        newlyPickedPublicAssetIds: []);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verifyNever(
        deletePublicAssetsInteractor.execute(
          any,
          any,
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verifyNever(
        removeIdentityFromPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verifyNever(
        addIdentityToPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: anyNamed('publicAssetIds'))
      );
    });

    test(
      'should destroy unused public assets '
      'when there are picked public assets that are deleted '
      'and add reference to public assets '
      'when there are new public assets '
      'and identity action is create'
      'and add reference to public assets '
      'when there are new public assets '
      'and those new public assets are pasted to signature',
    () async {
      // arrange
      final identityId = IdentityId(Id('id-1'));
      const identityActionType = IdentityActionType.create;
      final toBeUsedNewlyPickedPublicAssetId = Id('public-asset-1');
      final toBeDeletedNewlyPickedPublicAssetId = Id('public-asset-2');
      final newlyPickedPublicAssetIds = [
        toBeUsedNewlyPickedPublicAssetId,
        toBeDeletedNewlyPickedPublicAssetId
      ];
      final pastedPublicAssetId = Id('public-asset-3');
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${toBeUsedNewlyPickedPublicAssetId.value}"/>'
        '<img src="public-asset-3" public-asset-id="${pastedPublicAssetId.value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: [],
        newlyPickedPublicAssetIds: newlyPickedPublicAssetIds);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verify(
        deletePublicAssetsInteractor.execute(
          session,
          accountId,
          publicAssetIds: [toBeDeletedNewlyPickedPublicAssetId])
      ).called(1);
      verifyNever(
        removeIdentityFromPublicAssetsInteractor.execute(
          any,
          any,
          identityId: anyNamed('identityId'),
          publicAssetIds: anyNamed('publicAssetIds'))
      );
      verify(
        addIdentityToPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: [pastedPublicAssetId, toBeUsedNewlyPickedPublicAssetId])
      ).called(1);
    });

    test(
      'should destroy unused public assets '
      'when there are picked public assets that are deleted '
      'and remove reference to public assets '
      'when there are old public assets that are deleted '
      'and add reference to public assets '
      'when there are new public assets '
      'and those new public assets are pasted to signature',
    () async {
      // arrange
      final identityId = IdentityId(Id('id-1'));
      const identityActionType = IdentityActionType.edit;
      final toBeUsedNewlyPickedPublicAssetId = Id('public-asset-1');
      final toBeDeletedNewlyPickedPublicAssetId = Id('public-asset-2');
      final newlyPickedPublicAssetIds = [
        toBeUsedNewlyPickedPublicAssetId,
        toBeDeletedNewlyPickedPublicAssetId
      ];
      final toBeDeletedPreExistingPublicAssetId = Id('public-asset-3');
      final pastedPublicAssetId = Id('public-asset-4');
      final htmlSignature = '<img src="public-asset-1" public-asset-id="${toBeUsedNewlyPickedPublicAssetId.value}"/>'
        '<img src="public-asset-4" public-asset-id="${pastedPublicAssetId.value}"/>';
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: [toBeDeletedPreExistingPublicAssetId],
        newlyPickedPublicAssetIds: newlyPickedPublicAssetIds);

      when(deletePublicAssetsInteractor
        .execute(any, any, publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(DeletePublicAssetsSuccessState())));
      when(removeIdentityFromPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(RemoveIdentityFromPublicAssetsSuccessState())));
      when(addIdentityToPublicAssetsInteractor
        .execute(any, any, identityId: anyNamed('identityId'), publicAssetIds: anyNamed('publicAssetIds')))
        .thenAnswer((_) => Stream.value(Right(AddIdentityToPublicAssetsSuccessState())));
  
      // act
      await cleanUpPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        identityActionType: identityActionType,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments).last;
      
      // assert
      verify(
        deletePublicAssetsInteractor.execute(
          session,
          accountId,
          publicAssetIds: [toBeDeletedNewlyPickedPublicAssetId])
      ).called(1);
      verify(
        removeIdentityFromPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: [toBeDeletedPreExistingPublicAssetId])
      ).called(1);
      verify(
        addIdentityToPublicAssetsInteractor.execute(
          session,
          accountId,
          identityId: identityId,
          publicAssetIds: [pastedPublicAssetId])
      ).called(1);
    });
  });
}