
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_email_header_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

extension DetailedEmailExtension on DetailedEmail {
  DetailedEmailHiveCache toHiveCache() {
    return DetailedEmailHiveCache(
      emailId: emailId.asString,
      timeSaved: DateTime.now(),
      attachments: attachments?.toHiveCache(),
      headers: headers?.toHiveCache(),
      emailContentPath: emailContentPath
    );
  }

  String get newEmailFolderPath => CachingConstants.newEmailContentFolderName;

  String get openedEmailFolderPath => CachingConstants.openedEmailContentFolderNamee;

  DetailedEmail fromEmailContentPath(String path) {
    return DetailedEmail(
      emailId: emailId,
      attachments: attachments,
      headers: headers,
      htmlEmailContent: htmlEmailContent,
      emailContentPath: path,
    );
  }
}