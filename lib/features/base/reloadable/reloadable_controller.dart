import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/add_account_id_to_active_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/message_toast_utils.dart';

abstract class ReloadableController extends BaseController {
  final GetSessionInteractor getSessionInteractor = Get.find<GetSessionInteractor>();
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor = Get.find<GetAuthenticatedAccountInteractor>();
  final AddAccountIdToActiveAccountInteractor _addAccountIdToActiveAccountInteractor = Get.find<AddAccountIdToActiveAccountInteractor>();

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetSessionFailure) {
      _handleGetSessionFailure(failure.exception);
    } else if (failure is GetAuthenticatedAccountFailure) {
      if (PlatformInfo.isMobile) {
        navigateToTwakeIdPage();
      } else {
        navigateToLoginPage(arguments: LoginArguments(LoginFormType.none));
      }
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

  void getSessionAction({AccountId? accountId, UserName? userName}) {
    consumeState(getSessionInteractor.execute(
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
    clearAllDataAndBackToLogin();
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    final session = success.session;
    final personalAccount = session.personalAccount;
    final apiUrl = session.getQualifiedApiUrl(baseUrl: dynamicUrlInterceptors.jmapUrl);
    if (apiUrl.isNotEmpty) {
      dynamicUrlInterceptors.changeBaseUrl(apiUrl);
      _addAccountIdToActiveAccount(
        personalAccount.accountId,
        session.username,
        apiUrl
      );
      handleReloaded(session);
    } else {
      clearAllDataAndBackToLogin();
    }
  }

  void handleReloaded(Session session) {}

  void _addAccountIdToActiveAccount(
    AccountId accountId,
    UserName userName,
    String apiUrl,
  ) {
    consumeState(_addAccountIdToActiveAccountInteractor.execute(
      accountId,
      apiUrl,
      userName
    ));
  }

  void switchActiveAccount({
    required PersonalAccount currentAccount,
    required PersonalAccount nextAccount,
    required Session sessionCurrentAccount,
  }) async {
    await popAndPush(
      AppRoutes.home,
      arguments: LoginNavigateArguments(
        navigateType: LoginNavigateType.switchActiveAccount,
        currentAccount: currentAccount,
        sessionCurrentAccount: sessionCurrentAccount,
        nextActiveAccount: nextAccount,
      ));
  }
}