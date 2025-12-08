import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/remove_company_server_login_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_company_server_login_info_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleCompanyServerLoginInfoExtension on LoginController {
  bool get isDnsLookupFormOnMobile =>
      PlatformInfo.isMobile &&
      loginFormType.value == LoginFormType.dnsLookupForm;

  bool hasPreviousCompanyServerLogin(LoginArguments arguments) {
    return PlatformInfo.isMobile &&
        arguments.loginFormType == LoginFormType.dnsLookupForm &&
        arguments.loginInfo != null;
  }

  bool isCompanyServerLoginFlow(LoginArguments arguments) {
    return PlatformInfo.isMobile &&
        arguments.loginFormType == LoginFormType.dnsLookupForm;
  }

  void saveCompanyServerLoginInfo(String username) {
    log('$runtimeType::saveCompanyServerLoginInfo: Username = $username');
    saveLoginInfoInteractor = getBinding<SaveCompanyServerLoginInfoInteractor>();

    if (saveLoginInfoInteractor != null) {
      consumeState(
        saveLoginInfoInteractor!.execute(
          CompanyServerLoginInfo(email: username),
        ),
      );
    }
  }

  void autoFillPreviousCompanyServerMail(CompanyServerLoginInfo loginInfo) {
    final userEmail = loginInfo.email;
    onUsernameChange(userEmail);
    usernameInputController.text = userEmail;
  }

  Future<void> autoFillCompanyServerMail() async {
    final listUsername = await getAllRecentLoginUsernameAction();
    if (listUsername.isNotEmpty) {
      final username = listUsername.first.username;
      onUsernameChange(username);
      usernameInputController.text = username;
    }
  }

  void removeCompanyServerLoginInfo() {
    removeLoginInfoInteractor =
        getBinding<RemoveCompanyServerLoginInfoInteractor>();
    if (removeLoginInfoInteractor != null) {
      consumeState(removeLoginInfoInteractor!.execute());
    }
  }
}
