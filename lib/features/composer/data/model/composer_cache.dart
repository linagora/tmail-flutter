import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'composer_cache.g.dart';

@HiveType(typeId: CachingConstants.COMPOSER_HIVE_CACHE_IDENTIFY)
class ComposerCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final EmailActionType emailActionType;

  @HiveField(1)
  final PresentationEmail? presentationEmail;

  @HiveField(2)
  final List<EmailContent>? emailContents;

  @HiveField(3)
  final EmailAddress? emailAddress;

  @HiveField(4)
  final List<Attachment>? attachments;

  @HiveField(5)
  final Role? mailboxRole;



  ComposerCache({
    this.emailActionType = EmailActionType.compose,
    this.presentationEmail,
    this.emailContents,
    this.attachments,
    this.mailboxRole,
    this.emailAddress,
  });

  @override
  List<Object?> get props => [emailActionType, presentationEmail, emailContents, emailAddress, attachments, mailboxRole];
}
