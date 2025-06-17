
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'sending_email_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.SENDING_EMAIL_HIVE_CACHE_ID)
class SendingEmailHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String sendingId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String emailActionType;

  @HiveField(3)
  final DateTime createTime;

  @HiveField(4)
  final String? sentMailboxId;

  @HiveField(5)
  final String? emailIdDestroyed;

  @HiveField(6)
  final String? emailIdAnsweredOrForwarded;

  @HiveField(7)
  final String? identityId;

  @HiveField(8)
  final String? mailboxNameRequest;

  @HiveField(9)
  final String sendingState;

  @HiveField(10)
  final String? previousEmailId;

  SendingEmailHiveCache(
    this.sendingId,
    this.email,
    this.emailActionType,
    this.createTime,
    this.sentMailboxId,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.identityId,
    this.mailboxNameRequest,
    this.sendingState,
    this.previousEmailId,
  );

  @override
  List<Object?> get props => [
    sendingId,
    email,
    emailActionType,
    createTime,
    sentMailboxId,
    emailIdDestroyed,
    emailIdAnsweredOrForwarded,
    identityId,
    mailboxNameRequest,
    sendingState,
    previousEmailId,
  ];
}