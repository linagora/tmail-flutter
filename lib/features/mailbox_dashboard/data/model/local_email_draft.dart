import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'local_email_draft.g.dart';

@HiveType(typeId: CachingConstants.LOCAL_EMAIL_DRAFT_CACHE_ID)
class LocalEmailDraft with EquatableMixin {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String composerId;

  @HiveField(2)
  final DateTime savedTime;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final bool? hasRequestReadReceipt;

  @HiveField(5)
  final bool? isMarkAsImportant;

  @HiveField(6)
  final String? displayMode;

  @HiveField(7)
  final int? composerIndex;

  @HiveField(8)
  final int? draftHash;

  @HiveField(9)
  final String? actionType;

  @HiveField(10)
  final String? draftEmailId;

  LocalEmailDraft({
    required this.id,
    required this.composerId,
    required this.savedTime,
    this.email,
    this.hasRequestReadReceipt,
    this.isMarkAsImportant,
    this.displayMode,
    this.composerIndex,
    this.draftHash,
    this.actionType,
    this.draftEmailId,
  });

  @override
  List<Object?> get props => [
    id,
    savedTime,
    email,
    hasRequestReadReceipt,
    isMarkAsImportant,
    displayMode,
    composerIndex,
    composerId,
    draftHash,
    actionType,
    draftEmailId,
  ];
}
