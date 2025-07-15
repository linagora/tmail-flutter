import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class IdentityUtils {
  
  List<Identity>? getSmallestOrderedIdentity(List<Identity>? identities) {
    if (identities == null || identities.isEmpty) {
      return identities;
    }
    final initialIdentity = Identity(sortOrder: UnsignedInt(9007199254740991));
    final smallestIdentity = identities.fold<Identity>(
      initialIdentity,
      (previousIdentity, nextIdentity) {
        if (previousIdentity.sortOrder == null && nextIdentity.sortOrder == null) {
          return initialIdentity;
        } else if (previousIdentity.sortOrder == null) {
          return nextIdentity;
        } else if (nextIdentity.sortOrder == null) {
          return previousIdentity;
        } 
              
        return previousIdentity.sortOrder!.value < nextIdentity.sortOrder!.value 
            ? previousIdentity : nextIdentity;
      });

    if (smallestIdentity == initialIdentity) {
      return identities;
    }
    
    return identities.where((element) => element.sortOrder == smallestIdentity.sortOrder).toList();
  }

  void sortListIdentities(List<Identity> identities) {
    identities.sort((identity1, identity2) {
      var sortOrder1 = identity1.sortOrder;
      var sortOrder2 = identity2.sortOrder;
      if (identity1.sortOrder == null) {
        sortOrder1 = UnsignedInt(2147483647); // 2^31 - 1
      }
      if (identity2.sortOrder == null) {
        sortOrder2 = UnsignedInt(2147483647);
      }
      return sortOrder1!.value < sortOrder2!.value ? -1 : 1 ;
    });
  }
}