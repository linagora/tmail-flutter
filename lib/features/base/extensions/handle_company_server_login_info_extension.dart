import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_company_server_login_info_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleCompanyServerLoginInfoExtension on BaseController {
  void getCompanyServerLoginInfo({bool popAllRoute = true}) {
    final getLoginInfoInteractor =
      getBinding<GetCompanyServerLoginInfoInteractor>();

    if (getLoginInfoInteractor == null) {
      handleGetCompanyServerLoginInfoFailure(popAllRoute: popAllRoute);
      return;
    }

    consumeState(
      getLoginInfoInteractor.execute(popAllRoute: popAllRoute),
    );
  }

  void handleGetCompanyServerLoginInfoSuccess(
    CompanyServerLoginInfo info, {
    bool popAllRoute = true,
  }) {
    log('$runtimeType::handleGetCompanyServerLoginInfoSuccess: Info = $info, popAllRoute = $popAllRoute');
    final arguments = LoginArguments(
      LoginFormType.dnsLookupForm,
      loginInfo: info,
    );
    if (popAllRoute) {
      pushAndPopAll(AppRoutes.login, arguments: arguments);
    } else {
      popAndPush(AppRoutes.login, arguments: arguments);
    }
  }

  void handleGetCompanyServerLoginInfoFailure({bool popAllRoute = true}) {
    if (popAllRoute) {
      pushAndPopAll(AppRoutes.twakeWelcome);
    } else {
      popAndPush(AppRoutes.twakeWelcome);
    }
  }
}
