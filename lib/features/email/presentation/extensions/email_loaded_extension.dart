import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';

extension EmailLoadedExtension on EmailLoaded {
  EmailLoaded starById(EmailId emailId) {
    if (emailCurrent == null || emailCurrent!.id != emailId) {
      return this;
    }

    final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
      emailCurrent!.keywords ?? {},
    )..[KeyWordIdentifier.emailFlagged] = true;

    final updatedEmail = emailCurrent!.copyWith(
      keywords: updatedKeywords,
    );

    return copyWith(emailCurrent: updatedEmail);
  }

  EmailLoaded unstarById(EmailId emailId) {
    if (emailCurrent == null || emailCurrent!.id != emailId) {
      return this;
    }

    final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
      emailCurrent!.keywords ?? {},
    )..remove(KeyWordIdentifier.emailFlagged);

    final updatedEmail = emailCurrent!.copyWith(
      keywords: updatedKeywords,
    );

    return copyWith(emailCurrent: updatedEmail);
  }
}
