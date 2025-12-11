import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';

extension PresentationEmailMapExtension on Map<EmailId, PresentationEmail?> {
  Map<EmailId, PresentationEmail?> addEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
  }) {
    return map((id, email) {
      if (id != emailId || email == null) {
        return MapEntry(id, email);
      }
      return MapEntry(id, email.addKeyword(keyword));
    });
  }

  Map<EmailId, PresentationEmail?> removeEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
  }) {
    return map((id, email) {
      if (id != emailId || email == null) {
        return MapEntry(id, email);
      }
      return MapEntry(id, email.removeKeyword(keyword));
    });
  }
}
