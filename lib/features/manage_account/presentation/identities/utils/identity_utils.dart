import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class IdentityUtils {
  static const int _defaultSortOrder = 2147483647; // 2^31 - 1

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

  /// Sorts identities by ascending sortOrder (null last). The sort is stable:
  /// identities sharing the same sortOrder keep the order sent by the server.
  void sortListIdentities(List<Identity> identities) {
    mergeSort<Identity>(
      identities,
      compare: (identity1, identity2) =>
        _sortOrderOf(identity1).compareTo(_sortOrderOf(identity2)),
    );
  }

  num _sortOrderOf(Identity identity) =>
    identity.sortOrder?.value ?? _defaultSortOrder;
}
