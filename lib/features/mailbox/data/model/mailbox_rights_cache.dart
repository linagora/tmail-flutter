
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'mailbox_rights_cache.g.dart';

@HiveType(typeId: CachingConstants.MAILBOX_RIGHTS_CACHE_IDENTIFY)
class MailboxRightsCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final bool mayReadItems;

  @HiveField(1)
  final bool mayAddItems;

  @HiveField(2)
  final bool mayRemoveItems;

  @HiveField(3)
  final bool maySetSeen;

  @HiveField(4)
  final bool maySetKeywords;

  @HiveField(5)
  final bool mayCreateChild;

  @HiveField(6)
  final bool mayRename;

  @HiveField(7)
  final bool mayDelete;

  @HiveField(8)
  final bool maySubmit;

  MailboxRightsCache(
    this.mayReadItems,
    this.mayAddItems,
    this.mayRemoveItems,
    this.maySetSeen,
    this.maySetKeywords,
    this.mayCreateChild,
    this.mayRename,
    this.mayDelete,
    this.maySubmit
  );

  @override
  List<Object?> get props => [
    mayReadItems,
    mayAddItems,
    mayRemoveItems,
    maySetSeen,
    maySetKeywords,
    mayCreateChild,
    mayRename,
    mayDelete,
    maySubmit
  ];
}