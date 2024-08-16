import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:mockito/annotations.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource_impl/local_identity_creator_data_source_impl.dart';
import 'package:tmail_ui_user/features/identity_creator/data/model/identity_cache_model.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'local_identity_creator_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ExceptionThrower>()])
void main() {
  final exceptionThrower = MockExceptionThrower();
  final localIdentityCreatorDataSourceImpl = LocalIdentityCreatorDataSourceImpl(exceptionThrower);
  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  
  group('local identity creator data source impl test:', () {
    test(
      'should save identity cache as expected',
    () async {
      // arrange
      final identity = Identity();
      const identityActionType = IdentityActionType.create;
      const isDefault = true;
      final htmlSignature = identity.signatureAsString;
      final preExistingPublicAssetIds = <PublicAssetId>[];
      final newlyPickedPublicAssetIds = <PublicAssetId>[];
      final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
        htmlSignature: htmlSignature,
        preExistingPublicAssetIds: preExistingPublicAssetIds,
        newlyPickedPublicAssetIds: newlyPickedPublicAssetIds,
      );
      final identityCache = IdentityCache(
        identity: identity,
        identityActionType: identityActionType,
        isDefault: isDefault,
        publicAssetsInIdentityArguments: publicAssetsInIdentityArguments);

      // act
      await localIdentityCreatorDataSourceImpl.saveIdentityCacheOnWeb(
        accountId,
        session.username,
        identityCache: identityCache);
      final cacheKey = TupleKey(
        LocalIdentityCreatorDataSourceImpl.sessionStorageKeyword,
        accountId.asString,
        session.username.value
      ).toString();
      final cache = window.sessionStorage[cacheKey];
      
      // assert
      expect(
        jsonDecode(cache!),
        equals(IdentityCacheModel.fromDomain(identityCache).toJson()));
    });
  });
}