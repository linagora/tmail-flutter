import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_draft_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  SearchFilterDraftNotifier notifierOf() =>
      container.read(searchFilterDraftProvider.notifier);
  SearchEmailFilter stateOf() =>
      container.read(searchFilterDraftProvider);

  final committed = SearchEmailFilter(
    from: {'alice@example.com'},
    subject: 'invoice',
    unread: true,
    hasAttachment: true,
    sortOrderType: EmailSortOrderType.oldest,
  );

  test('seedFrom(committed) makes the draft equal the committed snapshot', () {
    notifierOf().seedFrom(committed);

    expect(stateOf(), committed);
  });

  test('seedFrom strips any pagination cursor from the seed', () {
    final date = UTCDate(DateTime.parse('2026-03-15T10:00:00.000Z'));

    notifierOf().seedFrom(SearchEmailFilter(
      subject: 'invoice',
      before: date,
      after: date,
      position: 5,
    ));

    expect(stateOf().subject, 'invoice'); // intent preserved
    expect(stateOf().before, isNull);
    expect(stateOf().after, isNull);
    expect(stateOf().position, isNull);
  });

  test('seedFrom then update keeps committed ⊆ draft (containment invariant)', () {
    notifierOf().seedFrom(committed);
    notifierOf().update(subjectOption: const Some('updated'));

    // Edited field reflects the draft change...
    expect(stateOf().subject, 'updated');
    // ...every other committed value is still present in the draft.
    expect(stateOf().from, committed.from);
    expect(stateOf().unread, committed.unread);
    expect(stateOf().hasAttachment, committed.hasAttachment);
    expect(stateOf().sortOrderType, committed.sortOrderType);
  });

  test('clear() preserves sortOrderType and resets the rest', () {
    notifierOf().seedFrom(committed);

    notifierOf().clear();

    expect(stateOf(), SearchEmailFilter.withSortOrder(EmailSortOrderType.oldest));
  });

  test('draft and committed are isolated providers (editing one never touches the other)', () {
    // Editing the committed SSOT must not leak into the draft...
    container.read(searchFilterProvider.notifier).update(unreadOption: const Some(true));
    expect(stateOf().unread, isFalse);

    // ...and editing the draft must not leak into the committed SSOT.
    notifierOf().update(subjectOption: const Some('draft-only'));
    expect(container.read(searchFilterProvider).subject, isNull);
  });
}
