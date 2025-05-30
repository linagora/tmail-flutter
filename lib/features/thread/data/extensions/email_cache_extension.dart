
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_address_hive_cache_extension.dart';

extension EmailCacheExtension on EmailCache {
  Email toEmail() {
    return Email(
      id: EmailId(Id(id)),
      keywords: keywords != null
        ? Map.fromIterables(keywords!.keys.map((value) => KeyWordIdentifier(value)), keywords!.values)
        : null,
      size: size != null ? UnsignedInt(size!) : null,
      receivedAt: receivedAt != null ? UTCDate(receivedAt!) : null,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt != null ? UTCDate(sentAt!) : null,
      from: from?.map((emailAddressCache) => emailAddressCache.toEmailAddress()).toSet(),
      to: to?.map((emailAddressCache) => emailAddressCache.toEmailAddress()).toSet(),
      cc: cc?.map((emailAddressCache) => emailAddressCache.toEmailAddress()).toSet(),
      bcc: bcc?.map((emailAddressCache) => emailAddressCache.toEmailAddress()).toSet(),
      replyTo: replyTo?.map((emailAddressCache) => emailAddressCache.toEmailAddress()).toSet(),
      mailboxIds: mailboxIds != null
        ? Map.fromIterables(mailboxIds!.keys.map((value) => MailboxId(Id(value))), mailboxIds!.values)
        : null,
      headerCalendarEvent: headerCalendarEvent != null
        ? Map.fromIterables(headerCalendarEvent!.keys.map((value) => IndividualHeaderIdentifier(value)), headerCalendarEvent!.values)
        : null,
      blobId: blobId != null ? Id(blobId!) : null,
      xPriorityHeader: xPriorityHeader != null
        ? Map.fromIterables(
            xPriorityHeader!.keys.map((value) => IndividualHeaderIdentifier(value)),
            xPriorityHeader!.values)
        : null,
      importanceHeader: importanceHeader != null
        ? Map.fromIterables(
            importanceHeader!.keys.map((value) => IndividualHeaderIdentifier(value)),
            importanceHeader!.values)
        : null,
      priorityHeader: priorityHeader != null
        ? Map.fromIterables(
            priorityHeader!.keys.map((value) => IndividualHeaderIdentifier(value)),
            priorityHeader!.values)
        : null,
    );
  }

  bool expireTimeCaching(EmailCleanupRule cleanupRule) {
    final currentTime = DateTime.now();
    log('EmailCacheExtension::expireTimeCaching():currentTime: $currentTime | receivedAt: $receivedAt');
    if (receivedAt != null) {
      final countDay = currentTime.daysBetween(receivedAt!.toLocal());
      log('EmailCacheExtension::expireTimeCaching():countDay: $countDay | cleanupRule.cachingEmailPeriod.countDay: ${cleanupRule.cachingEmailPeriod.countDay}');
      if (countDay >= cleanupRule.cachingEmailPeriod.countDay) {
        log('EmailCacheExtension::expireTimeCaching():true');
        return true;
      }
    }
    log('EmailCacheExtension::expireTimeCaching():false');
    return false;
  }
}