
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_email_header_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_header_identifier_id_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';

extension DetailedEmailExtension on DetailedEmail {
  DetailedEmailHiveCache toHiveCache() {
    return DetailedEmailHiveCache(
      emailId: emailId.asString,
      timeSaved: createdTime,
      attachments: attachments?.toHiveCache(),
      headers: headers?.toList().toHiveCache(),
      keywords: keywords?.toMapString(),
      emailContentPath: emailContentPath,
      messageId: messageId?.ids.toList(),
      references: references?.ids.toList(),
      inlineImages: inlineImages?.toHiveCache(),
      sMimeStatusHeader: sMimeStatusHeader?.toMapString(),
      identityHeader: identityHeader?.toMapString(),
    );
  }

  String get newEmailFolderPath => CachingConstants.newEmailsContentFolderName;

  String get openedEmailFolderPath => CachingConstants.openedEmailContentFolderName;

  DetailedEmail fromEmailContentPath(String path) {
    return DetailedEmail(
      emailId: emailId,
      createdTime: createdTime,
      attachments: attachments,
      headers: headers,
      keywords: keywords,
      htmlEmailContent: htmlEmailContent,
      emailContentPath: path,
      messageId: messageId,
      references: references,
      inlineImages: inlineImages,
      sMimeStatusHeader: sMimeStatusHeader,
      identityHeader: identityHeader,
    );
  }
}