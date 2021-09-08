
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class ComposerArguments with EquatableMixin {
  final EmailActionType emailActionType;
  final PresentationEmail? presentationEmail;
  final EmailContent? emailContent;
  final Session session;
  final UserProfile userProfile;
  final Map<Role, MailboxId> mapMailboxId;

  ComposerArguments({
    this.emailActionType = EmailActionType.compose,
    this.presentationEmail,
    this.emailContent,
    required this.session,
    required this.userProfile,
    required this.mapMailboxId,
  });

  @override
  List<Object?> get props => [
    emailActionType,
    presentationEmail,
    emailContent,
    session,
    userProfile,
    mapMailboxId,
  ];
}