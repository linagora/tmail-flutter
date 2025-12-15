import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';

extension EmailLoadedExtension on EmailLoaded {
  EmailLoaded toggleEmailKeyword({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    if (emailCurrent == null || emailCurrent!.id != emailId) {
      return this;
    }
    return copyWith(
      emailCurrent: emailCurrent!.toggleKeyword(
        keyword: keyword,
        remove: remove,
      ),
    );
  }
}
