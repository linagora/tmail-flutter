import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/quick_search_filter_action_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  QuickSearchFilterActionNotifier actionNotifier() =>
      container.read(quickSearchFilterActionProvider.notifier);

  test('selectQuickSearchFilter mutates filter and requests search', () {
    final before = container.read(quickSearchFilterActionProvider);

    final applied = actionNotifier()
        .selectQuickSearchFilter(QuickSearchFilter.hasAttachment);

    expect(applied, isTrue);
    expect(container.read(searchFilterProvider).hasAttachment, isTrue);
    expect(container.read(quickSearchFilterActionProvider), before.next);
  });

  test('deleteQuickSearchFilter mutates filter and requests search', () {
    actionNotifier().selectQuickSearchFilter(QuickSearchFilter.hasAttachment);
    final before = container.read(quickSearchFilterActionProvider);

    final applied = actionNotifier()
        .deleteQuickSearchFilter(QuickSearchFilter.hasAttachment);

    expect(applied, isTrue);
    expect(container.read(searchFilterProvider).hasAttachment, isFalse);
    expect(container.read(quickSearchFilterActionProvider), before.next);
  });

  test('mutateAndSearch applies the mutation to the committed filter and '
      'requests search', () {
    final mailbox = PresentationMailbox(
      MailboxId(Id('inbox-id')),
      name: MailboxName('Inbox'),
    );
    final before = container.read(quickSearchFilterActionProvider);

    actionNotifier().mutateAndSearch((filter) {
      filter.setSortOrder(EmailSortOrderType.mostRecent);
      filter.setMailbox(mailbox);
    });

    final filter = container.read(searchFilterProvider);
    expect(filter.sortOrderType, EmailSortOrderType.mostRecent);
    expect(filter.mailbox, mailbox);
    expect(container.read(quickSearchFilterActionProvider), before.next);
  });

  test('mutateAndSearch requests exactly one search per call', () {
    final before = container.read(quickSearchFilterActionProvider);

    actionNotifier().mutateAndSearch(
      (filter) => filter.setLabel(Label(id: Id('work'), displayName: 'Work')),
    );
    actionNotifier().mutateAndSearch(
      (filter) => filter.setReceiveTime(EmailReceiveTimeType.last7Days),
    );

    expect(container.read(quickSearchFilterActionProvider), before.next.next);
  });

  test('selectQuickSearchFilter returns false and skips search when the '
      'filter has no select action', () {
    final before = container.read(quickSearchFilterActionProvider);

    final applied =
        actionNotifier().selectQuickSearchFilter(QuickSearchFilter.folder);

    expect(applied, isFalse);
    expect(container.read(quickSearchFilterActionProvider), before);
  });

  test('deleteQuickSearchFilter returns false and skips search when the '
      'filter has no delete action', () {
    final before = container.read(quickSearchFilterActionProvider);

    final applied =
        actionNotifier().deleteQuickSearchFilter(QuickSearchFilter.fromMe);

    expect(applied, isFalse);
    expect(container.read(quickSearchFilterActionProvider), before);
  });
}
