import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';

class EmptyMailboxFolderArguments with EquatableMixin {
  final Session session;
  final AccountId accountId;
  final MailboxId mailboxId;
  final ThreadAPI threadAPI;
  final EmailAPI emailAPI;
  final RootIsolateToken isolateToken;

  EmptyMailboxFolderArguments(
    this.session,
    this.threadAPI,
    this.emailAPI,
    this.accountId,
    this.mailboxId,
    this.isolateToken,
  );

  @override
  List<Object?> get props => [
    session,
    accountId,
    emailAPI,
    threadAPI,
    mailboxId,
    isolateToken,
  ];
}
