import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';

void main() {
  PresentationEmail emailWith(String id) =>
      PresentationEmail(id: EmailId(Id(id)));

  group('SearchEmailResult', () {
    test('empty() has no emails, cannot load more, load-more is idle', () {
      final result = SearchEmailResult.empty();

      expect(result.emails, isEmpty);
      expect(result.canLoadMore, isFalse);
      expect(result.loadMore, LoadMoreState.idle);
    });

    test('copyWith replaces only the provided fields', () {
      final base = SearchEmailResult(emails: [emailWith('a')], canLoadMore: true);

      final onlyEmails = base.copyWith(emails: [emailWith('b')]);
      expect(onlyEmails.emails.single.id, EmailId(Id('b')));
      expect(onlyEmails.canLoadMore, isTrue);
      expect(onlyEmails.loadMore, LoadMoreState.idle);

      final onlyFlag = base.copyWith(canLoadMore: false);
      expect(onlyFlag.emails, base.emails);
      expect(onlyFlag.canLoadMore, isFalse);

      final onlyLoadMore = base.copyWith(loadMore: LoadMoreState.failure);
      expect(onlyLoadMore.loadMore, LoadMoreState.failure);
      expect(onlyLoadMore.emails, base.emails);
      expect(onlyLoadMore.canLoadMore, isTrue);
    });

    test('value equality is by emails, canLoadMore and loadMore', () {
      expect(
        SearchEmailResult(emails: [emailWith('a')], canLoadMore: true),
        SearchEmailResult(emails: [emailWith('a')], canLoadMore: true),
      );
      expect(
        SearchEmailResult(emails: [emailWith('a')], canLoadMore: true),
        isNot(SearchEmailResult(emails: [emailWith('a')], canLoadMore: false)),
      );
      expect(
        SearchEmailResult(emails: [emailWith('a')], canLoadMore: true),
        isNot(SearchEmailResult(
          emails: [emailWith('a')],
          canLoadMore: true,
          loadMore: LoadMoreState.failure,
        )),
      );
    });
  });
}
