
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class RestoreActiveAccountArguments extends RouterArguments {

  final PersonalAccount currentAccount;
  final Session session;
  final dynamic exception;

  RestoreActiveAccountArguments({
    required this.currentAccount,
    required this.session,
    this.exception,
  });

  @override
  List<Object?> get props => [
    currentAccount,
    session,
    exception,
  ];
}