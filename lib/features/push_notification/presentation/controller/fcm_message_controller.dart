
import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/extensions/sentry_cache_extensions.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_token_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/push_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/label_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class FcmMessageController extends PushBaseController {
  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;

  FcmMessageController._internal();

  static final FcmMessageController _instance = FcmMessageController._internal();

  static FcmMessageController get instance => _instance;

  @override
  void initialize({AccountId? accountId, Session? session}) {
    try {
      super.initialize(accountId: accountId, session: session);

      _listenTokenStream();
      _listenBackgroundMessageStream();
    } catch (e, st) {
      logError(
        'FcmMessageController::initialize: throw exception',
        exception: e,
        stackTrace: st,
      );
    }
  }

  void _listenBackgroundMessageStream() {
    FcmService.instance.backgroundMessageStreamController?.stream
        .debounceTime(const Duration(
          milliseconds: FcmUtils.durationBackgroundMessageComing,
        ))
        .listen(
          _handleBackgroundMessageAction,
          onError: (e, st) {
            logError(
              'FcmMessageController::_listenBackgroundMessageStream',
              exception: e,
              stackTrace: st,
            );
          },
        );
  }

  void _listenTokenStream() {
    FcmService.instance.fcmTokenStreamController
      ?.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationRefreshToken))
      .listen(
        FcmTokenController.instance.onFcmTokenChanged,
        onError: (e, st) {
          logError(
            'FcmMessageController::_listenTokenStream',
            exception: e,
            stackTrace: st,
          );
        },
      );
  }

  void _handleBackgroundMessageAction(Map<String, dynamic> payloadData) async {
    logTrace('FcmMessageController::_handleBackgroundMessageAction():payloadData keys: ${payloadData.keys.toList()}');
    final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(payloadData);
    if (stateChange == null) {
      logTrace('FcmMessageController::_handleBackgroundMessageAction(): stateChange is null');
      return;
    } else {
      logTrace('FcmMessageController::_handleBackgroundMessageAction(): stateChange: ${stateChange.toString()}');
    }
    _getAuthenticatedAccount(stateChange: stateChange);
  }

  Future<void> initialAppConfig() async {
    try {
      await MainBindings().dependencies();
      await HiveCacheConfig.instance.setUp();

      HomeBindings().dependencies();
      MailboxDashBoardBindings().dependencies();
      FcmInteractorBindings().dependencies();

      _getInteractorBindings();
    } catch (e, st) {
      logError(
        'FcmMessageController::initialAppConfig: throw exception',
        exception: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> setUpSentryConfiguration() async {
    try {
      final cacheManager = getBinding<SentryConfigurationCacheManager>();
      if (cacheManager == null) {
        logWarning('FcmMessageController::setUpSentryConfiguration: SentryConfigurationCacheManager is null');
        return;
      }

      final SentryConfigurationCache configCache;
      try {
        configCache = await cacheManager.getSentryConfiguration();
      } catch (e) {
        logWarning('FcmMessageController::setUpSentryConfiguration: SentryConfiguration not cached: $e');
        return;
      }

      final sentryConfig = configCache.toSentryConfig();
      if (!sentryConfig.isAvailable) {
        logWarning('FcmMessageController::setUpSentryConfiguration: SentryConfiguration is not available');
        return;
      }

      await SentryManager.instance.initializeWithSentryConfig(sentryConfig);

      try {
        final userCache = await cacheManager.getSentryUser();
        SentryManager.instance.setUser(userCache.toSentryUser());
      } catch (e) {
        logTrace('FcmMessageController::setUpSentryConfiguration: Sentry user not cached: $e');
        // Acceptable — Sentry initialized without user context
      }
    } catch (e, st) {
      logError(
        'FcmMessageController::setUpSentryConfiguration: throw exception',
        exception: e,
        stackTrace: st,
      );
    }
  }

  void _getInteractorBindings() {
    _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
    _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
    _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
    _getSessionInteractor = getBinding<GetSessionInteractor>();

    FcmTokenController.instance.initialBindingInteractor();
  }

  void _getAuthenticatedAccount({required StateChange stateChange}) {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute(stateChange: stateChange));
    } else {
      logTrace(
        'GetAuthenticatedAccountInteractor is null',
      );
    }
  }

  void _handleGetAccountByOidcSuccess(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors?.setJmapUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
      newToken: storedTokenOidcSuccess.tokenOidc,
      newConfig: storedTokenOidcSuccess.oidcConfiguration,
    );
    if (PlatformInfo.isAndroid) {
      _dynamicUrlInterceptors?.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
      _getSessionAction(stateChange: storedTokenOidcSuccess.stateChange);
    } else {
      _dispatchPushOnNonAndroid(
        apiUrl: storedTokenOidcSuccess.personalAccount.apiUrl,
        accountId: storedTokenOidcSuccess.personalAccount.accountId,
        username: storedTokenOidcSuccess.personalAccount.userName,
        stateChange: storedTokenOidcSuccess.stateChange,
      );
    }
  }

  void _handleGetAccountByBasicAuthSuccess(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors?.setJmapUrl(credentialViewState.baseUrl.toString());
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName,
      credentialViewState.password,
    );
    if (PlatformInfo.isAndroid) {
      _dynamicUrlInterceptors?.changeBaseUrl(credentialViewState.baseUrl.toString());
      _getSessionAction(stateChange: credentialViewState.stateChange);
    } else {
      _dispatchPushOnNonAndroid(
        apiUrl: credentialViewState.personalAccount.apiUrl,
        accountId: credentialViewState.personalAccount.accountId,
        username: credentialViewState.personalAccount.userName,
        stateChange: credentialViewState.stateChange,
      );
    }
  }

  void _dispatchPushOnNonAndroid({
    required String? apiUrl,
    required AccountId? accountId,
    required UserName? username,
    required StateChange? stateChange,
  }) {
    _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);
    final canPush = accountId != null && username != null && stateChange != null;
    if (!canPush) {
      logTrace('FcmMessageController::_dispatchPushOnNonAndroid: accountId or username or stateChange is null');
      return;
    }
    _pushActionFromRemoteMessageBackground(
      accountId: accountId,
      userName: username,
      stateChange: stateChange,
    );
  }

  void _getSessionAction({StateChange? stateChange}) {
    if (_getSessionInteractor != null) {
      consumeState(_getSessionInteractor!.execute(stateChange: stateChange));
    } else {
      logTrace('FcmMessageController::_getSessionAction: _getSessionInteractor is null');
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    try {
      final apiUrl = success.session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors?.jmapUrl);
      final stateChange = success.stateChange;

      if (apiUrl.isNotEmpty && stateChange != null) {
        _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);

        _pushActionFromRemoteMessageBackground(
          accountId: success.session.accountId,
          userName: success.session.username,
          stateChange: stateChange,
          session: success.session);
      } else {
        logTrace(
          'FcmMessageController::_handleGetSessionSuccess: Api url or state change is null',
        );
      }
    } catch (e, st) {
      logError(
        'FcmMessageController::_handleGetSessionSuccess:',
        exception: e,
        stackTrace: st,
      );
    }
  }

  void _pushActionFromRemoteMessageBackground({
    required AccountId accountId,
    required UserName userName,
    required StateChange stateChange,
    Session? session
  }) {
    final mapTypeState = stateChange.getMapTypeState(accountId);
    logTrace('FcmMessageController::_pushActionFromRemoteMessageBackground: Mapping type state to action ${mapTypeState.toString()}');
    mappingTypeStateToAction(
      mapTypeState,
      accountId,
      userName,
      emailChangeListener: EmailChangeListener.instance,
      mailboxChangeListener: MailboxChangeListener.instance,
      labelChangeListener: LabelChangeListener.instance,
      isForeground: false,
      session: session);
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('FcmMessageController::_handleFailureViewState(): $failure');
    if (failure is GetStoredTokenOidcFailure) {
      logTrace('FcmMessageController::GetStoredTokenOidcFailure: Get stored token oidc is failed');
    } else if (failure is GetSessionFailure) {
      logTrace('FcmMessageController::GetSessionFailure: Get session is failed');
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('FcmMessageController::_handleSuccessViewState(): $success');
    if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetAccountByOidcSuccess(success);
    } else if (success is GetCredentialViewState) {
      _handleGetAccountByBasicAuthSuccess(success);
    }
  }
}