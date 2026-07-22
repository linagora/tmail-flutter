import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

void main() {
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
}
