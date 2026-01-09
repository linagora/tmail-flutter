import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/filters/mailbox_filter_builder.dart';

void main() {
  PresentationMailbox mailbox({
    bool favorite = false,
    bool actionRequired = false,
  }) {
    if (favorite) {
      return PresentationMailbox.favoriteFolder;
    } else if (actionRequired) {
      return PresentationMailbox.actionRequiredFolder;
    } else {
      return PresentationMailbox(
        MailboxId(Id('inbox')),
        name: MailboxName('Inbox'),
        role: PresentationMailbox.roleInbox,
      );
    }
  }

  UTCDate beforeDate() => UTCDate(DateTime.utc(2024, 1, 1));

  group('buildEmailFilterForLoadMailbox', () {
    test(
      'ActionRequired mailbox → returns EmailFilter without mailboxId and filterOption',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.all,
        );

        final result = builder.buildEmailFilterForLoadMailbox();

        expect(result.filter, isA<Filter>());
        expect(result.mailboxId, isNull);
        expect(result.filterOption, isNull);
      },
    );

    test(
      'Normal mailbox → returns EmailFilter with filterOption applied',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.unread,
        );

        final result = builder.buildEmailFilterForLoadMailbox();

        expect(result.filterOption, FilterMessageOption.unread);
      },
    );
  });

  group('Favorite mailbox - buildFilterCondition', () {
    test(
      'Unread filter → flagged AND not seen',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(favorite: true),
          filterMessageOption: FilterMessageOption.unread,
        );

        final filter = builder.buildFilterCondition(
          oldestEmail: null,
        ) as EmailFilterCondition;

        expect(filter.hasKeyword, KeyWordIdentifier.emailFlagged.value);
        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
      },
    );

    test(
      'Attachments filter → hasAttachment AND flagged',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(favorite: true),
          filterMessageOption: FilterMessageOption.attachments,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasAttachment, true);
        expect(filter.hasKeyword, KeyWordIdentifier.emailFlagged.value);
      },
    );

    test(
      'Starred filter → flagged only',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(favorite: true),
          filterMessageOption: FilterMessageOption.starred,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasKeyword, KeyWordIdentifier.emailFlagged.value);
        expect(filter.notKeyword, isNull);
      },
    );
  });

  group('ActionRequired mailbox - buildFilterCondition', () {
    test(
      'Starred filter → AND(flagged, needsAction AND not seen)',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.starred,
        );

        final filter = builder.buildFilterCondition();

        expect(filter, isA<LogicFilterOperator>());

        final logic = filter as LogicFilterOperator;
        expect(logic.operator, Operator.AND);
        expect(logic.conditions.length, 2);
      },
    );

    test(
      'Attachments filter → hasAttachment AND needsAction AND not seen',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.attachments,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasAttachment, true);
        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
        expect(
          filter.hasKeyword,
          KeyWordIdentifierExtension.needsActionMail.value,
        );
      },
    );

    test(
      'Unread filter → needsAction AND not seen',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.unread,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
        expect(
          filter.hasKeyword,
          KeyWordIdentifierExtension.needsActionMail.value,
        );
      },
    );
  });

  group('Default mailbox - buildFilterCondition', () {
    test(
      'All filter → no keyword or attachment constraints',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.all,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasKeyword, isNull);
        expect(filter.notKeyword, isNull);
        expect(filter.hasAttachment, isNull);
      },
    );

    test(
      'Unread filter → not seen',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.unread,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
      },
    );

    test(
      'Attachments filter → hasAttachment',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.attachments,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasAttachment, true);
      },
    );

    test(
      'Starred filter → flagged',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.starred,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasKeyword, KeyWordIdentifier.emailFlagged.value);
      },
    );
  });

  group('Pagination (before) handling', () {
    test(
      'Oldest email provided → before date propagated into filter',
      () {
        final before = beforeDate();

        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.all,
        );

        final filter = builder.buildFilterCondition(
          oldestEmail: PresentationEmail(receivedAt: before),
        ) as EmailFilterCondition;

        expect(filter.before, before);
      },
    );
  });

  group('MailboxFilterBuilder - edge cases and regression', () {
    test(
      'No selectedMailbox → treated as default mailbox',
      () {
        const builder = MailboxFilterBuilder(
          selectedMailbox: null,
          filterMessageOption: FilterMessageOption.unread,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
      },
    );

    test(
      'Favorite mailbox + All filter → flagged only',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(favorite: true),
          filterMessageOption: FilterMessageOption.all,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasKeyword, KeyWordIdentifier.emailFlagged.value);
        expect(filter.notKeyword, isNull);
      },
    );

    test(
      'ActionRequired mailbox + All filter → needsAction AND not seen',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.all,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
        expect(
          filter.hasKeyword,
          KeyWordIdentifierExtension.needsActionMail.value,
        );
      },
    );

    test(
      'Favorite mailbox takes precedence over ActionRequired',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(
            favorite: true,
            actionRequired: true,
          ),
          filterMessageOption: FilterMessageOption.unread,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasKeyword, KeyWordIdentifier.emailFlagged.value);
        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
      },
    );

    test(
      'Before date propagated into all conditions of LogicFilterOperator',
      () {
        final before = beforeDate();

        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.starred,
        );

        final filter = builder.buildFilterCondition(
          oldestEmail: PresentationEmail(receivedAt: before),
        ) as LogicFilterOperator;

        for (final condition in filter.conditions) {
          final emailFilter = condition as EmailFilterCondition;
          expect(emailFilter.before, before);
        }
      },
    );

    test(
      'buildEmailFilterForLoadMailbox uses buildFilterCondition result',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(),
          filterMessageOption: FilterMessageOption.unread,
        );

        final emailFilter = builder.buildEmailFilterForLoadMailbox();

        final condition = emailFilter.filter as EmailFilterCondition;
        expect(condition.notKeyword, KeyWordIdentifier.emailSeen.value);
      },
    );

    test(
      'Filter never contains same keyword in both hasKeyword and notKeyword',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.unread,
        );

        final filter = builder.buildFilterCondition() as EmailFilterCondition;

        expect(filter.hasKeyword == filter.notKeyword, false);
      },
    );
  });

  group('inMailbox parameter - regression test', () {
    test(
      'Default mailbox with All filter → includes inMailbox',
      () {
        final testMailbox = mailbox(); // inbox with id 'inbox'
        final builder = MailboxFilterBuilder(
          selectedMailbox: testMailbox,
          filterMessageOption: FilterMessageOption.all,
        );

        final emailFilter = builder.buildEmailFilterForLoadMailbox();
        final filter = emailFilter.filter as EmailFilterCondition;

        // Verify inMailbox is present
        expect(filter.inMailbox, equals(testMailbox.id));
      },
    );

    test(
      'Default mailbox with Unread filter → includes inMailbox',
      () {
        final testMailbox = mailbox();
        final builder = MailboxFilterBuilder(
          selectedMailbox: testMailbox,
          filterMessageOption: FilterMessageOption.unread,
        );

        final emailFilter = builder.buildEmailFilterForLoadMailbox();
        final filter = emailFilter.filter as EmailFilterCondition;

        expect(filter.inMailbox, equals(testMailbox.id));
        expect(filter.notKeyword, KeyWordIdentifier.emailSeen.value);
      },
    );

    test(
      'Default mailbox with Attachments filter → includes inMailbox',
      () {
        final testMailbox = mailbox();
        final builder = MailboxFilterBuilder(
          selectedMailbox: testMailbox,
          filterMessageOption: FilterMessageOption.attachments,
        );

        final emailFilter = builder.buildEmailFilterForLoadMailbox();
        final filter = emailFilter.filter as EmailFilterCondition;

        expect(filter.inMailbox, equals(testMailbox.id));
        expect(filter.hasAttachment, true);
      },
    );

    test(
      'Virtual folder Action Required → does NOT include inMailbox',
      () {
        final builder = MailboxFilterBuilder(
          selectedMailbox: mailbox(actionRequired: true),
          filterMessageOption: FilterMessageOption.all,
        );

        final emailFilter = builder.buildEmailFilterForLoadMailbox();
        final filter = emailFilter.filter as EmailFilterCondition;

        // Virtual folders should NOT have inMailbox - they aggregate across all
        expect(filter.inMailbox, isNull);
        expect(
          filter.hasKeyword,
          KeyWordIdentifierExtension.needsActionMail.value,
        );
      },
    );
  });
}
