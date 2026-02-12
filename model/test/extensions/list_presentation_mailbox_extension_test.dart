import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

void main() {
  group('ListPresentationMailboxExtension - withoutVirtualMailbox', () {
    PresentationMailbox createMailbox(
      String idVal, {
      Role? role,
      String? name,
      String? parentIdVal,
    }) {
      return PresentationMailbox(
        MailboxId(Id(idVal)),
        role: role,
        name: name != null ? MailboxName(name) : null,
        parentId: parentIdVal != null ? MailboxId(Id(parentIdVal)) : null,
      );
    }

    late PresentationMailbox inbox;
    late PresentationMailbox sent;
    late PresentationMailbox trash;
    late PresentationMailbox customFolder;
    late PresentationMailbox favorite;
    late PresentationMailbox actionRequired;
    late PresentationMailbox subFolderOfVirtual;

    setUp(() {
      inbox = createMailbox(
        'mb_inbox',
        role: PresentationMailbox.roleInbox,
        name: 'Inbox',
      );
      sent = createMailbox(
        'mb_sent',
        role: PresentationMailbox.roleSent,
        name: 'Sent',
      );
      trash = createMailbox(
        'mb_trash',
        role: PresentationMailbox.roleTrash,
        name: 'Trash',
      );
      customFolder = createMailbox(
        'mb_custom',
        role: null,
        name: 'User Custom Folder',
      );

      favorite = createMailbox(
        'mb_fav',
        role: PresentationMailbox.roleFavorite,
        name: 'Starred',
      );
      actionRequired = createMailbox(
        'mb_act',
        role: PresentationMailbox.roleActionRequired,
        name: 'Needs Action',
      );

      subFolderOfVirtual = createMailbox(
        'mb_sub',
        parentIdVal: 'mb_fav',
        role: null,
        name: 'Sub of Favorite',
      );
    });

    test('Should remove "Favorite" (Starred) folder', () {
      final input = [inbox, favorite, sent];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 2);
      expect(result, containsAll([inbox, sent]));
      expect(result, isNot(contains(favorite)));
    });

    test('Should remove "Action Required" folder', () {
      final input = [inbox, actionRequired, sent];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 2);
      expect(result, containsAll([inbox, sent]));
      expect(result, isNot(contains(actionRequired)));
    });

    test('Should remove BOTH virtual folders if present', () {
      final input = [inbox, favorite, actionRequired, sent];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 2);
      expect(result, containsAll([inbox, sent]));
    });

    test('Should keep all standard folders (Inbox, Sent, Trash, Custom)', () {
      final input = [inbox, sent, trash, customFolder];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 4);
      expect(result, equals(input));
    });

    test('Should return empty list if input is empty', () {
      final List<PresentationMailbox> input = [];
      final result = input.withoutVirtualMailbox;
      expect(result, isEmpty);
    });

    test('Should return empty list if input contains ONLY virtual folders', () {
      final input = [favorite, actionRequired];
      final result = input.withoutVirtualMailbox;
      expect(result, isEmpty);
    });

    test('Should handle duplicates of virtual folders (remove all instances)',
        () {
      final input = [inbox, favorite, favorite, sent];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 2);
      expect(result, containsAll([inbox, sent]));
    });

    test(
        'Should NOT remove folders with similar role names (e.g., "favorites" vs "favorite")',
        () {
      final similarRoleBox = createMailbox('mb_sim', role: Role('favorites'));

      final input = [inbox, similarRoleBox];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 2);
      expect(result, contains(similarRoleBox));
    });

    test(
        'Should NOT remove folders with different case roles (e.g., "FAVORITE")',
        () {
      final upperCaseRoleBox =
          createMailbox('mb_upper', role: Role('FAVORITE'));

      final input = [inbox, upperCaseRoleBox];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 2);
      expect(result, contains(upperCaseRoleBox));
    });

    test('Should NOT mutate the original list', () {
      final input = [inbox, favorite, sent];
      final originalLength = input.length;

      final _ = input.withoutVirtualMailbox;

      expect(input.length, originalLength);
      expect(input, contains(favorite));
    });

    test('Should preserve object identity (return same instances)', () {
      final input = [inbox, sent];
      final result = input.withoutVirtualMailbox;

      expect(result[0], same(inbox));
      expect(result[1], same(sent));
    });

    test('Should preserve the relative order of remaining items', () {
      final input = [inbox, favorite, customFolder, actionRequired, sent];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 3);
      expect(result[0], inbox);
      expect(result[1], customFolder);
      expect(result[2], sent);
    });

    test('Should NOT remove a child folder just because its parent is virtual',
        () {
      final input = [favorite, subFolderOfVirtual];
      final result = input.withoutVirtualMailbox;

      expect(result.length, 1);
      expect(result.first, subFolderOfVirtual);
    });

    test('Should handle large lists efficiently', () {
      final largeList = List.generate(1000, (index) {
        if (index % 2 == 0) {
          return createMailbox(
            'id_$index',
            role: PresentationMailbox.roleInbox,
          );
        } else {
          return createMailbox(
            'id_$index',
            role: PresentationMailbox.roleFavorite,
          );
        }
      });

      final stopwatch = Stopwatch()..start();
      final result = largeList.withoutVirtualMailbox;
      stopwatch.stop();

      expect(result.length, 500);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
