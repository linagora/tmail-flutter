
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class LoginNavigateArguments extends RouterArguments {

  final LoginNavigateType navigateType;
  final PersonalAccount? currentAccount;

  LoginNavigateArguments(this.navigateType, this.currentAccount);

  @override
  List<Object?> get props => [navigateType, currentAccount];
}