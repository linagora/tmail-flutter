import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';

void main() {
  group('sorting_list_email_by_order_id_list test', () {
    test('sortingByOrderOfIdList method should return an ordered list of ids when of the same length', () {
      List<Id> ids = [
        Id('a'),
        Id('b'),
        Id('c'),
        Id('d'),
        Id('e')
      ];
      List<Email> emails = [
        Email(id: EmailId(Id('a'))),
        Email(id: EmailId(Id('c'))),
        Email(id: EmailId(Id('e'))),
        Email(id: EmailId(Id('d'))),
        Email(id: EmailId(Id('b')))
      ];

      List<Email> sortedEmails = emails.sortingByOrderOfIdList(ids);

      expect(
          sortedEmails.map((e) => e.id?.id.value),
          equals(['a', 'b', 'c', 'd', 'e'])
      );
    });

    test('sortingByOrderOfIdList method should return the original list when the length of the two lists is different', () {
      List<Id> ids = [
        Id('a'),
        Id('b'),
        Id('c'),
      ];
      List<Email> emails = [
        Email(id: EmailId(Id('a'))),
        Email(id: EmailId(Id('c'))),
        Email(id: EmailId(Id('e'))),
        Email(id: EmailId(Id('d'))),
        Email(id: EmailId(Id('b')))
      ];

      List<Email> sortedEmails = emails.sortingByOrderOfIdList(ids);

      expect(
          sortedEmails.map((e) => e.id?.id.value),
          equals(['a', 'c', 'e', 'd', 'b'])
      );
    });
  });
}