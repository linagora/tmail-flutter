
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/utils/caching_constants.dart';

part 'mailbox_cache.g.dart';

@HiveType(typeId: CachingConstants.MAILBOX_CACHE_IDENTIFY)
class MailboxCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? parentId;

  @HiveField(3)
  final String? role;

  @HiveField(4)
  final int? sortOrder;

  @HiveField(5)
  final int? totalEmails;

  @HiveField(6)
  final int? unreadEmails;

  @HiveField(7)
  final int? totalThreads;

  @HiveField(8)
  final int? unreadThreads;

  @HiveField(9)
  final MailboxRightsCache? myRights;

  @HiveField(10)
  final bool? isSubscribed;

  @HiveField(11)
  final DateTime? lastOpened;

  MailboxCache(
    this.id,
    {
      this.name,
      this.parentId,
      this.role,
      this.sortOrder,
      this.totalEmails,
      this.unreadEmails,
      this.totalThreads,
      this.unreadThreads,
      this.myRights,
      this.isSubscribed,
      this.lastOpened
    }
  );

  @override
  List<Object?> get props => [
    id,
    name,
    parentId,
    role,
    unreadEmails,
    lastOpened,
  ];
}