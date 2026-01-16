import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';

extension PresentationEmailMapExtension on Map<EmailId, PresentationEmail?> {
  Map<EmailId, PresentationEmail?> toggleEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    final newMap = Map<EmailId, PresentationEmail?>.from(this);
    final email = newMap[emailId];
    if (email != null) {
      newMap[emailId] = email.toggleKeyword(keyword, remove);
    }
    return newMap;
  }

  Map<EmailId, PresentationEmail?> toggleListEmailsKeywordByIds({
    required List<EmailId> emailIds,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    final updatedMap = Map<EmailId, PresentationEmail?>.from(this);

    for (final emailId in emailIds) {
      final email = updatedMap[emailId];
      if (email == null) continue;

      updatedMap[emailId] = email.toggleKeyword(keyword, remove);
    }

    return updatedMap;
  }
}
