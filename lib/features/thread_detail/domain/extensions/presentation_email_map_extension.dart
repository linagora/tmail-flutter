import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';

extension PresentationEmailMapExtension on Map<EmailId, PresentationEmail?> {
  Map<EmailId, PresentationEmail?> toggleEmailKeywords({
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    return map((id, email) {
      if (email == null) {
        return MapEntry(id, email);
      }
      return MapEntry(
        id,
        email.toggleKeyword(keyword: keyword, remove: remove),
      );
    });
  }

  Map<EmailId, PresentationEmail?> toggleEmailKeywordByIds({
    required List<EmailId> ids,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    final targetSet = ids.toSet();

    return map((id, email) {
      if (!targetSet.contains(id) || email == null) {
        return MapEntry(id, email);
      }
      return MapEntry(
        id,
        email.toggleKeyword(keyword: keyword, remove: remove),
      );
    });
  }

  Map<EmailId, PresentationEmail?> toggleEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    return map((id, email) {
      if (id != emailId || email == null) {
        return MapEntry(id, email);
      }
      return MapEntry(
        id,
        email.toggleKeyword(keyword: keyword, remove: remove),
      );
    });
  }
}
