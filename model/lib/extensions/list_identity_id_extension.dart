import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/identity/identity_request_dto.dart';

extension ListIdentityIdExtension on List<IdentityId> {

  Map<Id, PatchObject> generateMapUpdateObjectSortOrder({UnsignedInt? sortOrder}) {
    final Map<Id, PatchObject> maps = {};
    forEach((identityId) {
      maps[identityId.id] = PatchObject(IdentityRequestDto(sortOrder: sortOrder).toJson());
    });
    return maps;
  }
}