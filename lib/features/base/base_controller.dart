import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/services.dart' as services;
import 'package:contact/contact/model/capability_contact.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/base/mixin/logout_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/mdn_interactor_bindings.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/logout_exception.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/contact_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/tmail_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/log_out_oidc_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/bindings/email_rules_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forwarding_interactors_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_firebase_registration_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_firebase_registration_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/web_socket_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/fcm_configuration.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_token_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/web_socket_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

abstract class BaseController extends GetxController
    with MessageDialogActionMixin,
        PopupContextMenuActionMixin,
        LogoutMixin {

  final CachingManager cachingManager = Get.find<CachingManager>();
  final LanguageCacheManager languageCacheManager = Get.find<LanguageCacheManager>();
  final AuthorizationInterceptors authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final AuthorizationInterceptors authorizationIsolateInterceptors = Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag);
  final DynamicUrlInterceptors dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();
  final DeleteCredentialInteractor deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final LogoutOidcInteractor logoutOidcInteractor = Get.find<LogoutOidcInteractor>();
  final DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor = Get.find<DeleteAuthorityOidcInteractor>();
  final AppToast appToast = Get.find<AppToast>();
  final ImagePaths imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils responsiveUtils = Get.find<ResponsiveUtils>();
  final Uuid uuid = Get.find<Uuid>();
  final ApplicationManager applicationManager = Get.find<ApplicationManager>();
  final ToastManager toastManager = Get.find<ToastManager>();
  final TwakeAppManager twakeAppManager = Get.find<TwakeAppManager>();

  bool _isFcmEnabled = false;

  GetStoredFirebaseRegistrationInteractor? _getStoredFirebaseRegistrationInteractor;
  DestroyFirebaseRegistrationInteractor? _destroyFirebaseRegistrationInteractor;

  StreamSubscription<html.Event>? _onBeforeUnloadBrowserSubscription;
  StreamSubscription<html.Event>? _onUnloadBrowserSubscription;

  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  FpsCallback? fpsCallback;

  @override
  void onReady() {
    super.onReady();
    if (PlatformInfo.isWeb) {
      _triggerBrowserReloadListener();
    }
  }

  void _triggerBrowserReloadListener() {
    _onBeforeUnloadBrowserSubscription =
        html.window.onBeforeUnload.listen(onBeforeUnloadBrowserListener);
    _onUnloadBrowserSubscription =
        html.window.onUnload.listen(onUnloadBrowserListener);
  }

  Future<void> onBeforeUnloadBrowserListener(html.Event event) async {}

  Future<void> onUnloadBrowserListener(html.Event event) async {}

  @override
  void onClose() {
    if (PlatformInfo.isWeb) {
      _onBeforeUnloadBrowserSubscription?.cancel();
      _onUnloadBrowserSubscription?.cancel();
    }
    super.onClose();
  }

  void consumeState(Stream<Either<Failure, Success>> newStateStream) async {
    newStateStream.listen(onData, onError: onError, onDone: onDone);
  }

  void dispatchState(Either<Failure, Success> newState) {
    viewState.value = newState;
  }

  void clearState() {
    viewState.value = Right(UIState.idle);
  }

  void onData(Either<Failure, Success> newState) {
    viewState.value = newState;
    viewState.value.fold(onDataFailureViewState, handleSuccessViewState);
  }

  void onError(dynamic error, StackTrace stackTrace) {
    logError('$runtimeType::onError():Error: $error | StackTrace: $stackTrace');
    final isUrgentException = validateUrgentException(error);
    if (isUrgentException) {
      handleUrgentException(exception: error);
    } else {
      handleErrorViewState(error, stackTrace);
    }
  }

  void onDone() {}

  bool validateUrgentException(dynamic exception) {
    return exception is NoNetworkError
      || exception is BadCredentialsException
      || exception is ConnectionError;
  }

  void handleErrorViewState(Object error, StackTrace stackTrace) {}

  void handleUrgentException({Failure? failure, Exception? exception}) {
    if (PlatformInfo.isWeb) {
      handleUrgentExceptionOnWeb(failure: failure, exception: exception);
    } else if (PlatformInfo.isMobile) {
      handleUrgentExceptionOnMobile(failure: failure, exception: exception);
    } else {
      throw NoSupportPlatformException();
    }
  }

  void handleUrgentExceptionOnMobile({Failure? failure, Exception? exception}) {
    logError('$runtimeType::handleUrgentExceptionOnMobile():Failure: $failure | Exception: $exception');
    if (exception is ConnectionError) {
      _handleConnectionErrorException();
    } else if (exception is BadCredentialsException) {
      _handleBadCredentialsException();
    }
  }

  void handleUrgentExceptionOnWeb({Failure? failure, Exception? exception}) {
    logError('$runtimeType::handleUrgentExceptionOnWeb():Failure: $failure | Exception: $exception');
    if (exception is NoNetworkError) {
      _handleNotNetworkErrorException();
    } else if (exception is ConnectionError) {
      _handleConnectionErrorException();
    } else if (exception is BadCredentialsException) {
      _handleBadCredentialsException();
    }
  }

  Future<void> _executeBeforeReconnectAndLogOut() async {
    await executeBeforeReconnect();
    clearDataAndGoToLoginPage();
  }

  void onCancelReconnectWhenSessionExpired() {}

  void _handleConnectionErrorException() {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).connectionError);
    }
  }

  void _handleNotNetworkErrorException() {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).no_internet_connection,
        actionName: AppLocalizations.of(currentContext!).skip,
        onActionClick: ToastView.dismiss,
        leadingSVGIcon: imagePaths.icNotConnection,
        backgroundColor: AppColor.textFieldErrorBorderColor,
        textColor: Colors.white,
        infinityToast: true);
    }
  }

  void _handleBadCredentialsException() {
    log('$runtimeType::_handleBadCredentialsException:');
    if (twakeAppManager.hasComposer) {
      _performSaveAndReconnection();
    } else {
      _performReconnection();
    }
  }

  void _performSaveAndReconnection() {
    if (PlatformInfo.isWeb) {
      _executeBeforeReconnectAndLogOut();
    } else if (PlatformInfo.isMobile) {
      clearDataAndGoToLoginPage();
    }
  }

  void _performReconnection() {
    clearDataAndGoToLoginPage();
  }

  void onDataFailureViewState(Failure failure) {
    log('$runtimeType::onDataFailureViewState:failure = ${failure.runtimeType}');
    if (failure is FeatureFailure) {
      final isUrgentException = validateUrgentException(failure.exception);
      if (isUrgentException) {
        handleUrgentException(failure: failure, exception: failure.exception);
      } else {
        handleFailureViewState(failure);
      }
    } else {
      handleFailureViewState(failure);
    }
  }

  void handleFailureViewState(Failure failure) async {
    logError('$runtimeType::handleFailureViewState():Failure = $failure');
    if (failure is LogoutOidcFailure) {
      if (_isFcmEnabled) {
        _getStoredFirebaseRegistrationFromCache();
      } else {
        await clearDataAndGoToLoginPage();
      }
    } else if (failure is GetStoredFirebaseRegistrationFailure ||
        failure is DestroyFirebaseRegistrationFailure) {
      await clearDataAndGoToLoginPage();
    }
  }

  void handleSuccessViewState(Success success) async {
    log('$runtimeType::handleSuccessViewState():Success = ${success.runtimeType}');
    if (success is LogoutOidcSuccess) {
      if (_isFcmEnabled) {
        _getStoredFirebaseRegistrationFromCache();
      } else {
        await clearDataAndGoToLoginPage();
      }
    } else if (success is GetStoredFirebaseRegistrationSuccess) {
      _destroyFirebaseRegistration(success.firebaseRegistration.id!);
    } else if (success is DestroyFirebaseRegistrationSuccess) {
      await clearDataAndGoToLoginPage();
    }
  }

  void startFpsMeter() {
    FpsManager().start();
    fpsCallback = (fpsInfo) {
      log('$runtimeType::startFpsMeter(): $fpsInfo');
    };
    if (fpsCallback != null) {
      FpsManager().addFpsCallback(fpsCallback!);
    }
  }

  void stopFpsMeter() {
    FpsManager().stop();
    if (fpsCallback != null) {
      FpsManager().removeFpsCallback(fpsCallback!);
    }
  }

  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      ContactAutoCompleteBindings().dependencies();
      requireCapability(session!, accountId!, [tmailContactCapabilityIdentifier]);
      TMailAutoCompleteBindings().dependencies();
    } catch (e) {
      logError('$runtimeType::injectAutoCompleteBindings(): exception: $e');
    }
  }

  void injectMdnBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapMdn]);
      MdnInteractorBindings().dependencies();
    } catch(e) {
      logError('$runtimeType::injectMdnBindings(): exception: $e');
    }
  }

  void injectForwardBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityForward]);
      ForwardingInteractorsBindings().dependencies();
    } catch(e) {
      logError('$runtimeType::injectForwardBindings(): exception: $e');
    }
  }

  void injectRuleFilterBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityRuleFilter]);
      EmailRulesInteractorBindings().dependencies();
    } catch(e) {
      logError('$runtimeType::injectRuleFilterBindings(): exception: $e');
    }
  }

  Future<void> injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      requireCapability(session!, accountId!, [FirebaseCapability.fcmIdentifier]);
      log('$runtimeType::injectFCMBindings: fcmAvailable = ${AppConfig.fcmAvailable}');
      if (AppConfig.fcmAvailable) {
        await FcmConfiguration.initialize();
        FcmInteractorBindings().dependencies();
        FcmService.instance.initialStreamController();
        FcmMessageController.instance.initialize(accountId: accountId, session: session);
        FcmTokenController.instance.initialBindingInteractor();
        await FcmReceiver.instance.onInitialFcmListener();
        if (PlatformInfo.isMobile) {
          await LocalNotificationManager.instance.setUp(groupId: session.username.value);
        }
      } else {
        throw NotSupportFCMException();
      }
    } catch(e) {
      logError('$runtimeType::injectFCMBindings(): exception: $e');
    }
  }

  void injectWebSocket(Session? session, AccountId? accountId) {
    try {
      log('$runtimeType::injectWebSocket:');
      requireCapability(
        session!,
        accountId!,
        [
          CapabilityIdentifier.jmapWebSocket,
          CapabilityIdentifier.jmapWebSocketTicket
        ]
      );
      final wsCapability = session.getCapabilityProperties<WebSocketCapability>(
        accountId,
        CapabilityIdentifier.jmapWebSocket);
      if (wsCapability?.supportsPush != true) {
        throw WebSocketPushNotSupportedException();
      }
      WebSocketInteractorBindings().dependencies();
      WebSocketController.instance.initialize(accountId: accountId, session: session);
    } catch(e) {
      logError('$runtimeType::injectWebSocket(): exception: $e');
    }
  }

  AuthenticationType get authenticationType => authorizationInterceptors.authenticationType;

  bool get isAuthenticatedWithOidc => authenticationType == AuthenticationType.oidc;

  bool _isFcmActivated(Session session, AccountId accountId) =>
    FirebaseCapability.fcmIdentifier.isSupported(session, accountId) && AppConfig.fcmAvailable;

  void goToLogin() {
    if (PlatformInfo.isMobile) {
      navigateToTwakeWelcomePage();
    } else {
      navigateToLoginPage();
    }
  }

  void removeAllPageAndGoToLogin() {
    if (PlatformInfo.isMobile) {
      pushAndPopAll(AppRoutes.twakeWelcome);
    } else {
      navigateToLoginPage();
    }
  }

  void navigateToTwakeWelcomePage() {
    popAndPush(AppRoutes.twakeWelcome);
  }

  void navigateToLoginPage() {
    if (Get.currentRoute == AppRoutes.login) {
      return;
    }
    pushAndPopAll(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.none));
  }

  void logout(
    BuildContext context,
    Session? session,
    AccountId? accountId,
  ) {
    if (PlatformInfo.isMobile) {
      showLogoutConfirmDialog(
        context: context,
        userAddress: session?.getOwnEmailAddress() ?? '',
        onConfirmAction: () => _handleLogoutAction(session, accountId),
      );
    } else {
      _handleLogoutAction(session, accountId);
    }
  }

  Future<void> _handleLogoutAction(Session? session, AccountId? accountId) async {
    if (session == null || accountId == null) {
      await clearDataAndGoToLoginPage();
      return;
    }

    _isFcmEnabled = _isFcmActivated(session, accountId);
    if (isAuthenticatedWithOidc) {
      consumeState(logoutOidcInteractor.execute());
    } else {
      if (_isFcmEnabled) {
        _getStoredFirebaseRegistrationFromCache();
      } else {
        await clearDataAndGoToLoginPage();
      }
    }
  }

  Future<void> logoutToSignInNewAccount({
    required Session session,
    required AccountId accountId,
    required Function onSuccessCallback,
    required Function({Object? exception}) onFailureCallback,
  }) async {
    try {
      _isFcmEnabled = _isFcmActivated(session, accountId);

      if (isAuthenticatedWithOidc) {
        final logoutViewState = await logoutOidcInteractor.execute().last;
        logoutViewState.foldSuccess<LogoutOidcSuccess>(
          onSuccess: (success) async {
            await _handleDeleteFCMAndClearData();
            onSuccessCallback();
          },
          onFailure: (failure) async {
            if (failure is LogoutOidcFailure && _validateUserCancelledLogoutOidcFlow(failure.exception))  {
              await _handleDeleteFCMAndClearData();
              onFailureCallback(exception: UserCancelledLogoutOIDCFlowException());
            } else {
              onFailureCallback();
            }
          },
        );
      } else {
        await _handleDeleteFCMAndClearData();
        onSuccessCallback();
      }
    } catch (e) {
      logError('BaseController::logoutToSignInNewAccount:Exception = $e');
      onFailureCallback();
    }
  }

  bool _validateUserCancelledLogoutOidcFlow(dynamic exception) {
   return exception is services.PlatformException &&
      exception.code == OIDCConstant.endSessionFailedCode;
  }

  Future<void> _handleDeleteFCMAndClearData() async {
    await Future.wait([
      if (_isFcmEnabled)
        _handleDeleteFCMRegistration(),
      clearAllData(),
    ]);
  }

  Future<void> _handleDeleteFCMRegistration() async {
    try {
      _getStoredFirebaseRegistrationInteractor = getBinding<GetStoredFirebaseRegistrationInteractor>();
      final fcmRegistration = await _getStoredFirebaseRegistrationInteractor?.execute().last;

      fcmRegistration?.foldSuccess<GetStoredFirebaseRegistrationSuccess>(
        onSuccess: (success) async {
          _destroyFirebaseRegistrationInteractor = getBinding<DestroyFirebaseRegistrationInteractor>();
          await _destroyFirebaseRegistrationInteractor?.execute(success.firebaseRegistration.id!).last;
        },
        onFailure: (failure) {},
      );
    } catch (e) {
      logError('BaseController::_handleDeleteFCMRegistration:Exception = $e');
    }
  }

  void _destroyFirebaseRegistration(FirebaseRegistrationId firebaseRegistrationId) async {
    _destroyFirebaseRegistrationInteractor = getBinding<DestroyFirebaseRegistrationInteractor>();
    if (_destroyFirebaseRegistrationInteractor != null) {
      consumeState(_destroyFirebaseRegistrationInteractor!.execute(firebaseRegistrationId));
    } else {
      await clearDataAndGoToLoginPage();
    }
  }

  void _getStoredFirebaseRegistrationFromCache() async {
    _getStoredFirebaseRegistrationInteractor = getBinding<GetStoredFirebaseRegistrationInteractor>();
    if (_getStoredFirebaseRegistrationInteractor != null) {
      consumeState(_getStoredFirebaseRegistrationInteractor!.execute());
    } else {
      await clearDataAndGoToLoginPage();
    }
  }

  Future<void> executeBeforeReconnect() async {
    final beforeReconnectManager = getBinding<BeforeReconnectManager>();
    await beforeReconnectManager?.executeBeforeReconnectListeners();
  }

  Future<void> clearDataAndGoToLoginPage() async {
    log('$runtimeType::clearDataAndGoToLoginPage:');
    await clearAllData();
    removeAllPageAndGoToLogin();
  }

  Future<void> clearAllData() async {
    try {
      if (isAuthenticatedWithOidc) {
        await _clearOidcAuthData();
      } else {
        await _clearBasicAuthData();
      }
    } catch (e) {
      logError('BaseController::clearAllData:Exception = $e');
    }
  }

  Future<void> _clearBasicAuthData() async {
    await Future.wait([
      deleteCredentialInteractor.execute(),
      cachingManager.clearAll(),
      languageCacheManager.removeLanguage(),
    ]);
    if (PlatformInfo.isMobile) {
      await cachingManager.clearAllFileInStorage();
    }
    authorizationInterceptors.clear();
    authorizationIsolateInterceptors.clear();
    await cachingManager.closeHive();
  }

  Future<void> _clearOidcAuthData() async {
    await Future.wait([
      deleteAuthorityOidcInteractor.execute(),
      cachingManager.clearAll(),
      languageCacheManager.removeLanguage(),
    ]);
    if (PlatformInfo.isMobile) {
      await cachingManager.clearAllFileInStorage();
    }
    authorizationIsolateInterceptors.clear();
    authorizationInterceptors.clear();
    await cachingManager.closeHive();
  }

  int getMinInputLengthAutocomplete({
    required Session session,
    required AccountId accountId,
  }) {
    final minInputLength = session.getMinInputLengthAutocomplete(accountId);
    return minInputLength?.value.toInt() ?? AppConfig.defaultMinInputLengthAutocomplete;
  }

  void showRetryToast(FeatureFailure failure) {
    if (currentOverlayContext == null || currentContext == null) return;

    final exception = failure.exception;
    final errorMessage = exception is MethodLevelErrors && exception.message != null
      ? AppLocalizations.of(currentContext!).unexpectedError('${exception.message!}')
      : AppLocalizations.of(currentContext!).unknownError;

    appToast.showToastMessageWithMultipleActions(
      currentOverlayContext!,
      errorMessage,
      actions: [
        if (failure.onRetry != null)
          (
            actionName: AppLocalizations.of(currentContext!).retry,
            onActionClick: () => consumeState(failure.onRetry!),
            actionIcon: SvgPicture.asset(imagePaths.icUndo),
          ),
        (
          actionName: AppLocalizations.of(currentContext!).close,
          onActionClick: () => ToastView.dismiss(),
          actionIcon: SvgPicture.asset(
            imagePaths.icClose,
            colorFilter: Colors.white.asFilter(),
          ),
        )
      ],
      backgroundColor: AppColor.toastErrorBackgroundColor,
      textColor: Colors.white,
      infinityToast: true,
    );
  }
}
