import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SaveToDraftArguments extends RouterArguments {
  final Session session;
  final AccountId accountId;
  final Email newEmail;
  final EmailId? oldEmailId;

  SaveToDraftArguments({
    required this.session,
    required this.accountId,
    required this.newEmail,
    required this.oldEmailId
  });

  @override
  List<Object?> get props => [
    session,
    accountId,
    newEmail,
    oldEmailId,
  ];
}
