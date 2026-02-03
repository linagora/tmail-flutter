
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
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
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
      await Future.wait([
        MainBindings().dependencies(),
        HiveCacheConfig.instance.setUp()
      ]);

      await Future.sync(() {
        HomeBindings().dependencies();
        MailboxDashBoardBindings().dependencies();
        FcmInteractorBindings().dependencies();
      });

      _getInteractorBindings();
    } catch (e, st) {
      logError(
        'FcmMessageController::initialAppConfig: throw exception',
        exception: e,
        stackTrace: st,
      );
    }
  }

  Future<void> setUpSentryConfiguration() async {
    try {
      final cachingManager = getBinding<CachingManager>();
      if (cachingManager == null) {
        logWarning('FcmMessageController::setUpSentryConfiguration: CachingManager is null');
        return;
      }

      final sentryConfig = await cachingManager.getSentryConfiguration();
      if (sentryConfig == null) {
        logWarning('FcmMessageController::setUpSentryConfiguration: SentryConfiguration is null');
        return;
      }

      if (!sentryConfig.isAvailable) {
        logWarning('FcmMessageController::setUpSentryConfiguration: SentryConfiguration is not available');
        return;
      }

      await SentryManager.instance.initializeWithSentryConfig(sentryConfig);

      final sentryUser = await cachingManager.getSentryUser();
      if (sentryUser == null) {
        logTrace('FcmMessageController::setUpSentryConfiguration: Sentry user is null');
        // Sentry initialized without user context - this is acceptable
      } else {
        SentryManager.instance.setUser(sentryUser);
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
      newConfig: storedTokenOidcSuccess.oidcConfiguration
    );

    if (PlatformInfo.isAndroid) {
      _dynamicUrlInterceptors?.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
      _getSessionAction(stateChange: storedTokenOidcSuccess.stateChange);
    } else {
      _dynamicUrlInterceptors?.changeBaseUrl(storedTokenOidcSuccess.personalAccount.apiUrl);

      final accountId = storedTokenOidcSuccess.personalAccount.accountId;
      final username = storedTokenOidcSuccess.personalAccount.userName;
      final stateChange = storedTokenOidcSuccess.stateChange;

      if (accountId != null && username != null && stateChange != null) {
        _pushActionFromRemoteMessageBackground(
          accountId: accountId,
          userName: username,
          stateChange: stateChange);
      } else {
        logTrace('FcmMessageController::_handleGetAccountByOidcSuccess: accountId or username or stateChange is null');
      }
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
      _dynamicUrlInterceptors?.changeBaseUrl(credentialViewState.personalAccount.apiUrl);

      final accountId = credentialViewState.personalAccount.accountId;
      final username = credentialViewState.personalAccount.userName;
      final stateChange = credentialViewState.stateChange;

      if (accountId != null && username != null && stateChange != null) {
        _pushActionFromRemoteMessageBackground(
          accountId: accountId,
          userName: username,
          stateChange: stateChange);
      } else {
        logTrace('FcmMessageController::_handleGetAccountByBasicAuthSuccess: accountId or username or stateChange is null');
      }
    }
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