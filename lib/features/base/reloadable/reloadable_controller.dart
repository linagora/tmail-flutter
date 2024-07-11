import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_current_account_cache_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_current_account_cache_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_interactors_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/message_toast_utils.dart';

abstract class ReloadableController extends BaseController {
  final GetSessionInteractor _getSessionInteractor = Get.find<GetSessionInteractor>();
  final GetCurrentAccountCacheInteractor _getCurrentAccountCacheInteractor = Get.find<GetCurrentAccountCacheInteractor>();
  final UpdateCurrentAccountCacheInteractor _updateCurrentAccountCacheInteractor = Get.find<UpdateCurrentAccountCacheInteractor>();

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetCurrentAccountCacheFailure) {
      goToLogin();
    } else if (failure is GetSessionFailure) {
      _handleGetSessionFailure(failure.exception);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetCurrentAccountCacheSuccess) {
      setUpInterceptors(success.account);
      getSessionAction();
    } else if (success is GetSessionSuccess) {
      updateCurrentAccountCache(success.session);
    } else if (success is UpdateCurrentAccountCacheSuccess) {
      dynamicUrlInterceptors.changeBaseUrl(success.apiUrl);
      handleReloaded(success.session);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  /*
  * trigger reload by getting Credential again then setting up Interceptor and retrieving session
  * */
  void reload() {
    getCurrentAccountCache();
  }

  void getCurrentAccountCache() {
    consumeState(_getCurrentAccountCacheInteractor.execute());
  }

  void setUpInterceptors(PersonalAccount personalAccount) {
    dynamicUrlInterceptors.setJmapUrl(personalAccount.baseUrl);
    dynamicUrlInterceptors.changeBaseUrl(personalAccount.baseUrl);

    switch(personalAccount.authenticationType) {
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

  void getSessionAction() {
    consumeState(_getSessionInteractor.execute());
  }

  void _handleGetSessionFailure(dynamic exception) {
    if (currentContext != null && currentOverlayContext != null && exception !is BadCredentialsException) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        MessageToastUtils.getMessageByException(currentContext!, exception) ?? AppLocalizations.of(currentContext!).unknownError
      );
    }
    clearDataAndGoToLoginPage();
  }

  void handleReloaded(Session session) {}

  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapVacationResponse]);
      VacationInteractorsBindings().dependencies();
    } catch(e) {
      logError('ReloadableController::injectVacationBindings(): exception: $e');
    }
  }

  void updateCurrentAccountCache(Session session) {
    consumeState(_updateCurrentAccountCacheInteractor.execute(session));
  }
}