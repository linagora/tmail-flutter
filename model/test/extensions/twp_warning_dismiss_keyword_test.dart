import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';

void main() {
  // Locks the backend dismissal contract: the keyword name and the SetEmail
  // patch shape the server relies on to remember a dismissed warning.
  group('TWP warning dismissal keyword', () {
    test('keyword name is twp-warning-dismissed-<index>', () {
      expect(
        KeyWordIdentifierExtension.twpWarningDismissedPrefix,
        'twp-warning-dismissed-',
      );
      expect(
        KeyWordIdentifierExtension.twpWarningDismissed(0).value,
        'twp-warning-dismissed-0',
      );
      expect(
        KeyWordIdentifierExtension.twpWarningDismissed(3).value,
        'twp-warning-dismissed-3',
      );
    });

    test('generates a keywords/<keyword> = true patch', () {
      final patch = KeyWordIdentifierExtension.twpWarningDismissed(
        1,
      ).generateDismissTwpWarningActionPath();
      expect(patch, PatchObject({'keywords/twp-warning-dismissed-1': true}));
    });

    test('builds the SetEmail update map keyed by the email id', () {
      final emailId = EmailId(Id('email-1'));
      final updates = emailId.generateMapUpdateObjectDismissTwpWarning(2);

      expect(updates.keys.single, emailId.id);
      expect(
        updates[emailId.id],
        PatchObject({'keywords/twp-warning-dismissed-2': true}),
      );
    });
  });

  group('PresentationEmail.isTwpWarningDismissed', () {
    test('is true only for an index whose keyword is present', () {
      final email = PresentationEmail(
        keywords: {KeyWordIdentifierExtension.twpWarningDismissed(1): true},
      );
      expect(email.isTwpWarningDismissed(1), isTrue);
      expect(email.isTwpWarningDismissed(0), isFalse);
    });

    test('is false when there are no keywords', () {
      expect(PresentationEmail().isTwpWarningDismissed(0), isFalse);
    });
  });
}
