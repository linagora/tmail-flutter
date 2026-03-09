import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';

class _TestEmailItemTile with BaseEmailItemTile {
  @override
  ImagePaths get imagePaths => ImagePaths();

  @override
  ResponsiveUtils get responsiveUtils => ResponsiveUtils();
}

void main() {
  late _TestEmailItemTile tile;

  setUp(() {
    tile = _TestEmailItemTile();
  });

  final inboxFolder = PresentationMailbox(MailboxId(Id('inbox')));

  group('BaseEmailItemTile.hasMailboxLabel', () {
    test('should return false when showMailboxLabel is false and mailboxContain null', () {
      final email = PresentationEmail();

      final result = tile.hasMailboxLabel(false, email);

      expect(result, isFalse);
    });

    test('should return false when showMailboxLabel is false even if mailboxContain exists',
        () {
      final email = PresentationEmail(
        mailboxContain: inboxFolder,
      );

      final result = tile.hasMailboxLabel(false, email);

      expect(result, isFalse);
    });

    test('should return false when showMailboxLabel is true but mailboxContain null', () {
      final email = PresentationEmail();

      final result = tile.hasMailboxLabel(true, email);

      expect(result, isFalse);
    });

    test('should return true when showMailboxLabel is true and mailboxContain exists', () {
      final email = PresentationEmail(
        mailboxContain: inboxFolder,
      );

      final result = tile.hasMailboxLabel(true, email);

      expect(result, isTrue);
    });
  });
}
