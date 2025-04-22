
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/model/email_header_hive_cache.dart';

import 'attachment_hive_cache.dart';

part 'detailed_email_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.DETAILED_EMAIL_HIVE_CACHE_ID)
class DetailedEmailHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String emailId;

  @HiveField(1)
  final DateTime timeSaved;

  @HiveField(2)
  final List<AttachmentHiveCache>? attachments;

  @HiveField(3)
  final String? emailContentPath;

  @HiveField(4)
  final List<EmailHeaderHiveCache>? headers;

  @HiveField(5)
  final Map<String, bool>? keywords;

  @HiveField(6)
  final List<String>? messageId;

  @HiveField(7)
  final List<String>? references;

  @HiveField(8)
  final List<AttachmentHiveCache>? inlineImages;

  @HiveField(9)
  Map<String, String?>? sMimeStatusHeader;

  @HiveField(10)
  Map<String, String?>? identityHeader;

  DetailedEmailHiveCache({
    required this.emailId,
    required this.timeSaved,
    this.attachments,
    this.emailContentPath,
    this.headers,
    this.keywords,
    this.messageId,
    this.references,
    this.inlineImages,
    this.sMimeStatusHeader,
    this.identityHeader,
  });

  @override
  List<Object?> get props => [
    emailId,
    timeSaved,
    attachments,
    emailContentPath,
    headers,
    keywords,
    messageId,
    references,
    inlineImages,
    sMimeStatusHeader,
    identityHeader,
  ];
}