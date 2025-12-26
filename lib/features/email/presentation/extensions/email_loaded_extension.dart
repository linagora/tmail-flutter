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
    final current = emailCurrent;
    if (current == null || current.id != emailId) {
      return this;
    }
    return copyWith(
      emailCurrent: current.toggleKeyword(keyword, remove),
    );
  }
}
