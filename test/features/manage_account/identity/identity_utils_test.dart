import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';

void main() {
  final identityUtils = IdentityUtils();
  group('get smallest sortOrder identity test', () {
    test('getSmallestOrderedIdentity return identity with sortOrder equals to 1', () {
      final sortOrders = [1,99, 999, 100, 201];
      final listIdentities1 = sortOrders.map((e) => Identity(sortOrder: UnsignedInt(e))).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1, [listIdentities1[0]]);
    });

    test('getSmallestOrderedIdentity return list identities with sortOrder equals to 1', () {
      final sortOrders = [1, 1, 23, 2, 3, 4];
      final listIdentities1 = sortOrders.map((e) => Identity(sortOrder: UnsignedInt(e))).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1, [listIdentities1[0], listIdentities1[1]]);
    });

    test('getSmallestOrderedIdentity return identity with sortOrder equals to 1', () {
      final sortOrders = [null, 1, 2, 3, 5, 99];
      final listIdentities1 = sortOrders.map((e) {
        if(e != null){
          return Identity(sortOrder: UnsignedInt(e));
        }
        return Identity();
      }).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1, [listIdentities1[1]]);
    });

    test('getSmallestOrderedIdentity return identity with sortOrder equals to 2', () {
      final sortOrders = [null, null, 2, 3, 5, 99];
      final listIdentities1 = sortOrders.map((e) {
        if(e != null){
          return Identity(sortOrder: UnsignedInt(e));
        }
        return Identity();
      }).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1, [listIdentities1[2]]);
    });

    test('getSmallestOrderedIdentity return list identities with sortOrder equals to null', () {
      final sortOrders = [null, null, null, null, null];
      final listIdentities1 = sortOrders.map((e) {
        if(e != null){
          return Identity(sortOrder: UnsignedInt(e as num));
        }
        return Identity();
      }).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1!.length, 5);
      expect(actual1[1], Identity(sortOrder: null));
    });

    test('getSmallestOrderedIdentity return list identities with sortOrder equals to 0', () {
      final sortOrders = [0, 0, 0, 0 ,0 ,0];
      final listIdentities1 = sortOrders.map((e) {
        return Identity(sortOrder: UnsignedInt(e));
      }).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1!.length, 6);
      expect(actual1[1], Identity(sortOrder: UnsignedInt(0)));
    });

    test('getSmallestOrderedIdentity return identity with sortOrder equals to 0', () {
      final sortOrders = [0, 99, 999, 100, 12];
      final listIdentities1 = sortOrders.map((e) => Identity(sortOrder: UnsignedInt(e))).toList();
      final actual1 = identityUtils.getSmallestOrderedIdentity(listIdentities1);

      expect(actual1, [listIdentities1[0]]);
    });
  });

  group('test sort list of all identities', () {
    test('should return a list of identities with increasing sortOrder of identities', () {
      final sortOrders = [9, 1, 99, 98, 95, 0, 12];
      final listIdentities1 = sortOrders.map((e) => Identity(sortOrder: UnsignedInt(e))).toList();
      identityUtils.sortListIdentities(listIdentities1);
      expect(listIdentities1, [0, 1, 9, 12, 95, 98, 99].map((e) => Identity(sortOrder: UnsignedInt(e))).toList());
    });

    test('should return a list of identities with increasing sortOrder of identities, null identity will be put at the end of list', () {
      final sortOrders = [9, 1, 99, 98, 95, null, 12];
      final listIdentities1 = sortOrders.map((e) {
        if(e != null){
          return Identity(sortOrder: UnsignedInt(e));
        }
        return Identity();
      }).toList();
      identityUtils.sortListIdentities(listIdentities1);
      expect(listIdentities1, [1, 9, 12, 95, 98, 99, null].map((e) => Identity(sortOrder: e != null ? UnsignedInt(e) : null)).toList());
    });

    test('return a list of identities with all null value at the end of list and 999 is the first identities in list', () {
      final sortOrders = [null, 999, null, null, null, null, null];
      final listIdentities1 = sortOrders.map((e) {
        if(e != null){
          return Identity(sortOrder: UnsignedInt(e));
        }
        return Identity();
      }).toList();
      identityUtils.sortListIdentities(listIdentities1);
      expect(listIdentities1, [999, null, null, null, null, null, null].map((e) => Identity(sortOrder: e != null ? UnsignedInt(e) : null)).toList());
    });

    test('should return a list of null value', () {
      final sortOrders = [null, null, null, null, null, null, null];
      final listIdentities1 = sortOrders.map((e) {
        if(e != null){
          return Identity(sortOrder: null);
        }
        return Identity();
      }).toList();
      identityUtils.sortListIdentities(listIdentities1);
      expect(listIdentities1, [null, null, null, null, null, null, null].map((e) => Identity()).toList());
    });
  });
}