import 'package:core/presentation/state/success.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/user/user_profile.dart';

class SaveToDraftViewEvent extends ViewEvent {
  final BuildContext context;
  final Session session;
  final AccountId accountId;
  final UserProfile userProfile;
  final MailboxId draftMailboxId;
  final EmailId? emailIdEditing;

  SaveToDraftViewEvent({
    required this.context,
    required this.session,
    required this.accountId,
    required this.userProfile,
    required this.draftMailboxId,
    this.emailIdEditing
  });

  @override
  List<Object?> get props => [
    context,
    session,
    accountId,
    userProfile,
    draftMailboxId,
    emailIdEditing,
  ];
}