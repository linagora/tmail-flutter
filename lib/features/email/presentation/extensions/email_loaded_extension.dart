import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';

extension EmailLoadedExtension on EmailLoaded {
  EmailLoaded addEmailKeyword({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
  }) {
    if (emailCurrent == null || emailCurrent?.id != emailId) {
      return this;
    }
    final newKeyword = emailCurrent?.keywords?.withKeyword(keyword);
    final updatedEmail = emailCurrent?.copyWith(keywords: newKeyword);
    return copyWith(emailCurrent: updatedEmail);
  }

  EmailLoaded removeEmailKeyword({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
  }) {
    if (emailCurrent == null || emailCurrent?.id != emailId) {
      return this;
    }
    final newKeyword = emailCurrent?.keywords?.withoutKeyword(keyword);
    final updatedEmail = emailCurrent?.copyWith(keywords: newKeyword);
    return copyWith(emailCurrent: updatedEmail);
  }
}
