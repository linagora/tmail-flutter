import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/identity_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_default_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/utils/identity_utils.dart';
import 'package:uuid/uuid.dart';

import '../../models/provisioning_identity.dart';
import 'jmap_test_client.dart';

/// Creates identities straight through JMAP, without the identity controllers.
class JmapIdentityProvisioner {
  Future<void> create(List<ProvisioningIdentity> identities) async {
    final client = await JmapTestClient.current();
    final api = IdentityAPI(client.httpClient);
    // Sequential: the default identity request depends on the identities created before it.
    for (final provisioning in identities) {
      final creationId = Id(const Uuid().v1());
      final request = provisioning.isDefault
          ? await _defaultRequest(api, client, creationId, provisioning)
          : CreateNewIdentityRequest(creationId, provisioning.identity);
      await api.createNewIdentity(client.session, client.accountId, request);
    }
  }

  Future<CreateNewDefaultIdentityRequest> _defaultRequest(
    IdentityAPI api,
    JmapTestClient client,
    Id creationId,
    ProvisioningIdentity provisioning,
  ) async {
    final existing = await api.getAllIdentities(
      client.session,
      client.accountId,
      properties: Properties({'sortOrder', 'mayDelete'}),
    );
    final deletable =
        existing.identities?.where((identity) => identity.mayDelete == true).toList();
    final previousDefaults = IdentityUtils().getSmallestOrderedIdentity(deletable);
    return CreateNewDefaultIdentityRequest(
      creationId,
      provisioning.identity,
      oldDefaultIdentityIds: previousDefaults?.map((identity) => identity.id!).toList(),
    );
  }
}
