import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

LogicFilterOperator _assertAndOperator(dynamic result, int conditionsCount) {
  expect(result, isA<LogicFilterOperator>());
  final andFilter = result as LogicFilterOperator;
  expect(andFilter.operator, equals(Operator.AND));
  expect(andFilter.conditions.length, equals(conditionsCount));
  return andFilter;
}

void _assertEventsExclusionInAnd(LogicFilterOperator andFilter) {
  final eventsExclusion = andFilter.conditions
      .whereType<EmailFilterCondition>()
      .firstWhere(
        (c) => c.notKeyword == KeyWordIdentifierExtension.eventsMail.value,
      );
  expect(eventsExclusion.notKeyword, KeyWordIdentifierExtension.eventsMail.value);
}

LogicFilterOperator _actAndAssertAndWithEventsExclusion(
  SearchEmailFilter filter,
  int conditionsCount,
) {
  final result = filter.mappingToEmailFilterCondition();
  final andFilter = _assertAndOperator(result, conditionsCount);
  _assertEventsExclusionInAnd(andFilter);
  return andFilter;
}

void main() {
  group('SearchEmailFilter::test', () {
    group('generateFilterFromToField::test', () {
      late SearchEmailFilter searchEmailFilter;

      setUp(() {
        searchEmailFilter = SearchEmailFilter();
      });

      test('SHOULD generate a single filter WHEN "to" has one item', () {
        // Arrange
        searchEmailFilter = SearchEmailFilter(
          to: {'singleRecipient@example.com'},
        );

        // Act
        final filters = searchEmailFilter.generateFilterFromToField();

        // Assert
        expect(filters.length, 1);

        expect(filters.first, isA<LogicFilterOperator>());

        final filter = filters.first as LogicFilterOperator;
        expect(filter.operator, Operator.OR);

        expect(filter.conditions, {
          EmailFilterCondition(to: 'singleRecipient@example.com'),
          EmailFilterCondition(cc: 'singleRecipient@example.com'),
          EmailFilterCondition(bcc: 'singleRecipient@example.com'),
        });
      });

      test('SHOULD generate multiple from filters which combine with OR operator WHEN "to" has multiple items', () {
        // Arrange
        searchEmailFilter = SearchEmailFilter(
          to: {'recipient1@example.com', 'recipient2@example.com'},
        );

        // Act
        final filters = searchEmailFilter.generateFilterFromToField();

        // Assert
        expect(filters.length, 2);

        expect(filters[0], isA<LogicFilterOperator>());
        expect(filters[1], isA<LogicFilterOperator>());

        final filter1 = filters[0] as LogicFilterOperator;
        expect(filter1.operator, Operator.OR);
        expect(filter1.conditions, {
          EmailFilterCondition(to: 'recipient1@example.com'),
          EmailFilterCondition(cc: 'recipient1@example.com'),
          EmailFilterCondition(bcc: 'recipient1@example.com'),
        });

        final filter2 = filters[1] as LogicFilterOperator;
        expect(filter2.operator, Operator.OR);
        expect(filter2.conditions, {
          EmailFilterCondition(to: 'recipient2@example.com'),
          EmailFilterCondition(cc: 'recipient2@example.com'),
          EmailFilterCondition(bcc: 'recipient2@example.com'),
        });
      });
    });

    group('mappingToEmailFilterCondition::test', () {
      test('SHOULD return null WHEN no conditions are set and notIncludeEvents is false (default)', () {
        // Arrange
        final filter = SearchEmailFilter.initial();

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents defaults to false → no events-exclusion condition is added.
        // No other conditions → empty condition list → null.
        expect(result, isNull);
      });

      test('SHOULD return a single text EmailFilterCondition WHEN only text is provided and notIncludeEvents is false', () {
        // Arrange
        final filter = SearchEmailFilter(
          text: SearchQuery('example'),
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents defaults to false → no events-exclusion added.
        // Only the text condition is present, returned directly.
        expect(result, isA<EmailFilterCondition>());
        final emailCondition = result as EmailFilterCondition;
        expect(emailCondition.text, 'example');
      });

      test('SHOULD creates a filter with multiple "to" values using AND logic operator', () {
        // Arrange
        final filter = SearchEmailFilter(
          to: {'to1@example.com', 'to2@example.com'},
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // 2 "to" OR-conditions, no events-exclusion (notIncludeEvents = false) → AND of 2 conditions.
        expect(result, isA<LogicFilterOperator>());
        final logicOperator = result as LogicFilterOperator;
        expect(logicOperator.operator, Operator.AND);
        expect(logicOperator.conditions.length, equals(2));
        expect(
          logicOperator.conditions.whereType<EmailFilterCondition>().any(
            (condition) =>
                condition.notKeyword ==
                KeyWordIdentifierExtension.eventsMail.value,
          ),
          isFalse,
        );
      });

      test('SHOULD includes moreFilterCondition WHEN provided', () {
        // Arrange
        final moreCondition = EmailFilterCondition(text: 'moreFilter');
        final filter = SearchEmailFilter(
          text: SearchQuery('example'),
        );

        // Act
        final result = filter.mappingToEmailFilterCondition(moreFilterCondition: moreCondition);

        // Assert
        expect(result, isA<LogicFilterOperator>());
        final logicOperator = result as LogicFilterOperator;
        expect(logicOperator.conditions.contains(moreCondition), isTrue);
      });

      test('SHOULD combines multiple fields into an AND filter', () {
        // Arrange
        final filter = SearchEmailFilter(
          from: {'sender@example.com'},
          to: {'to@example.com'},
          text: SearchQuery('text'),
          subject: 'subject',
          notKeyword: {'keyword'},
          hasKeyword: {'hasKeyword'},
          mailbox: PresentationMailbox(MailboxId(Id('inbox-id')), name: MailboxName('Inbox')),
          emailReceiveTimeType: EmailReceiveTimeType.last7Days,
          hasAttachment: true,
          before: UTCDate(DateTime.parse('2024-10-30 12:00:00')),
          startDate: UTCDate(DateTime.parse('2024-10-30 12:00:00')),
          endDate: UTCDate(DateTime.parse('2024-10-31 12:00:00')),
          position: 0,
          sortOrderType: EmailSortOrderType.oldest,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        expect(result, isA<LogicFilterOperator>());
        final logicOperator = result as LogicFilterOperator;
        expect(logicOperator.operator, Operator.AND);
        expect(logicOperator.conditions.length, greaterThan(1));
      });

      test('SHOULD return a NOT LogicFilterOperator for notKeyword WHEN only notKeyword is given and notIncludeEvents is false', () {
        // Arrange
        final filter = SearchEmailFilter(
          notKeyword: {'hello'},
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents defaults to false → no events-exclusion added.
        // Only NOT(text=hello) → returned directly as a single LogicFilterOperator.
        expect(result, isA<LogicFilterOperator>());
        final notFilter = result as LogicFilterOperator;
        expect(notFilter.operator, equals(Operator.NOT));
        expect(notFilter.conditions.length, equals(1));

        final notCondition = notFilter.conditions.first as EmailFilterCondition;
        expect(notCondition.text, 'hello');
        expect(notCondition.notKeyword, isNull);
      });

      test(
        'SHOULD return a NOT LogicFilterOperator with multiple keywords WHEN only notKeyword list is given and notIncludeEvents is false',
      () {
        // Arrange
        final filter = SearchEmailFilter(
          notKeyword: {'hello', 'hi', 'bye'},
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents defaults to false → no events-exclusion added.
        // Only NOT(text=hello, text=hi, text=bye) → returned directly.
        expect(result, isA<LogicFilterOperator>());
        final notFilter = result as LogicFilterOperator;
        expect(notFilter.operator, equals(Operator.NOT));
        expect(notFilter.conditions.length, equals(3));

        final listEmailCondition = notFilter.conditions.map((e) => e as EmailFilterCondition).toList();
        expect(listEmailCondition[0].text, 'hello');
        expect(listEmailCondition[0].notKeyword, isNull);

        expect(listEmailCondition[1].text, 'hi');
        expect(listEmailCondition[1].notKeyword, isNull);

        expect(listEmailCondition[2].text, 'bye');
        expect(listEmailCondition[2].notKeyword, isNull);
      });

      test('SHOULD add an events-exclusion condition WHEN notIncludeEvents is true', () {
        // Arrange
        final filter = SearchEmailFilter(
          text: SearchQuery('example'),
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents = true → events-exclusion condition IS added.
        // Result is AND(text=example, notKeyword=event).
        expect(result, isA<LogicFilterOperator>());
        final andFilter = result as LogicFilterOperator;
        expect(andFilter.operator, equals(Operator.AND));
        expect(andFilter.conditions.length, equals(2));

        final textCondition = andFilter.conditions.whereType<EmailFilterCondition>()
            .firstWhere((c) => c.text != null);
        expect(textCondition.text, 'example');

        final eventsExclusion = andFilter.conditions.whereType<EmailFilterCondition>()
            .firstWhere((c) => c.notKeyword != null);
        expect(eventsExclusion.notKeyword, KeyWordIdentifierExtension.eventsMail.value);
      });

      test('SHOULD return an events-exclusion EmailFilterCondition WHEN notIncludeEvents is true and no other conditions are set', () {
        // Arrange
        final filter = SearchEmailFilter(notIncludeEvents: true);

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents = true → events-exclusion is added as the sole condition.
        expect(result, isA<EmailFilterCondition>());
        final emailCondition = result as EmailFilterCondition;
        expect(emailCondition.notKeyword, KeyWordIdentifierExtension.eventsMail.value);
      });

      test('SHOULD NOT add an events-exclusion condition WHEN notIncludeEvents is false (default)', () {
        // Arrange
        final filter = SearchEmailFilter(
          text: SearchQuery('example'),
          notIncludeEvents: false,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // notIncludeEvents = false → events-exclusion is NOT added.
        // Only the text condition is returned directly.
        expect(result, isA<EmailFilterCondition>());
        final emailCondition = result as EmailFilterCondition;
        expect(emailCondition.text, 'example');
        expect(
          emailCondition.notKeyword,
          isNot(equals(KeyWordIdentifierExtension.eventsMail.value)),
        );
      });

      test('SHOULD combine events-exclusion with NOT(notKeyword) in AND WHEN notIncludeEvents is true and notKeyword is given', () {
        // Result: AND(NOT(text=hello), eventsExclusion) — 2 conditions.
        final andFilter = _actAndAssertAndWithEventsExclusion(
          SearchEmailFilter(notKeyword: {'hello'}, notIncludeEvents: true),
          2,
        );

        final notFilter = andFilter.conditions.whereType<LogicFilterOperator>().first;
        expect(notFilter.operator, equals(Operator.NOT));
        expect((notFilter.conditions.first as EmailFilterCondition).text, 'hello');
      });

      test('SHOULD combine events-exclusion with multiple "to" OR-conditions in AND WHEN notIncludeEvents is true', () {
        // Result: AND(OR(to1), OR(to2), eventsExclusion) — 3 conditions.
        final andFilter = _actAndAssertAndWithEventsExclusion(
          SearchEmailFilter(to: {'to1@example.com', 'to2@example.com'}, notIncludeEvents: true),
          3,
        );

        final toFilters = andFilter.conditions.whereType<LogicFilterOperator>().toList();
        expect(toFilters.length, equals(2));
        expect(toFilters.every((f) => f.operator == Operator.OR), isTrue);
      });

      test('SHOULD combine events-exclusion with OR(from) in AND WHEN notIncludeEvents is true and multiple from are given', () {
        // Result: AND(OR(from1, from2), eventsExclusion) — 2 conditions.
        final andFilter = _actAndAssertAndWithEventsExclusion(
          SearchEmailFilter(from: {'from1@example.com', 'from2@example.com'}, notIncludeEvents: true),
          2,
        );

        final fromFilter = andFilter.conditions.whereType<LogicFilterOperator>().first;
        expect(fromFilter.operator, equals(Operator.OR));
        expect(fromFilter.conditions.length, equals(2));
      });

      test('SHOULD combine events-exclusion with unread condition in AND WHEN notIncludeEvents is true and unread is true', () {
        // Arrange
        final filter = SearchEmailFilter(
          unread: true,
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // unread=true sets notKeyword=emailSeen in the shared EmailFilterCondition.
        // Result: AND(emailCond(notKeyword=emailSeen), eventsExclusion) — 2 conditions.
        expect(result, isA<LogicFilterOperator>());
        final andFilter = result as LogicFilterOperator;
        expect(andFilter.operator, equals(Operator.AND));
        expect(andFilter.conditions.length, equals(2));

        final emailConditions = andFilter.conditions.whereType<EmailFilterCondition>().toList();
        expect(emailConditions.length, equals(2));

        expect(
          emailConditions.any((c) => c.notKeyword == KeyWordIdentifier.emailSeen.value),
          isTrue,
        );
        expect(
          emailConditions.any((c) => c.notKeyword == KeyWordIdentifierExtension.eventsMail.value),
          isTrue,
        );
      });

      test('SHOULD combine events-exclusion with hasAttachment in AND WHEN notIncludeEvents is true and hasAttachment is true', () {
        // Arrange
        final filter = SearchEmailFilter(
          hasAttachment: true,
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // hasAttachment goes into the shared condition.
        // Result: AND(sharedCond(hasAttachment=true), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final sharedCond = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.hasAttachment == true);
        expect(sharedCond.hasAttachment, isTrue);
      });

      test('SHOULD combine events-exclusion with subject in AND WHEN notIncludeEvents is true and subject is given', () {
        // Arrange
        final filter = SearchEmailFilter(
          subject: 'Meeting notes',
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // subject goes into the shared condition.
        // Result: AND(sharedCond(subject='Meeting notes'), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final sharedCond = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.subject != null);
        expect(sharedCond.subject, 'Meeting notes');
      });

      test('SHOULD combine events-exclusion with label hasKeyword in AND WHEN notIncludeEvents is true and label is given', () {
        // Arrange
        // label adds a SEPARATE EmailFilterCondition(hasKeyword: label.keyword.value),
        // distinct from the shared base condition.
        final labelKeyword = KeyWordIdentifier(r'$label-work');
        final filter = SearchEmailFilter(
          label: Label(keyword: labelKeyword),
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // Result: AND(EmailFilterCondition(hasKeyword=label.keyword), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final labelCond = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.hasKeyword != null);
        expect(labelCond.hasKeyword, labelKeyword.value);
      });

      test('SHOULD combine events-exclusion with single hasKeyword in shared condition WHEN notIncludeEvents is true and one hasKeyword is given', () {
        // Arrange
        final filter = SearchEmailFilter(
          hasKeyword: {KeyWordIdentifier.emailFlagged.value},
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // Single hasKeyword goes into the shared condition (hasKeyword: hasKeyword.first).
        // Result: AND(sharedCond(hasKeyword=emailFlagged), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final sharedCond = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.hasKeyword != null);
        expect(sharedCond.hasKeyword, KeyWordIdentifier.emailFlagged.value);
      });

      test('SHOULD combine events-exclusion with multi-hasKeyword AND operator WHEN notIncludeEvents is true and multiple hasKeywords are given', () {
        // Arrange
        final filter = SearchEmailFilter(
          hasKeyword: {'kw1', 'kw2'},
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // Multiple hasKeywords produce a separate AND(hasKeyword=kw1, hasKeyword=kw2).
        // Result: AND(AND(kw1, kw2), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final innerAnd = andFilter.conditions
            .whereType<LogicFilterOperator>()
            .first;
        expect(innerAnd.operator, equals(Operator.AND));
        expect(innerAnd.conditions.length, equals(2));
        expect(
          innerAnd.conditions
              .whereType<EmailFilterCondition>()
              .every((c) => c.hasKeyword != null),
          isTrue,
        );
      });

      test('SHOULD combine events-exclusion with single from in shared condition WHEN notIncludeEvents is true and one from address is given', () {
        // Arrange
        final filter = SearchEmailFilter(
          from: {'sender@example.com'},
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // Single from goes into the shared condition (from: from.first).
        // Result: AND(sharedCond(from='sender@example.com'), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final sharedCond = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.from != null);
        expect(sharedCond.from, 'sender@example.com');
      });

      test('SHOULD combine events-exclusion with single "to" OR-condition WHEN notIncludeEvents is true and one to address is given', () {
        // Arrange
        final filter = SearchEmailFilter(
          to: {'recipient@example.com'},
          notIncludeEvents: true,
        );

        // Act
        final result = filter.mappingToEmailFilterCondition();

        // Assert
        // Single "to" spreads one OR(to:x, cc:x, bcc:x) into the condition set.
        // Result: AND(OR(to, cc, bcc), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final toOrFilter = andFilter.conditions
            .whereType<LogicFilterOperator>()
            .first;
        expect(toOrFilter.operator, equals(Operator.OR));
        expect(toOrFilter.conditions.length, equals(3));
        expect(
          toOrFilter.conditions
              .whereType<EmailFilterCondition>()
              .any((c) => c.to == 'recipient@example.com'),
          isTrue,
        );
      });

      test('SHOULD combine events-exclusion with inMailboxOtherThan WHEN notIncludeEvents is true and trashSpamMailboxIds are passed', () {
        // Arrange
        // No mailbox set → _getInMailboxOtherThanField returns trashSpamMailboxIds,
        // adding inMailboxOtherThan to the shared condition. This mirrors every real
        // production call from ThreadController / SearchEmailController.
        final trashId = MailboxId(Id('trash-id'));
        final spamId = MailboxId(Id('spam-id'));
        final filter = SearchEmailFilter(notIncludeEvents: true);

        // Act
        final result = filter.mappingToEmailFilterCondition(
          trashSpamMailboxIds: {trashId, spamId},
        );

        // Assert
        // Result: AND(sharedCond(inMailboxOtherThan={trashId, spamId}), eventsExclusion) — 2 conditions.
        final andFilter = _assertAndOperator(result, 2);
        _assertEventsExclusionInAnd(andFilter);

        final sharedCond = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.inMailboxOtherThan != null);
        expect(sharedCond.inMailboxOtherThan, containsAll([trashId, spamId]));
      });

      test('SHOULD combine events-exclusion with moreFilterCondition in AND WHEN notIncludeEvents is true and no other conditions', () {
        // Arrange
        final moreCondition = EmailFilterCondition(text: 'moreFilter');
        final filter = SearchEmailFilter(notIncludeEvents: true);

        // Act
        final result = filter.mappingToEmailFilterCondition(moreFilterCondition: moreCondition);

        // Assert
        // Result: AND(eventsExclusion, moreCondition) — 2 conditions.
        expect(result, isA<LogicFilterOperator>());
        final andFilter = result as LogicFilterOperator;
        expect(andFilter.operator, equals(Operator.AND));
        expect(andFilter.conditions.length, equals(2));
        expect(andFilter.conditions.contains(moreCondition), isTrue);

        final eventsExclusion = andFilter.conditions.whereType<EmailFilterCondition>()
            .firstWhere((c) => c.notKeyword != null);
        expect(eventsExclusion.notKeyword, KeyWordIdentifierExtension.eventsMail.value);
      });
    });

    group('isApplied::test', () {
      test('SHOULD return false WHEN all fields are default and notIncludeEvents is false', () {
        // Arrange
        final filter = SearchEmailFilter();

        // Assert
        expect(filter.isApplied, isFalse);
      });

      test('SHOULD return true WHEN notIncludeEvents is true', () {
        // Arrange
        final filter = SearchEmailFilter(notIncludeEvents: true);

        // Assert
        expect(filter.isApplied, isTrue);
      });

      test('SHOULD return true WHEN notIncludeEvents is true even if all other fields are default', () {
        // Arrange
        final filter = SearchEmailFilter(
          notIncludeEvents: true,
          text: null,
          subject: null,
          hasAttachment: false,
          unread: false,
        );

        // Assert
        expect(filter.isApplied, isTrue);
      });
    });

    group('copyWith notIncludeEventsOption::test', () {
      test(
        'SHOULD set notIncludeEvents to true '
        'AND mappingToEmailFilterCondition returns events-exclusion filter '
        'WHEN checkbox is checked (notIncludeEventsOption: Some(true))',
      () {
        // Arrange: initial filter with no conditions (checkbox OFF by default)
        final initial = SearchEmailFilter.initial();
        expect(initial.notIncludeEvents, isFalse);

        // Act: user checks "Don't include events" checkbox
        final updated = initial.copyWith(notIncludeEventsOption: const Some(true));

        // Assert: filter state updated
        expect(updated.notIncludeEvents, isTrue);

        // Assert: filter condition sent to interactor excludes events
        final condition = updated.mappingToEmailFilterCondition();
        expect(condition, isA<EmailFilterCondition>());
        final emailCondition = condition as EmailFilterCondition;
        expect(emailCondition.notKeyword, KeyWordIdentifierExtension.eventsMail.value);
      });

      test(
        'SHOULD set notIncludeEvents to false '
        'AND mappingToEmailFilterCondition returns null '
        'WHEN checkbox is unchecked (notIncludeEventsOption: None())',
      () {
        // Arrange: filter with events excluded (checkbox ON)
        final withEvents = SearchEmailFilter(notIncludeEvents: true);
        expect(withEvents.notIncludeEvents, isTrue);

        // Act: user unchecks "Don't include events" checkbox
        final reset = withEvents.copyWith(notIncludeEventsOption: const None());

        // Assert: filter state reset
        expect(reset.notIncludeEvents, isFalse);

        // Assert: no condition is sent to interactor (null = no filter applied)
        final condition = reset.mappingToEmailFilterCondition();
        expect(condition, isNull);
      });

      test(
        'SHOULD return original state '
        'WHEN checkbox is checked then unchecked (full on/off cycle)',
      () {
        // Arrange
        final initial = SearchEmailFilter.initial();

        // Act: check then uncheck
        final afterCheck = initial.copyWith(notIncludeEventsOption: const Some(true));
        final afterUncheck = afterCheck.copyWith(notIncludeEventsOption: const None());

        // Assert: state returns to original
        expect(afterUncheck.notIncludeEvents, isFalse);
        expect(afterUncheck.mappingToEmailFilterCondition(), isNull);
        expect(afterUncheck, equals(initial));
      });

      test(
        'SHOULD combine events-exclusion with existing text query '
        'WHEN checkbox is checked while a text query is active',
      () {
        // Arrange: user has already typed a search query
        final withText = SearchEmailFilter(text: SearchQuery('meeting'));

        // Act: user additionally checks "Don't include events"
        final updated = withText.copyWith(notIncludeEventsOption: const Some(true));

        // Assert: both conditions are preserved
        expect(updated.notIncludeEvents, isTrue);
        expect(updated.text, equals(SearchQuery('meeting')));

        // Assert: filter condition is AND(text=meeting, notKeyword=eventsMail)
        final condition = updated.mappingToEmailFilterCondition();
        expect(condition, isA<LogicFilterOperator>());
        final andFilter = condition as LogicFilterOperator;
        expect(andFilter.operator, equals(Operator.AND));
        expect(andFilter.conditions.length, equals(2));

        final textCondition = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.text != null);
        expect(textCondition.text, 'meeting');

        final eventsExclusion = andFilter.conditions
            .whereType<EmailFilterCondition>()
            .firstWhere((c) => c.notKeyword != null);
        expect(eventsExclusion.notKeyword, KeyWordIdentifierExtension.eventsMail.value);
      });

      test(
        'SHOULD remove events-exclusion from filter condition while keeping text query '
        'WHEN checkbox is unchecked while a text query is active',
      () {
        // Arrange: user has text query AND events excluded
        final withBoth = SearchEmailFilter(
          text: SearchQuery('meeting'),
          notIncludeEvents: true,
        );

        // Act: user unchecks "Don't include events"
        final updated = withBoth.copyWith(notIncludeEventsOption: const None());

        // Assert: notIncludeEvents reset but text preserved
        expect(updated.notIncludeEvents, isFalse);
        expect(updated.text, equals(SearchQuery('meeting')));

        // Assert: only text condition is sent to interactor (no events-exclusion)
        final condition = updated.mappingToEmailFilterCondition();
        expect(condition, isA<EmailFilterCondition>());
        final emailCondition = condition as EmailFilterCondition;
        expect(emailCondition.text, 'meeting');
        expect(
          emailCondition.notKeyword,
          isNot(equals(KeyWordIdentifierExtension.eventsMail.value)),
        );
      });
    });

    group('isOnlyStarredApplied::test', () {
      test('SHOULD return true WHEN only flagged hasKeyword is set and notIncludeEvents is false', () {
        // Arrange
        final filter = SearchEmailFilter(
          hasKeyword: {KeyWordIdentifier.emailFlagged.value},
        );

        // Assert
        expect(filter.isOnlyStarredApplied, isTrue);
      });

      test('SHOULD return false WHEN flagged hasKeyword is set but notIncludeEvents is true', () {
        // Arrange
        final filter = SearchEmailFilter(
          hasKeyword: {KeyWordIdentifier.emailFlagged.value},
          notIncludeEvents: true,
        );

        // Assert
        expect(filter.isOnlyStarredApplied, isFalse);
      });

      test('SHOULD return false WHEN notIncludeEvents is true and no other filters are set', () {
        // Arrange
        final filter = SearchEmailFilter(notIncludeEvents: true);

        // Assert
        expect(filter.isOnlyStarredApplied, isFalse);
      });
    });
  });
}
