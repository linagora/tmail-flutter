import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/email/email_property.dart';
import 'package:model/extensions/email_extension.dart' as model;
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

void main() {
  final emailId = EmailId(Id('email'));
  const unsubscribe =
      '<mailto:unsubscribe@example.com>, <https://example.com/unsubscribe>';

  test(
    'mailbox fetch requests raw headers instead of List-Unsubscribe asText',
    () {
      for (final properties in [
        ThreadConstants.propertiesDefault,
        ThreadConstants.propertiesUpdatedDefault,
        ThreadConstants.propertiesCalendarEvent,
      ]) {
        expect(properties.value.contains(EmailProperty.headers), isTrue);
        expect(
          properties.value.contains(
            IndividualHeaderIdentifier.listUnsubscribeHeader.value,
          ),
          isFalse,
        );
      }
    },
  );

  test('raw unsubscribe survives cache roundtrip', () {
    final email = Email(
      id: emailId,
      headers: {EmailHeader(EmailProperty.headerUnsubscribeKey, unsubscribe)},
    );

    final cache = email.toEmailCache();

    expect(cache.unsubscribeHeader, {
      IndividualHeaderIdentifier.listUnsubscribeHeader.value: unsubscribe,
    });
    expect(model.EmailExtension(cache.toEmail()).listUnsubscribe, unsubscribe);
  });

  test(
    'existing individual unsubscribe values, including empty, survive cache',
    () {
      for (final value in [unsubscribe, '']) {
        final email = Email(
          id: emailId,
          individualHeaders: {
            IndividualHeaderIdentifier.listUnsubscribeHeader: TextHeaderValue(
              value,
            ),
          },
        );

        final cache = email.toEmailCache();

        expect(cache.unsubscribeHeader, {
          IndividualHeaderIdentifier.listUnsubscribeHeader.value: value,
        });
        expect(model.EmailExtension(cache.toEmail()).listUnsubscribe, value);
      }
    },
  );

  test('missing unsubscribe remains absent from cache', () {
    expect(Email(id: emailId).toEmailCache().unsubscribeHeader, isNull);
  });

  test('raw headers refresh unsubscribe in a previously cached email', () {
    final cached = Email(
      id: emailId,
      individualHeaders: {
        IndividualHeaderIdentifier.listUnsubscribeHeader: const TextHeaderValue(
          'old',
        ),
      },
    ).toEmailCache().toEmail();
    final updated = Email(
      id: emailId,
      headers: {
        EmailHeader(EmailProperty.headerUnsubscribeKey, unsubscribe),
        EmailHeader(
          EmailProperty.headerListPostKey,
          ' <mailto:list@example.com> ',
        ),
      },
    );

    final combined = model.EmailExtension(
      cached,
    ).combineEmail(updated, ThreadConstants.propertiesUpdatedDefault);

    expect(model.EmailExtension(combined).listUnsubscribe, unsubscribe);
    expect(
      model.EmailExtension(combined).listPost,
      '<mailto:list@example.com>',
    );
    expect(
      model.EmailExtension(combined).toPresentationEmail().listPost,
      '<mailto:list@example.com>',
    );
    expect(
      model.EmailExtension(combined.toEmailCache().toEmail()).listUnsubscribe,
      unsubscribe,
    );
  });

  test('unrelated updates preserve raw headers for reply to list', () {
    final email = Email(
      id: emailId,
      headers: {
        EmailHeader(
          EmailProperty.headerListPostKey,
          '<mailto:list@example.com>',
        ),
      },
    );
    final combined = model.EmailExtension(email).combineEmail(
      Email(id: emailId, subject: 'updated'),
      Properties({EmailProperty.subject}),
    );

    expect(
      model.EmailExtension(combined).listPost,
      '<mailto:list@example.com>',
    );
  });

  test(
    'raw header refresh clears removed legacy list headers and retains priority',
    () {
      final cached = Email(
        id: emailId,
        individualHeaders: {
          IndividualHeaderIdentifier.listUnsubscribeHeader:
              const TextHeaderValue(unsubscribe),
          IndividualHeaderIdentifier.listPostHeader: const TextHeaderValue(
            '<mailto:old@example.com>',
          ),
          IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue(
            '1',
          ),
        },
      );

      final combined = model.EmailExtension(cached).combineEmail(
        Email(id: emailId, headers: {}),
        Properties({EmailProperty.headers}),
      );

      expect(model.EmailExtension(combined).listUnsubscribe, isEmpty);
      expect(model.EmailExtension(combined).listPost, isEmpty);
      expect(combined.toEmailCache().unsubscribeHeader, isNull);
      expect(combined.xPriorityHeader?.value, '1');
    },
  );
}
