
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/fcm_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_token_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/email_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/mailbox_change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class FcmMessageController extends FcmBaseController {

  AccountId? _currentAccountId;
  Session? _currentSession;
  UserName? _userName;

  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;
  AccountCacheManager? _accountCacheManager;
  TokenOidcCacheManager? _tokenOidcCacheManager;
  StateCacheManager? _stateCacheManager;
  AuthenticationInfoCacheManager? _authenticationInfoCacheManager;

  FcmMessageController._internal();

  static final FcmMessageController _instance = FcmMessageController._internal();

  static FcmMessageController get instance => _instance;

  void initialize({AccountId? accountId, Session? session}) {
    _currentAccountId = accountId;
    _currentSession = session;
    _userName = session?.username;

    _listenTokenStream();
    _listenForegroundMessageStream();
    _listenBackgroundMessageStream();
  }

  void _listenForegroundMessageStream() {
    FcmService.instance.foregroundMessageStreamController
      ?.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationMessageComing))
      .listen(_handleForegroundMessageAction);
  }

  void _listenBackgroundMessageStream() {
    FcmService.instance.backgroundMessageStreamController
      ?.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationMessageComing))
      .listen(_handleBackgroundMessageAction);
  }

  void _listenTokenStream() {
    FcmService.instance.fcmTokenStreamController
      ?.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationRefreshToken))
      .listen(FcmTokenController.instance.onFcmTokenChanged);
  }

  void _handleForegroundMessageAction(Map<String, dynamic> payloadData) {
    log('FcmMessageController::_handleForegroundMessageAction():payloadData: $payloadData | _currentAccountId: $_currentAccountId');
    if (_currentAccountId != null && _userName != null) {
      final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(payloadData);
      final mapTypeState = stateChange.getMapTypeState(_currentAccountId!);
      _mappingTypeStateToAction(
        mapTypeState,
        _currentAccountId!,
        _userName!,
        session: _currentSession);
    }
  }

  Future<void> _handleBackgroundMessageAction(Map<String, dynamic> payloadData) async {
    log('FcmMessageController::_handleBackgroundMessageAction():payloadData: $payloadData');
    final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(payloadData);
    await _initialAppConfig();
    _getAuthenticatedAccount(stateChange: stateChange);
  }

  void _mappingTypeStateToAction(
    Map<String, dynamic> mapTypeState,
    AccountId accountId,
    UserName userName, {
    bool isForeground = true,
    Session? session
  }) {
    log('FcmMessageController::_mappingTypeStateToAction():mapTypeState: $mapTypeState');
    final listTypeName = mapTypeState.keys
      .map((value) => TypeName(value))
      .toList();

    final listEmailActions = listTypeName
      .where((typeName) => typeName == TypeName.emailType || typeName == TypeName.emailDelivery)
      .map((typeName) => toFcmAction(typeName, accountId, userName, mapTypeState, isForeground, session: session))
      .whereNotNull()
      .toList();

    log('FcmMessageController::_mappingTypeStateToAction():listEmailActions: $listEmailActions');

    if (listEmailActions.isNotEmpty) {
       EmailChangeListener.instance.dispatchActions(listEmailActions);
    }

    final listMailboxActions = listTypeName
      .where((typeName) => typeName == TypeName.mailboxType)
      .map((typeName) => toFcmAction(typeName, accountId, userName, mapTypeState, isForeground))
      .whereNotNull()
      .toList();

    log('FcmMessageController::_mappingTypeStateToAction():listMailboxActions: $listEmailActions');

    if (listMailboxActions.isNotEmpty) {
      MailboxChangeListener.instance.dispatchActions(listMailboxActions);
    }
  }

  FcmAction? toFcmAction(
    TypeName typeName,
    AccountId accountId,
    UserName userName,
    Map<String, dynamic> mapTypeState,
    isForeground,
    {
      Session? session
    }
  ) {
    final newState = jmap.State(mapTypeState[typeName.value]);
    if (typeName == TypeName.emailType) {
      if (isForeground) {
        return SynchronizeEmailOnForegroundAction(typeName, newState, accountId, session);
      } else {
        return StoreEmailStateToRefreshAction(typeName, newState, accountId, userName, session);
      }
    } else if (typeName == TypeName.emailDelivery) {
      if (!isForeground) {
        return PushNotificationAction(typeName, newState, session, accountId, userName);
      }
    } else if (typeName == TypeName.mailboxType) {
      if (isForeground) {
        return SynchronizeMailboxOnForegroundAction(typeName, newState, accountId);
      } else {
        return StoreMailboxStateToRefreshAction(typeName, newState, accountId, userName);
      }
    }
    return null;
  }

  Future<void> _initialAppConfig() async {
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

    await Future.wait([
      if (_accountCacheManager != null)
        _accountCacheManager!.closeAccountHiveCacheBox(),
      if (_tokenOidcCacheManager != null)
        _tokenOidcCacheManager!.closeTokenOIDCHiveCacheBox(),
      if (_stateCacheManager != null)
        _stateCacheManager!.closeStateHiveCacheBox(),
      if (_authenticationInfoCacheManager != null)
        _authenticationInfoCacheManager!.closeAuthenticationInfoHiveCacheBox(),
    ]);
  }

  void _getInteractorBindings() {
    _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
    _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
    _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
    _getSessionInteractor = getBinding<GetSessionInteractor>();
    _accountCacheManager = getBinding<AccountCacheManager>();
    _tokenOidcCacheManager = getBinding<TokenOidcCacheManager>();
    _stateCacheManager = getBinding<StateCacheManager>();
    _authenticationInfoCacheManager = getBinding<AuthenticationInfoCacheManager>();

    FcmTokenController.instance.initialBindingInteractor();
  }

  void _getAuthenticatedAccount({StateChange? stateChange}) {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute(stateChange: stateChange));
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
      }
    }
  }

  void _getSessionAction({StateChange? stateChange}) {
    if (_getSessionInteractor != null) {
      consumeState(_getSessionInteractor!.execute(stateChange: stateChange));
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    try {
      final apiUrl = success.session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors?.jmapUrl);
      final stateChange = success.stateChange;

      if (apiUrl.isNotEmpty && stateChange != null) {
        _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);

        _pushActionFromRemoteMessageBackground(
          accountId: success.session.personalAccount.accountId,
          userName: success.session.username,
          stateChange: stateChange,
          session: success.session);
      }
    } catch (e) {
      logError('FcmMessageController::_handleGetSessionSuccess: Exception $e');
    }
  }

  void _pushActionFromRemoteMessageBackground({
    required AccountId accountId,
    required UserName userName,
    required StateChange stateChange,
    Session? session
  }) {
    final mapTypeState = stateChange.getMapTypeState(accountId);

    _mappingTypeStateToAction(
      mapTypeState,
      accountId,
      userName,
      isForeground: false,
      session: session);
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('FcmMessageController::_handleFailureViewState(): $failure');
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