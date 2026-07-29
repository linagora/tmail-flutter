import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

void main() {
  group('FilterMessageOption.filterEmail', () {
    test('all matches every email', () {
      expect(FilterMessageOption.all.filterEmail(Email()), isTrue);
    });

    test('unread matches only emails without the seen keyword', () {
      expect(FilterMessageOption.unread.filterEmail(Email()), isTrue);
      expect(
        FilterMessageOption.unread
            .filterEmail(Email(keywords: {KeyWordIdentifier.emailSeen: true})),
        isFalse,
      );
    });

    test('attachments matches only emails with attachments', () {
      expect(
        FilterMessageOption.attachments.filterEmail(Email(hasAttachment: true)),
        isTrue,
      );
      expect(FilterMessageOption.attachments.filterEmail(Email()), isFalse);
    });

    test('starred matches only flagged emails', () {
      expect(
        FilterMessageOption.starred.filterEmail(
          Email(keywords: {KeyWordIdentifier.emailFlagged: true}),
        ),
        isTrue,
      );
      expect(FilterMessageOption.starred.filterEmail(Email()), isFalse);
    });
  });

  group('FilterMessageOption.applyTo', () {
    test('all leaves the filter unchanged', () {
      final filter = SearchEmailFilter.initial();

      final result = FilterMessageOption.all.applyTo(filter);

      expect(result, filter);
    });

    test('unread sets the unread flag', () {
      final result =
          FilterMessageOption.unread.applyTo(SearchEmailFilter.initial());

      expect(result.unread, isTrue);
    });

    test('attachments sets the hasAttachment flag', () {
      final result =
          FilterMessageOption.attachments.applyTo(SearchEmailFilter.initial());

      expect(result.hasAttachment, isTrue);
    });

    test('starred adds the flagged keyword to hasKeyword', () {
      final result =
          FilterMessageOption.starred.applyTo(SearchEmailFilter.initial());

      expect(
        result.hasKeyword,
        contains(KeyWordIdentifier.emailFlagged.value),
      );
    });

    test('starred merges the flagged keyword with existing keywords', () {
      final filter = SearchEmailFilter(hasKeyword: {'existing-keyword'});

      final result = FilterMessageOption.starred.applyTo(filter);

      expect(
        result.hasKeyword,
        containsAll(<String>{
          'existing-keyword',
          KeyWordIdentifier.emailFlagged.value,
        }),
      );
    });

    test('preserves other user-intent fields already on the filter', () {
      final filter = SearchEmailFilter(subject: 'invoice');

      final result = FilterMessageOption.unread.applyTo(filter);

      expect(result.subject, 'invoice');
      expect(result.unread, isTrue);
    });
  });

  group('FilterMessageOption.isActiveIn', () {
    test('all is never active', () {
      expect(
        FilterMessageOption.all.isActiveIn(SearchEmailFilter(unread: true)),
        isFalse,
      );
    });

    test('unread reflects the unread flag', () {
      expect(
        FilterMessageOption.unread.isActiveIn(SearchEmailFilter(unread: true)),
        isTrue,
      );
      expect(
        FilterMessageOption.unread.isActiveIn(SearchEmailFilter.initial()),
        isFalse,
      );
    });

    test('attachments reflects the hasAttachment flag', () {
      expect(
        FilterMessageOption.attachments
            .isActiveIn(SearchEmailFilter(hasAttachment: true)),
        isTrue,
      );
    });

    test('starred reflects the flagged keyword', () {
      expect(
        FilterMessageOption.starred.isActiveIn(
          SearchEmailFilter(hasKeyword: {KeyWordIdentifier.emailFlagged.value}),
        ),
        isTrue,
      );
      expect(
        FilterMessageOption.starred.isActiveIn(SearchEmailFilter.initial()),
        isFalse,
      );
    });
  });

  group('FilterMessageOption.removeFrom', () {
    test('all leaves the filter unchanged', () {
      final filter = SearchEmailFilter(unread: true);

      expect(FilterMessageOption.all.removeFrom(filter), filter);
    });

    test('unread clears the unread flag', () {
      final result =
          FilterMessageOption.unread.removeFrom(SearchEmailFilter(unread: true));

      expect(result.unread, isFalse);
    });

    test('attachments clears the hasAttachment flag', () {
      final result = FilterMessageOption.attachments
          .removeFrom(SearchEmailFilter(hasAttachment: true));

      expect(result.hasAttachment, isFalse);
    });

    test('starred removes only the flagged keyword, keeping the others', () {
      final filter = SearchEmailFilter(
        hasKeyword: {KeyWordIdentifier.emailFlagged.value, 'other-keyword'},
      );

      final result = FilterMessageOption.starred.removeFrom(filter);

      expect(result.isContainFlagged, isFalse);
      expect(result.hasKeyword, contains('other-keyword'));
    });
  });
}
