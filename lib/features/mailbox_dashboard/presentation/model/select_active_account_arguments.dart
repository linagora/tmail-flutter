
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SelectActiveAccountArguments extends RouterArguments {

  final Session session;
  final PersonalAccount activeAccount;

  SelectActiveAccountArguments({
    required this.session,
    required this.activeAccount,
  });

  @override
  List<Object?> get props => [
    session,
    activeAccount,
  ];
}