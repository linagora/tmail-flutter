import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  SearchFilterNotifier notifierOf() =>
      container.read(searchFilterProvider.notifier);
  SearchEmailFilter stateOf() => container.read(searchFilterProvider);

  test('build() starts at SearchEmailFilter.initial()', () {
    expect(stateOf(), SearchEmailFilter.initial());
  });

  group('update', () {
    test('sets only the provided field, leaving cursors/bounds untouched', () {
      notifierOf().update(unreadOption: const Some(true));

      expect(stateOf().unread, isTrue);
      expect(stateOf().before, isNull);
      expect(stateOf().after, isNull);
      expect(stateOf().startDate, isNull);
    });

    test('sets the startDate/endDate range bounds (kept as user intent)', () {
      final start = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
      final end = UTCDate(DateTime.parse('2026-06-01T00:00:00.000Z'));

      notifierOf().update(
        startDateOption: optionOf(start),
        endDateOption: optionOf(end),
      );

      expect(stateOf().startDate, start);
      expect(stateOf().endDate, end);
    });

    test('successive updates accumulate on independent fields', () {
      notifierOf().update(unreadOption: const Some(true));
      notifierOf().update(hasAttachmentOption: const Some(true));

      expect(stateOf().unread, isTrue);
      expect(stateOf().hasAttachment, isTrue);
    });
  });

  group('set', () {
    test('fully replaces user-intent state', () {
      final replacement = SearchEmailFilter(
        subject: 'invoice',
        unread: true,
        sortOrderType: EmailSortOrderType.oldest,
      );

      notifierOf().set(replacement);

      expect(stateOf(), replacement);
    });

    test('strips pagination cursors riding in on a full replacement', () {
      final cursor = UTCDate(DateTime.parse('2026-03-15T10:00:00.000Z'));
      final startDate = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
      final endDate = UTCDate(DateTime.parse('2026-06-01T00:00:00.000Z'));

      notifierOf().set(SearchEmailFilter(
        subject: 'invoice',
        before: cursor,
        after: cursor,
        startDate: startDate,
        endDate: endDate,
        position: 5,
      ));

      expect(stateOf().subject, 'invoice'); // intent preserved
      expect(stateOf().startDate, startDate);
      expect(stateOf().endDate, endDate);
      expect(stateOf().before, isNull);
      expect(stateOf().after, isNull);
      expect(stateOf().position, isNull);
    });

    test('snapshots filter sets instead of aliasing replacement state', () {
      final replacement = SearchEmailFilter(
        from: {'alice@example.com'},
        to: {'bob@example.com'},
        notKeyword: {'draft'},
        hasKeyword: {'flagged'},
      );

      notifierOf().set(replacement);
      replacement.from.add('mallory@example.com');
      replacement.to.add('mallory@example.com');
      replacement.notKeyword.add('leak');
      replacement.hasKeyword.add('leak');

      expect(stateOf().from, {'alice@example.com'});
      expect(stateOf().to, {'bob@example.com'});
      expect(stateOf().notKeyword, {'draft'});
      expect(stateOf().hasKeyword, {'flagged'});
    });
  });

  test('clear() preserves sortOrderType and resets every other field', () {
    notifierOf().set(SearchEmailFilter(
      subject: 'invoice',
      unread: true,
      hasAttachment: true,
      sortOrderType: EmailSortOrderType.oldest,
    ));

    notifierOf().clear();

    expect(stateOf().sortOrderType, EmailSortOrderType.oldest);
    expect(stateOf(), SearchEmailFilter.withSortOrder(EmailSortOrderType.oldest));
    expect(stateOf().subject, isNull);
    expect(stateOf().unread, isFalse);
    expect(stateOf().hasAttachment, isFalse);
  });
}
