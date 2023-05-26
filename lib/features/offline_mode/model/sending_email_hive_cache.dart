
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'sending_email_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.SENDING_EMAIL_HIVE_CACHE_ID)
class SendingEmailHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String sendingId;

  @HiveField(1)
  final Map<String, dynamic> email;

  @HiveField(2)
  final String emailActionType;

  @HiveField(3)
  final String? sentMailboxId;

  @HiveField(4)
  final String? emailIdDestroyed;

  @HiveField(5)
  final String? emailIdAnsweredOrForwarded;

  @HiveField(6)
  final String? identityId;

  @HiveField(7)
  final String? mailboxNameRequest;

  @HiveField(8)
  final String? creationIdRequest;

  SendingEmailHiveCache(
    this.sendingId,
    this.email,
    this.emailActionType,
    this.sentMailboxId,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.identityId,
    this.mailboxNameRequest,
    this.creationIdRequest
  );

  @override
  List<Object?> get props => [
    sendingId,
    email,
    emailActionType,
    sentMailboxId,
    emailIdDestroyed,
    emailIdAnsweredOrForwarded,
    identityId,
    mailboxNameRequest,
    creationIdRequest
  ];
}