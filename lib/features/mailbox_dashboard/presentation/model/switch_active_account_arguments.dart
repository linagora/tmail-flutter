
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SwitchActiveAccountArguments extends RouterArguments {

  final Session sessionCurrentAccount;
  final Session sessionNextAccount;
  final PersonalAccount currentAccount;
  final PersonalAccount nextAccount;

  SwitchActiveAccountArguments({
    required this.sessionCurrentAccount,
    required this.sessionNextAccount,
    required this.currentAccount,
    required this.nextAccount,
  });

  @override
  List<Object> get props => [
    sessionCurrentAccount,
    sessionNextAccount,
    currentAccount,
    nextAccount,
  ];
}