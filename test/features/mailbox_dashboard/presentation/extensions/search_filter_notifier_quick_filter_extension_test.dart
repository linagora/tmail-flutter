import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/search_filter_notifier_quick_filter_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  SearchFilterNotifier notifier() =>
      container.read(searchFilterProvider.notifier);
  SearchEmailFilter state() => container.read(searchFilterProvider);

  test('selectQuickSearchFilter applies direct quick filters', () {
    expect(
      notifier().selectQuickSearchFilter(QuickSearchFilter.hasAttachment),
      isTrue,
    );
    expect(notifier().selectQuickSearchFilter(QuickSearchFilter.starred), isTrue);
    expect(notifier().selectQuickSearchFilter(QuickSearchFilter.unread), isTrue);
    expect(notifier().selectQuickSearchFilter(QuickSearchFilter.events), isTrue);
    expect(notifier().selectQuickSearchFilter(QuickSearchFilter.dateTime), isFalse);

    expect(state().hasAttachment, isTrue);
    expect(state().hasKeyword, contains(KeyWordIdentifier.emailFlagged.value));
    expect(state().unread, isTrue);
    expect(state().notIncludeEvents, isTrue);
  });

  test('deleteQuickSearchFilter clears mapped quick filters', () {
    final mailbox = PresentationMailbox(
      MailboxId(Id('inbox-id')),
      name: MailboxName('Inbox'),
    );
    final label = Label(id: Id('label-id'), displayName: 'Work');
    final start = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
    final end = UTCDate(DateTime.parse('2026-01-07T00:00:00.000Z'));

    notifier().set(SearchEmailFilter(
      from: {'alice@example.com'},
      to: {'bob@example.com'},
      mailbox: mailbox,
      hasAttachment: true,
      unread: true,
      notIncludeEvents: true,
      hasKeyword: {KeyWordIdentifier.emailFlagged.value},
      sortOrderType: EmailSortOrderType.oldest,
      emailReceiveTimeType: EmailReceiveTimeType.customRange,
      startDate: start,
      endDate: end,
      label: label,
    ));

    for (final filter in [
      QuickSearchFilter.dateTime,
      QuickSearchFilter.sortBy,
      QuickSearchFilter.from,
      QuickSearchFilter.hasAttachment,
      QuickSearchFilter.to,
      QuickSearchFilter.folder,
      QuickSearchFilter.labels,
      QuickSearchFilter.starred,
      QuickSearchFilter.unread,
      QuickSearchFilter.events,
    ]) {
      expect(notifier().deleteQuickSearchFilter(filter), isTrue);
    }
    expect(notifier().deleteQuickSearchFilter(QuickSearchFilter.last7Days), isFalse);

    expect(state().emailReceiveTimeType, EmailReceiveTimeType.allTime);
    expect(state().startDate, isNull);
    expect(state().endDate, isNull);
    expect(state().sortOrderType, SearchEmailFilter.defaultSortOrder);
    expect(state().from, isEmpty);
    expect(state().to, isEmpty);
    expect(state().mailbox, isNull);
    expect(state().hasAttachment, isFalse);
    expect(state().label, isNull);
    expect(state().hasKeyword, isEmpty);
    expect(state().unread, isFalse);
    expect(state().notIncludeEvents, isFalse);
  });
}
