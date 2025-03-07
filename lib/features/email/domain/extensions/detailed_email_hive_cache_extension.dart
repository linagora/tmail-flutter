import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_acttachments_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_email_header_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

extension DetailedEmailHiveCacheExtension on DetailedEmailHiveCache {
  DetailedEmail toDetailedEmailWithContent(String emailContent) {
    return DetailedEmail(
      emailId: EmailId(Id(emailId)),
      createdTime: timeSaved,
      attachments: attachments?.toAttachment(),
      emailContentPath: emailContentPath,
      headers: headers?.toSetEmailHeader(),
      keywords: keywords != null
        ? Map.fromIterables(keywords!.keys.map((value) => KeyWordIdentifier(value)), keywords!.values)
        : null,
      htmlEmailContent: emailContent,
      messageId: messageId != null
        ? MessageIdsHeaderValue(messageId!.toSet())
        : null,
      references: references != null
        ? MessageIdsHeaderValue(references!.toSet())
        : null,
      inlineImages: inlineImages?.toAttachment(),
      sMimeStatusHeader: sMimeStatusHeader != null
        ? Map.fromIterables(sMimeStatusHeader!.keys.map((value) => IndividualHeaderIdentifier(value)), sMimeStatusHeader!.values)
        : null,
    );
 }
}