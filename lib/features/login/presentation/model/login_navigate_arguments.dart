
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class LoginNavigateArguments extends RouterArguments {

  final LoginNavigateType navigateType;
  final PersonalAccount? currentAccount;
  final Session? sessionCurrentAccount;
  final PersonalAccount? nextActiveAccount;

  LoginNavigateArguments({
    required this.navigateType,
    this.currentAccount,
    this.sessionCurrentAccount,
    this.nextActiveAccount,
  });

  @override
  List<Object?> get props => [
    navigateType,
    currentAccount,
    sessionCurrentAccount,
    nextActiveAccount,
  ];
}