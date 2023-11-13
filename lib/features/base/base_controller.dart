import 'package:contact/contact/model/capability_contact.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/views/toast/tmail_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/fps_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/mdn_interactor_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
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
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_subscription_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_fcm_subscription_local.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_fcm_subscription_local_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/fcm_configuration.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

abstract class BaseController extends GetxController
    with MessageDialogActionMixin,
        PopupContextMenuActionMixin {

  final CachingManager cachingManager = Get.find<CachingManager>();
  final languageCacheManager = Get.find<LanguageCacheManager>();
  final authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final authorizationIsolateInterceptors = Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag);
  final DeleteCredentialInteractor deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final LogoutOidcInteractor logoutOidcInteractor = Get.find<LogoutOidcInteractor>();
  final DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor = Get.find<DeleteAuthorityOidcInteractor>();
  final _fcmReceiver = FcmReceiver.instance;
  bool _isFcmEnabled = false;

  GetFCMSubscriptionLocalInteractor? _getSubscriptionLocalInteractor;
  DestroySubscriptionInteractor? _destroySubscriptionInteractor;

  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  FpsCallback? fpsCallback;

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
    viewState.value.fold(
      (failure) {
        if (failure is FeatureFailure) {
          final exception = _performFilterExceptionInError(failure.exception);
          logError('BaseController::onData:exception: $exception');
          if (exception != null) {
            handleExceptionAction(failure: failure, exception: exception);
          } else {
            handleFailureViewState(failure);
          }
        } else {
          handleFailureViewState(failure);
        }
      },
      handleSuccessViewState);
  }

  void onError(Object error, StackTrace stackTrace) {
    logError('BaseController::onError():error: $error | stackTrace: $stackTrace');
    final exception = _performFilterExceptionInError(error);
    if (exception != null) {
      handleExceptionAction(exception: exception);
    } else {
      handleErrorViewState(error, stackTrace);
    }
  }

  void onDone() {}

  Exception? _performFilterExceptionInError(dynamic error) {
    logError('BaseController::_performFilterExceptionInError(): $error');
    if (error is NoNetworkError || error is ConnectionTimeout || error is InternalServerError) {
      if (PlatformInfo.isWeb && currentOverlayContext != null && currentContext != null) {
        _appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).no_internet_connection,
          actionName: AppLocalizations.of(currentContext!).skip,
          onActionClick: ToastView.dismiss,
          leadingSVGIcon: _imagePaths.icNotConnection,
          backgroundColor: AppColor.textFieldErrorBorderColor,
          textColor: Colors.white,
          infinityToast: true,
        );
      }
      return error;
    } else if (error is BadCredentialsException) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).badCredentials
        );
      }
      return error;
    } else if (error is ConnectionError) {
      if (authorizationInterceptors.isAppRunning && currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).connectionError
        );
      }
      return error;
    }

    return null;
  }

  void handleErrorViewState(Object error, StackTrace stackTrace) {}

  void handleExceptionAction({Failure? failure, Exception? exception}) {
    logError('BaseController::handleExceptionAction():failure: $failure | exception: $exception');
    if (!authorizationInterceptors.isAppRunning) {
      return;
    }
    if (exception is BadCredentialsException || exception is ConnectionError) {
      performInvokeLogoutAction();
    }
  }

  void handleFailureViewState(Failure failure) {
    logError('BaseController::handleFailureViewState(): ${failure.runtimeType}');
    if (failure is LogoutOidcFailure) {
      if (_isFcmEnabled) {
        _getSubscriptionLocalAction();
      } else {
        _logoutOIDCAction();
      }
    } else if (failure is GetFCMSubscriptionLocalFailure) {
      performInvokeLogoutAction();
    } else if (failure is DestroySubscriptionFailure) {
      performInvokeLogoutAction();
    }
  }

  void handleSuccessViewState(Success success) {
    log('BaseController::handleSuccessViewState(): ${success.runtimeType}');
    if (success is LogoutOidcSuccess) {
      if (_isFcmEnabled) {
        _getSubscriptionLocalAction();
      } else {
        _logoutOIDCAction();
      }
    } else if (success is GetFCMSubscriptionLocalSuccess) {
      final subscriptionId = success.fcmSubscription.subscriptionId;
      _destroySubscriptionAction(subscriptionId);
    } else if (success is DestroySubscriptionSuccess) {
      performInvokeLogoutAction();
    }
  }

  void startFpsMeter() {
    FpsManager().start();
    fpsCallback = (fpsInfo) {
      log('BaseController::startFpsMeter(): $fpsInfo');
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
      logError('BaseController::injectAutoCompleteBindings(): exception: $e');
    }
  }

  void injectMdnBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapMdn]);
      MdnInteractorBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectMdnBindings(): exception: $e');
    }
  }

  void injectForwardBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityForward]);
      ForwardingInteractorsBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectForwardBindings(): exception: $e');
    }
  }

  void injectRuleFilterBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityRuleFilter]);
      EmailRulesInteractorBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectRuleFilterBindings(): exception: $e');
    }
  }

  void injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      requireCapability(session!, accountId!, [FirebaseCapability.fcmIdentifier]);
      if (AppConfig.fcmAvailable) {
        final mapEnvData = Map<String, String>.from(dotenv.env);
        await AppUtils.loadFcmConfigFileToEnv(currentMapEnvData: mapEnvData);
        FcmConfiguration.initialize();
        FcmInteractorBindings().dependencies();
        FcmMessageController.instance.initializeFromAccountId(accountId, session);
      } else {
        throw NotSupportFCMException();
      }
    } catch(e) {
      logError('BaseController::injectFCMBindings(): exception: $e');
    }
  }

  AuthenticationType get authenticationType => authorizationInterceptors.authenticationType;

  bool get isAuthenticatedWithOidc => authenticationType == AuthenticationType.oidc;

  bool _isFcmActivated(Session session, AccountId accountId) =>
    [FirebaseCapability.fcmIdentifier].isSupported(session, accountId) && AppConfig.fcmAvailable;

  void goToLogin({LoginArguments? arguments}) {
    if (Get.currentRoute != AppRoutes.login) {
      pushAndPopAll(AppRoutes.login, arguments: arguments);
    }
  }

  void logout(Session? session, AccountId? accountId) {
    if (session == null || accountId == null) {
      logError('BaseController::logout(): Session is $session OR AccountId is $accountId');
      performInvokeLogoutAction();
      return;
    }
    _isFcmEnabled = _isFcmActivated(session, accountId);
    if (isAuthenticatedWithOidc) {
      consumeState(logoutOidcInteractor.execute());
    } else {
      if (_isFcmEnabled) {
        _getSubscriptionLocalAction();
      } else {
        _logoutAction();
      }
    }
  }

  void _destroySubscriptionAction(String subscriptionId) {
    try {
      _destroySubscriptionInteractor = Get.find<DestroySubscriptionInteractor>();
      consumeState(_destroySubscriptionInteractor!.execute(subscriptionId));
    } catch(e) {
      logError('BaseController::destroySubscriptionAction(): exception: $e');
      performInvokeLogoutAction();
    }
  }

  void _getSubscriptionLocalAction() {
    try {
      _getSubscriptionLocalInteractor = Get.find<GetFCMSubscriptionLocalInteractor>();
      consumeState(_getSubscriptionLocalInteractor!.execute());
    } catch (e) {
      logError('BaseController::getSubscriptionLocalAction(): exception: $e');
      performInvokeLogoutAction();
    }
  }

  void performInvokeLogoutAction() {
    log('BaseController::performInvokeLogoutAction():');
    if (isAuthenticatedWithOidc) {
      _logoutOIDCAction();
    } else {
      _logoutAction();
    }
  }

  void _logoutAction() async {
    log('BaseController::_logoutAction():');
    await Future.wait([
      deleteCredentialInteractor.execute(),
      cachingManager.clearAll(),
      languageCacheManager.removeLanguage(),
    ]);
    cachingManager.clearAllFileInStorage();
    authorizationInterceptors.clear();
    authorizationIsolateInterceptors.clear();
    if (_isFcmEnabled) {
      _fcmReceiver.deleteFcmToken();
    }
    await cachingManager.closeHive();
    goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
  }

  void _logoutOIDCAction() async {
    log('BaseController::_logoutOIDCAction():');
    await Future.wait([
      deleteAuthorityOidcInteractor.execute(),
      cachingManager.clearAll(),
      languageCacheManager.removeLanguage(),
    ]);
    cachingManager.clearAllFileInStorage();
    authorizationIsolateInterceptors.clear();
    authorizationInterceptors.clear();
    if (_isFcmEnabled) {
      _fcmReceiver.deleteFcmToken();
    }
    await cachingManager.closeHive();
    goToLogin(arguments: LoginArguments(LoginFormType.ssoForm));
  }
}
