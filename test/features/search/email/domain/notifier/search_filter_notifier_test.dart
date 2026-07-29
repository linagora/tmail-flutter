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
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

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

  group('toggleStarred', () {
    final flagged = KeyWordIdentifier.emailFlagged.value;

    test('adds the flagged keyword when starred, keeping other keywords', () {
      notifierOf().setHasKeywords({'custom'}.asSearchFilterKeywordSet());

      notifierOf().toggleStarred(true.asSearchFilterToggle());

      expect(stateOf().hasKeyword, {'custom', flagged});
    });

    test('removes only the flagged keyword when unstarred', () {
      notifierOf().setHasKeywords({'custom', flagged}.asSearchFilterKeywordSet());

      notifierOf().toggleStarred(false.asSearchFilterToggle());

      expect(stateOf().hasKeyword, {'custom'});
    });
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
      ));

      expect(stateOf().subject, 'invoice'); // intent preserved
      expect(stateOf().startDate, startDate);
      expect(stateOf().endDate, endDate);
      expect(stateOf().before, isNull);
      expect(stateOf().after, isNull);
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
