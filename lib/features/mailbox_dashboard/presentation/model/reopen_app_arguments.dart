import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class ReopenAppArguments extends RouterArguments {

  final Session? session;
  final PersonalAccount personalAccount;

  ReopenAppArguments({required this.personalAccount, this.session});

  @override
  List<Object?> get props => [personalAccount, session];
}