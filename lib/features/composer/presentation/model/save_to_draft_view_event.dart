import 'package:core/presentation/state/success.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

class SaveToDraftViewEvent extends ViewEvent {
  final BuildContext context;
  final Session session;
  final AccountId accountId;
  final MailboxId draftMailboxId;
  final EmailId? emailIdEditing;
  final ComposerArguments? arguments;

  SaveToDraftViewEvent({
    required this.context,
    required this.session,
    required this.accountId,
    required this.draftMailboxId,
    this.emailIdEditing,
    this.arguments,
  });

  @override
  List<Object?> get props => [
    context,
    session,
    accountId,
    draftMailboxId,
    emailIdEditing,
    arguments,
  ];
}