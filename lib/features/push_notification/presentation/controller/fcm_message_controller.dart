
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:fcm/model/type_name.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
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
  RemoteMessage? _remoteMessageBackground;

  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;

  FcmMessageController._internal() {
    _listenFcmStream();
  }

  static final FcmMessageController _instance = FcmMessageController._internal();

  static FcmMessageController get instance => _instance;

  void initialize({Session? session, AccountId? accountId}) {
    _currentSession = session;
    _currentAccountId = accountId;
    FcmTokenController.instance.initialize();
  }

  void _listenFcmStream() async {
    await Future.wait([
      listenForegroundMessageStream(),
      listenBackgroundMessageStream(),
      listenTokenStream()
    ]);
  }

  Future<void> listenForegroundMessageStream() {
    FcmService.instance.foregroundMessageStream
      .throttleTime(const Duration(milliseconds: FcmService.durationMessageComing))
      .listen(_handleForegroundMessageAction);
    return Future.value();
  }

  Future<void> listenBackgroundMessageStream() {
    FcmService.instance.backgroundMessageStream
      .throttleTime(const Duration(milliseconds: FcmService.durationMessageComing))
      .listen(_handleBackgroundMessageAction);
    return Future.value();
  }

  Future<void> listenTokenStream() {
    FcmService.instance.fcmTokenStream
      .debounceTime(const Duration(milliseconds: FcmService.durationRefreshToken))
      .listen(FcmTokenController.instance.handleTokenAction);
    return Future.value();
  }

  void _handleForegroundMessageAction(RemoteMessage newRemoteMessage) {
    log('FcmMessageController::_handleForegroundMessageAction():remoteMessage: ${newRemoteMessage.data}');
    if (_currentAccountId != null && _currentSession != null) {
      final stateChange = _convertRemoteMessageToStateChange(newRemoteMessage);
      final mapTypeState = stateChange.getMapTypeState(_currentAccountId!);
      _mappingTypeStateToAction(_currentSession!, mapTypeState, _currentAccountId!);
    }
  }

  void _handleBackgroundMessageAction(RemoteMessage newRemoteMessage) async {
    log('FcmMessageController::_handleBackgroundMessageAction():remoteMessage: ${newRemoteMessage.data}');
    _remoteMessageBackground = newRemoteMessage;
    await _initialAppConfig();
    _getAuthenticatedAccount();
  }

  StateChange? _convertRemoteMessageToStateChange(RemoteMessage newRemoteMessage) {
    return FcmUtils.instance.convertFirebaseDataMessageToStateChange(newRemoteMessage.data);
  }

  void _mappingTypeStateToAction(
    Session session,
    Map<String, dynamic> mapTypeState,
    AccountId accountId, {
    bool isForeground = true,
  }) {
    log('FcmMessageController::_mappingTypeStateToAction():mapTypeState: $mapTypeState');
    final listTypeName = mapTypeState.keys
      .map((value) => TypeName(value))
      .toList();

    final listEmailActions = listTypeName
      .where((typeName) => typeName == TypeName.emailType || typeName == TypeName.emailDelivery)
      .map((typeName) => toFcmAction(session, typeName, accountId, mapTypeState, isForeground))
      .whereNotNull()
      .toList();

    log('FcmMessageController::_mappingTypeStateToAction():listEmailActions: $listEmailActions');

    if (listEmailActions.isNotEmpty) {
       EmailChangeListener.instance.dispatchActions(listEmailActions);
    }

    final listMailboxActions = listTypeName
      .where((typeName) => typeName == TypeName.mailboxType)
      .map((typeName) => toFcmAction(session, typeName, accountId, mapTypeState, isForeground))
      .whereNotNull()
      .toList();

    log('FcmMessageController::_mappingTypeStateToAction():listMailboxActions: $listEmailActions');

    if (listMailboxActions.isNotEmpty) {
      MailboxChangeListener.instance.dispatchActions(listMailboxActions);
    }
  }

  FcmAction? toFcmAction(
    Session session,
    TypeName typeName,
    AccountId accountId,
    Map<String, dynamic> mapTypeState,
    isForeground
  ) {
    final newState = jmap.State(mapTypeState[typeName.value]);
    if (typeName == TypeName.emailType) {
      if (isForeground) {
        return SynchronizeEmailOnForegroundAction(typeName, newState, accountId);
      } else {
        return StoreEmailStateToRefreshAction(typeName, newState, accountId);
      }
    } else if (typeName == TypeName.emailDelivery) {
      if (!isForeground) {
        return PushNotificationAction(typeName, newState, session, accountId);
      }
    } else if (typeName == TypeName.mailboxType) {
      if (isForeground) {
        return SynchronizeMailboxOnForegroundAction(typeName, newState, accountId);
      } else {
        return StoreMailboxStateToRefreshAction(typeName, newState, accountId);
      }
    }
    return null;
  }

  Future<void> _initialAppConfig() async {
    await Future.wait([
      MainBindings().dependencies(),
      HiveCacheConfig().setUp()
    ]);

    await Future.sync(() {
      HomeBindings().dependencies();
      MailboxDashBoardBindings().dependencies();
      FcmInteractorBindings().dependencies();
    });

    return await _getInteractorBindings();
  }

  Future<void> _getInteractorBindings() {
    try {
      _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
      _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
      _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
      FcmTokenController.instance.initialize();
    } catch (e) {
      logError('FcmMessageController::_getBindings(): ${e.toString()}');
    }
    return Future.value(null);
  }

  void _getAuthenticatedAccount() {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute());
    } else {
      _clearRemoteMessageBackground();
      logError('FcmMessageController::_getAuthenticatedAccount():_getAuthenticatedAccountInteractor is null');
    }
  }

  void _handleGetAuthenticatedAccountSuccess(GetAuthenticatedAccountSuccess success) {
    _currentAccountId = success.account.accountId;
    _dynamicUrlInterceptors?.changeBaseUrl(success.account.apiUrl);
    log('FcmMessageController::_handleGetAuthenticatedAccountSuccess():_currentAccountId: $_currentAccountId');
  }

  void _handleGetAccountByOidcSuccess(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    log('FcmMessageController::_handleGetAccountByOidcSuccess():');
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
      newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
      newConfig: storedTokenOidcSuccess.oidcConfiguration
    );
    _pushActionFromRemoteMessageBackground();
  }

  void _handleGetAccountByBasicAuthSuccess(GetCredentialViewState credentialViewState) {
    log('FcmMessageController::_handleGetAccountByBasicAuthSuccess():');
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    _pushActionFromRemoteMessageBackground();
  }

  void _pushActionFromRemoteMessageBackground() {
    log('FcmMessageController::_pushActionFromRemoteMessageBackground():');
    if (_remoteMessageBackground != null && _currentAccountId != null && _currentSession != null) {
      final stateChange = _convertRemoteMessageToStateChange(_remoteMessageBackground!);
      final mapTypeState = stateChange.getMapTypeState(_currentAccountId!);
      _mappingTypeStateToAction(_currentSession!, mapTypeState, _currentAccountId!, isForeground: false);
    }
    _clearRemoteMessageBackground();
  }

  void _clearRemoteMessageBackground() {
    _remoteMessageBackground = null;
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('FcmMessageController::_handleFailureViewState(): $failure');
    _clearRemoteMessageBackground();
  }

  @override
  void handleSuccessViewState(Success success) {
    log('FcmMessageController::_handleSuccessViewState(): $success');
    if (success is GetAuthenticatedAccountSuccess) {
      _handleGetAuthenticatedAccountSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetAccountByOidcSuccess(success);
    } else if (success is GetCredentialViewState) {
      _handleGetAccountByBasicAuthSuccess(success);
    }
  }
}