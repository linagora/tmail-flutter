import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';

class MoveFolderContentIsolateArguments with EquatableMixin {
  final Session session;
  final AccountId accountId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final bool markAsRead;
  final ThreadAPI threadAPI;
  final EmailAPI emailAPI;
  final RootIsolateToken isolateToken;

  MoveFolderContentIsolateArguments({
    required this.session,
    required this.threadAPI,
    required this.emailAPI,
    required this.accountId,
    required this.currentMailboxId,
    required this.destinationMailboxId,
    required this.isolateToken,
    this.markAsRead = false,
  });

  @override
  List<Object?> get props => [
        session,
        accountId,
        threadAPI,
        emailAPI,
        currentMailboxId,
        destinationMailboxId,
        isolateToken,
        markAsRead,
      ];
}
