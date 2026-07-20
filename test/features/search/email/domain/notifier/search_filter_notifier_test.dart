import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

typedef FilterSnapshot = ({
  bool unread,
  bool hasAttachment,
  bool starred,
});

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  SearchFilterNotifier notifierOf() =>
      container.read(searchFilterProvider.notifier);
  SearchEmailFilter stateOf() => container.read(searchFilterProvider);

  FilterSnapshot filterSnapshot({
    bool unread = false,
    bool hasAttachment = false,
    bool starred = false,
  }) => (
    unread: unread,
    hasAttachment: hasAttachment,
    starred: starred,
  );

  void expectFilter(FilterSnapshot expected) {
    expect(stateOf().unread, expected.unread ? isTrue : isFalse);
    expect(stateOf().hasAttachment, expected.hasAttachment ? isTrue : isFalse);
    expect(
      stateOf().hasKeyword,
      expected.starred
          ? contains(KeyWordIdentifier.emailFlagged.value)
          : isEmpty,
    );
    expect(stateOf().isContainFlagged, expected.starred ? isTrue : isFalse);
  }

  test('build() starts at SearchEmailFilter.initial()', () {
    expect(stateOf(), SearchEmailFilter.initial());
  });

  group('update', () {
    test('sets only the provided field, leaving cursors/bounds untouched', () {
      notifierOf().update(SearchFilterPatch()..unreadOption = const Some(true));

      expect(stateOf().unread, isTrue);
      expect(stateOf().before, isNull);
      expect(stateOf().after, isNull);
      expect(stateOf().startDate, isNull);
    });

    test('sets the startDate/endDate range bounds (kept as user intent)', () {
      final start = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
      final end = UTCDate(DateTime.parse('2026-06-01T00:00:00.000Z'));

      notifierOf().update(SearchFilterPatch()
        ..startDateOption = optionOf(start)
        ..endDateOption = optionOf(end));

      expect(stateOf().startDate, start);
      expect(stateOf().endDate, end);
    });

    test('successive updates accumulate on independent fields', () {
      notifierOf().update(SearchFilterPatch()..unreadOption = const Some(true));
      notifierOf().update(SearchFilterPatch()
        ..hasAttachmentOption = const Some(true));

      expect(stateOf().unread, isTrue);
      expect(stateOf().hasAttachment, isTrue);
    });
  });

  group('single-field helpers', () {
    test('setSubject / setText trim input and clear blank values', () {
      notifierOf().setSubject('  invoice  '.asSearchFilterTextInput());
      notifierOf().setText('  hello  '.asSearchFilterTextInput());

      expect(stateOf().subject, 'invoice');
      expect(stateOf().text, SearchQuery('hello'));

      notifierOf().setSubject('   '.asSearchFilterTextInput());
      notifierOf().setText('   '.asSearchFilterTextInput());

      expect(stateOf().subject, isNull);
      expect(stateOf().text, isNull);
    });

    test('setNotKeywords splits comma input and clears blank values', () {
      notifierOf().setNotKeywords(' draft, spam '.asSearchFilterTextInput());

      expect(stateOf().notKeyword, {'draft', 'spam'});

      notifierOf().setNotKeywords('   '.asSearchFilterTextInput());

      expect(stateOf().notKeyword, isEmpty);
    });

    test('boolean and sort helpers mutate only their fields', () {
      notifierOf().setHasAttachment(true.asSearchFilterToggle());
      notifierOf().setUnread(true.asSearchFilterToggle());
      notifierOf().setNotIncludeEvents(true.asSearchFilterToggle());
      notifierOf().setSortOrder(EmailSortOrderType.oldest);

      expect(stateOf().hasAttachment, isTrue);
      expect(stateOf().unread, isTrue);
      expect(stateOf().notIncludeEvents, isTrue);
      expect(stateOf().sortOrderType, EmailSortOrderType.oldest);

      notifierOf().setUnread(false.asSearchFilterToggle());
      notifierOf().setNotIncludeEvents(false.asSearchFilterToggle());

      expect(stateOf().unread, isFalse);
      expect(stateOf().notIncludeEvents, isFalse);
    });

    test('setHasAttachment writes false when the checkbox is cleared', () {
      notifierOf().setHasAttachment(true.asSearchFilterToggle());
      expect(stateOf().hasAttachment, isTrue);

      notifierOf().setHasAttachment(false.asSearchFilterToggle());

      expect(stateOf().hasAttachment, isFalse);
    });

    test('setSenders / setRecipients replace the address sets', () {
      notifierOf().setSenders(
        {'alice@example.com', 'bob@example.com'}.asSearchFilterEmailSet());
      notifierOf().setRecipients(
        {'carol@example.com'}.asSearchFilterEmailSet());

      expect(stateOf().from, {'alice@example.com', 'bob@example.com'});
      expect(stateOf().to, {'carol@example.com'});

      notifierOf().setSenders(<String>{}.asSearchFilterEmailSet());
      notifierOf().setRecipients(<String>{}.asSearchFilterEmailSet());

      expect(stateOf().from, isEmpty);
      expect(stateOf().to, isEmpty);
    });

    test('setMailbox selects a mailbox and clears it when null is passed', () {
      final mailbox = PresentationMailbox(
        MailboxId(Id('inbox-id')),
        name: MailboxName('Inbox'),
      );

      notifierOf().setMailbox(mailbox);
      expect(stateOf().mailbox, mailbox);

      notifierOf().setMailbox(null);
      expect(stateOf().mailbox, isNull);
    });

    test('clear helpers reset their fields', () {
      final mailbox = PresentationMailbox(
        MailboxId(Id('inbox-id')),
        name: MailboxName('Inbox'),
      );

      notifierOf().setSenders({'alice@example.com'}.asSearchFilterEmailSet());
      notifierOf().setRecipients({'bob@example.com'}.asSearchFilterEmailSet());
      notifierOf().setMailbox(mailbox);

      notifierOf().clearSenders();
      notifierOf().clearRecipients();
      notifierOf().clearMailbox();

      expect(stateOf().from, isEmpty);
      expect(stateOf().to, isEmpty);
      expect(stateOf().mailbox, isNull);
    });

    test('setReceiveTime stores receive-time bounds', () {
      final start = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
      final end = UTCDate(DateTime.parse('2026-01-07T00:00:00.000Z'));

      notifierOf().setReceiveTime(
        EmailReceiveTimeType.customRange,
        startDate: start,
        endDate: end,
      );

      expect(stateOf().emailReceiveTimeType, EmailReceiveTimeType.customRange);
      expect(stateOf().startDate, start);
      expect(stateOf().endDate, end);
    });

    test('setLabel assigns and clears the label without toggling by id', () {
      final workLabel = Label(id: Id('work-label'), displayName: 'Work');

      notifierOf().setLabel(workLabel);
      notifierOf().setLabel(workLabel);
      expect(stateOf().label, workLabel);

      notifierOf().setLabel(null);
      expect(stateOf().label, isNull);
    });

    test('toggleLabel selects, clears, and replaces labels by id', () {
      final workLabel = Label(id: Id('work-label'), displayName: 'Work');
      final travelLabel = Label(id: Id('travel-label'), displayName: 'Travel');

      notifierOf().toggleLabel(workLabel);
      expect(stateOf().label, workLabel);

      notifierOf().toggleLabel(workLabel);
      expect(stateOf().label, isNull);

      notifierOf().toggleLabel(workLabel);
      notifierOf().toggleLabel(travelLabel);
      expect(stateOf().label, travelLabel);
    });

    test('resetReceiveTime clears the receive-time range as one invariant', () {
      final start = UTCDate(DateTime.utc(2026, 1, 1));
      final end = UTCDate(DateTime.utc(2026, 1, 7));
      notifierOf().update(SearchFilterPatch()
        ..emailReceiveTimeTypeOption = const Some(EmailReceiveTimeType.customRange)
        ..startDateOption = optionOf(start)
        ..endDateOption = optionOf(end));

      notifierOf().resetReceiveTime();

      expect(stateOf().emailReceiveTimeType, EmailReceiveTimeType.allTime);
      expect(stateOf().startDate, isNull);
      expect(stateOf().endDate, isNull);
    });

    test('clearLabel always removes the selected label', () {
      notifierOf().toggleLabel(
        Label(id: Id('work-label'), displayName: 'Work'),
      );

      notifierOf().clearLabel();

      expect(stateOf().label, isNull);
    });
  });

  group('setStarred', () {
    final flagged = KeyWordIdentifier.emailFlagged.value;

    test('adds the flagged keyword when starred, keeping other keywords', () {
      notifierOf().setHasKeywords({'custom'}.asSearchFilterKeywordSet());

      notifierOf().setStarred(true.asSearchFilterToggle());

      expect(stateOf().hasKeyword, {'custom', flagged});
    });

    test('removes only the flagged keyword when unstarred', () {
      notifierOf().setHasKeywords({'custom', flagged}.asSearchFilterKeywordSet());

      notifierOf().setStarred(false.asSearchFilterToggle());

      expect(stateOf().hasKeyword, {'custom'});
    });
  });

  group('toggleStarred', () {
    final flagged = KeyWordIdentifier.emailFlagged.value;

    test('adds the flagged keyword when it is not present', () {
      notifierOf().setHasKeywords({'custom'}.asSearchFilterKeywordSet());

      notifierOf().toggleStarred();

      expect(stateOf().hasKeyword, {'custom', flagged});
    });

    test('removes the flagged keyword when it is present', () {
      notifierOf().setHasKeywords({'custom', flagged}.asSearchFilterKeywordSet());

      notifierOf().toggleStarred();

      expect(stateOf().hasKeyword, {'custom'});
    });
  });

  group('keyword helpers', () {
    final flagged = KeyWordIdentifier.emailFlagged.value;

    test('addHasKeyword and removeHasKeyword preserve other keywords', () {
      notifierOf().setHasKeywords({'custom'}.asSearchFilterKeywordSet());

      notifierOf().addHasKeyword(flagged);
      expect(stateOf().hasKeyword, {'custom', flagged});

      notifierOf().removeHasKeyword(flagged);
      expect(stateOf().hasKeyword, {'custom'});
    });
  });

  group('filter message option helpers', () {
    final emptyFilter = filterSnapshot();
    final unreadFilter = filterSnapshot(unread: true);
    final attachmentFilter = filterSnapshot(hasAttachment: true);
    final starredFilter = filterSnapshot(starred: true);
    final unreadAndAttachmentFilter = filterSnapshot(
      unread: true,
      hasAttachment: true,
    );

    final seedCases = [
      (
        name: 'unread option seeds the unread search filter',
        option: FilterMessageOption.unread,
        expected: unreadFilter,
      ),
      (
        name: 'attachments option seeds the has-attachment search filter',
        option: FilterMessageOption.attachments,
        expected: attachmentFilter,
      ),
      (
        name: 'starred option seeds the flagged keyword search filter',
        option: FilterMessageOption.starred,
        expected: starredFilter,
      ),
      (
        name: 'all option leaves the search filter untouched',
        option: FilterMessageOption.all,
        expected: emptyFilter,
      ),
    ];

    for (final seedCase in seedCases) {
      test(seedCase.name, () {
        notifierOf().applyFilterMessageOption(seedCase.option);

        expectFilter(seedCase.expected);
      });
    }

    void testSyncFilterMessageOptionChange(
      String description, {
      FilterMessageOption? seed,
      FilterSnapshot? beforeSync,
      required FilterMessageOption previous,
      required FilterMessageOption next,
      required FilterSnapshot expected,
    }) {
      test(description, () {
        if (seed != null) {
          notifierOf().applyFilterMessageOption(seed);
        }
        if (beforeSync != null) {
          expectFilter(beforeSync);
        }

        notifierOf().syncFilterMessageOptionChange(
          previous: previous,
          next: next,
        );

        expectFilter(expected);
      });
    }

    testSyncFilterMessageOptionChange(
      'selecting an option turns its toggle on',
      previous: FilterMessageOption.all,
      next: FilterMessageOption.unread,
      expected: unreadFilter,
    );

    testSyncFilterMessageOptionChange(
      'deselecting an option turns its toggle off',
      seed: FilterMessageOption.unread,
      beforeSync: unreadFilter,
      previous: FilterMessageOption.unread,
      next: FilterMessageOption.all,
      expected: emptyFilter,
    );

    testSyncFilterMessageOptionChange(
      'switching options clears the previous and sets the next',
      seed: FilterMessageOption.unread,
      previous: FilterMessageOption.unread,
      next: FilterMessageOption.attachments,
      expected: attachmentFilter,
    );

    testSyncFilterMessageOptionChange(
      'preserves an unrelated active toggle',
      seed: FilterMessageOption.attachments,
      previous: FilterMessageOption.all,
      next: FilterMessageOption.unread,
      expected: unreadAndAttachmentFilter,
    );

    testSyncFilterMessageOptionChange(
      'switching to starred sets the flagged keyword',
      previous: FilterMessageOption.all,
      next: FilterMessageOption.starred,
      expected: starredFilter,
    );

    testSyncFilterMessageOptionChange(
      'switching away from starred clears the flagged keyword',
      seed: FilterMessageOption.starred,
      beforeSync: starredFilter,
      previous: FilterMessageOption.starred,
      next: FilterMessageOption.unread,
      expected: unreadFilter,
    );
  });

  group('sender / recipient membership', () {
    test('addSender / removeSender mutate only the from set', () {
      notifierOf().addSender('alice@example.com'.asSearchFilterEmailAddress());
      notifierOf().addSender('bob@example.com'.asSearchFilterEmailAddress());
      expect(stateOf().from, {'alice@example.com', 'bob@example.com'});

      notifierOf().removeSender('alice@example.com'.asSearchFilterEmailAddress());
      expect(stateOf().from, {'bob@example.com'});
      expect(stateOf().to, isEmpty);
    });

    test('addRecipient / removeRecipient mutate only the to set', () {
      notifierOf().addRecipient('carol@example.com'.asSearchFilterEmailAddress());
      expect(stateOf().to, {'carol@example.com'});

      notifierOf().removeRecipient('carol@example.com'.asSearchFilterEmailAddress());
      expect(stateOf().to, isEmpty);
      expect(stateOf().from, isEmpty);
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
}
