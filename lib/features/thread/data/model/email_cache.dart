
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_address_hive_cache.dart';

part 'email_cache.g.dart';

@HiveType(typeId: CachingConstants.EMAIL_CACHE_IDENTIFY)
class EmailCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, bool>? keywords;

  @HiveField(2)
  final int? size;

  @HiveField(3)
  final DateTime? receivedAt;

  @HiveField(4)
  final bool? hasAttachment;

  @HiveField(5)
  final String? preview;

  @HiveField(6)
  final String? subject;

  @HiveField(7)
  final DateTime? sentAt;

  @HiveField(8)
  final List<EmailAddressHiveCache>? from;

  @HiveField(9)
  final List<EmailAddressHiveCache>? to;

  @HiveField(10)
  final List<EmailAddressHiveCache>? cc;

  @HiveField(11)
  final List<EmailAddressHiveCache>? bcc;

  @HiveField(12)
  final List<EmailAddressHiveCache>? replyTo;

  @HiveField(13)
  Map<String, bool>? mailboxIds;

  @HiveField(14)
  Map<String, String?>? headerCalendarEvent;

  @HiveField(15)
  final String? blobId;

  @HiveField(16)
  Map<String, String?>? xPriorityHeader;

  @HiveField(17)
  Map<String, String?>? importanceHeader;

  @HiveField(18)
  Map<String, String?>? priorityHeader;

  EmailCache(
    this.id,
    {
      this.keywords,
      this.size,
      this.receivedAt,
      this.hasAttachment,
      this.preview,
      this.subject,
      this.sentAt,
      this.from,
      this.to,
      this.cc,
      this.bcc,
      this.replyTo,
      this.mailboxIds,
      this.headerCalendarEvent,
      this.blobId,
      this.xPriorityHeader,
      this.importanceHeader,
      this.priorityHeader,
    }
  );

  @override
  List<Object?> get props => [
    id,
    subject,
    from,
    to,
    cc,
    bcc,
    keywords,
    size,
    receivedAt,
    sentAt,
    replyTo,
    preview,
    hasAttachment,
    mailboxIds,
    headerCalendarEvent,
    blobId,
    xPriorityHeader,
    importanceHeader,
    priorityHeader,
  ];
}