import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';

extension PresentationEmailMapExtension on Map<EmailId, PresentationEmail?> {
  Map<EmailId, PresentationEmail?> starAll() {
    return map((id, email) {
      if (email == null) {
        return MapEntry(id, email);
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..[KeyWordIdentifier.emailFlagged] = true;

      return MapEntry(
        id,
        email.copyWith(keywords: updatedKeywords),
      );
    });
  }

  Map<EmailId, PresentationEmail?> unstarAll() {
    return map((id, email) {
      if (email == null) {
        return MapEntry(id, email);
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..remove(KeyWordIdentifier.emailFlagged);

      return MapEntry(
        id,
        email.copyWith(keywords: updatedKeywords),
      );
    });
  }

  Map<EmailId, PresentationEmail?> starByIds(List<EmailId> ids) {
    final targetSet = ids.toSet();

    return map((id, email) {
      if (!targetSet.contains(id) || email == null) {
        return MapEntry(id, email);
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..[KeyWordIdentifier.emailFlagged] = true;

      return MapEntry(
        id,
        email.copyWith(keywords: updatedKeywords),
      );
    });
  }

  Map<EmailId, PresentationEmail?> unstarByIds(List<EmailId> ids) {
    final targetSet = ids.toSet();

    return map((id, email) {
      if (!targetSet.contains(id) || email == null) {
        return MapEntry(id, email);
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..remove(KeyWordIdentifier.emailFlagged);

      return MapEntry(
        id,
        email.copyWith(keywords: updatedKeywords),
      );
    });
  }

  Map<EmailId, PresentationEmail?> starOne(EmailId emailId) {
    return map((id, email) {
      if (id != emailId || email == null) {
        return MapEntry(id, email);
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..[KeyWordIdentifier.emailFlagged] = true;

      return MapEntry(
        id,
        email.copyWith(keywords: updatedKeywords),
      );
    });
  }

  Map<EmailId, PresentationEmail?> unstarOne(EmailId emailId) {
    return map((id, email) {
      if (id != emailId || email == null) {
        return MapEntry(id, email);
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..remove(KeyWordIdentifier.emailFlagged);

      return MapEntry(
        id,
        email.copyWith(keywords: updatedKeywords),
      );
    });
  }
}
