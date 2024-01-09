import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/message_toast_utils.dart';

abstract class ReloadableController extends BaseController {
  final GetSessionInteractor _getSessionInteractor = Get.find<GetSessionInteractor>();
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor = Get.find<GetAuthenticatedAccountInteractor>();
  final UpdateAuthenticationAccountInteractor _updateAuthenticationAccountInteractor = Get.find<UpdateAuthenticationAccountInteractor>();

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetSessionFailure) {
      _handleGetSessionFailure(failure.exception);
    } else if (failure is GetAuthenticatedAccountFailure) {
      goToLogin(
        arguments: LoginArguments(
          PlatformInfo.isMobile
            ? LoginFormType.dnsLookupForm
            : LoginFormType.none
        )
      );
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAuthenticatedAccountSuccess) {
      setUpInterceptors(success.account);
      getSessionAction(
        accountId: success.account.accountId,
        userName: success.account.userName
      );
    } else if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    }
  }

  /*
  * trigger reload by getting Credential again then setting up Interceptor and retrieving session
  * */
  void reload() {
    getAuthenticatedAccountAction();
  }

  void getAuthenticatedAccountAction() {
    consumeState(_getAuthenticatedAccountInteractor.execute());
  }

  void setUpInterceptors(PersonalAccount personalAccount) {
    dynamicUrlInterceptors.setJmapUrl(personalAccount.baseUrl);
    dynamicUrlInterceptors.changeBaseUrl(personalAccount.baseUrl);

    switch(personalAccount.authType) {
      case AuthenticationType.oidc:
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: personalAccount.tokenOidc,
          newConfig: personalAccount.tokenOidc!.oidcConfiguration
        );
        authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
          newToken: personalAccount.tokenOidc,
          newConfig: personalAccount.tokenOidc!.oidcConfiguration
        );
        break;
      case AuthenticationType.basic:
        authorizationInterceptors.setBasicAuthorization(
          personalAccount.basicAuth!.userName,
          personalAccount.basicAuth!.password,
        );
        authorizationIsolateInterceptors.setBasicAuthorization(
          personalAccount.basicAuth!.userName,
          personalAccount.basicAuth!.password,
        );
        break;
      default:
        break;
    }
  }

  void getSessionAction({AccountId? accountId, UserName? userName}) {
    consumeState(_getSessionInteractor.execute(
      accountId: accountId,
      userName: userName
    ));
  }

  void _handleGetSessionFailure(dynamic exception) {
    if (currentContext != null || currentOverlayContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        MessageToastUtils.getMessageByException(currentContext!, exception) ?? AppLocalizations.of(currentContext!).unknownError
      );
    }
    clearDataAndGoToLoginPage();
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    final session = success.session;
    final personalAccount = session.personalAccount;
    final apiUrl = session.getQualifiedApiUrl(baseUrl: dynamicUrlInterceptors.jmapUrl);
    if (apiUrl.isNotEmpty) {
      dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      updateAuthenticationAccount(session, personalAccount.accountId, session.username);
      handleReloaded(session);
    } else {
      clearDataAndGoToLoginPage();
    }
  }

  void handleReloaded(Session session) {}

  void updateAuthenticationAccount(Session session, AccountId accountId, UserName userName) {
    final apiUrl = session.getQualifiedApiUrl(baseUrl: dynamicUrlInterceptors.jmapUrl);
    if (apiUrl.isNotEmpty) {
      consumeState(_updateAuthenticationAccountInteractor.execute(accountId, apiUrl, userName));
    }
  }
}