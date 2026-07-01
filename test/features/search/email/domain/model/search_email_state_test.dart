import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_state.dart';

void main() {
  PresentationEmail emailWith(String id) =>
      PresentationEmail(id: EmailId(Id(id)));

  group('SearchEmailState', () {
    test('empty() has no emails and cannot load more', () {
      final state = SearchEmailState.empty();

      expect(state.emails, isEmpty);
      expect(state.canLoadMore, isFalse);
    });

    test('copyWith replaces only the provided fields', () {
      final base = SearchEmailState(emails: [emailWith('a')], canLoadMore: true);

      final onlyEmails = base.copyWith(emails: [emailWith('b')]);
      expect(onlyEmails.emails.single.id, EmailId(Id('b')));
      expect(onlyEmails.canLoadMore, isTrue);

      final onlyFlag = base.copyWith(canLoadMore: false);
      expect(onlyFlag.emails, base.emails);
      expect(onlyFlag.canLoadMore, isFalse);
    });

    test('value equality is by emails and canLoadMore', () {
      expect(
        SearchEmailState(emails: [emailWith('a')], canLoadMore: true),
        SearchEmailState(emails: [emailWith('a')], canLoadMore: true),
      );
      expect(
        SearchEmailState(emails: [emailWith('a')], canLoadMore: true),
        isNot(SearchEmailState(emails: [emailWith('a')], canLoadMore: false)),
      );
    });
  });
}
