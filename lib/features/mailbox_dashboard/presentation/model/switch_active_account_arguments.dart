
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SwitchActiveAccountArguments extends RouterArguments {

  final Session session;
  final PersonalAccount? currentAccount;
  final PersonalAccount? nextActiveAccount;

  SwitchActiveAccountArguments({
    required this.session,
    this.currentAccount,
    this.nextActiveAccount,
  });

  @override
  List<Object?> get props => [
    session,
    currentAccount,
    nextActiveAccount,
  ];
}