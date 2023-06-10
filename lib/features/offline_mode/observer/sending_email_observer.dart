import 'dart:async';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/list_email_content_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_sending_email_state.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/bindings/sending_email_interactor_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/exceptions/workmanager_exception.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_config.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_isolate_manager.dart';
import 'package:tmail_ui_user/features/session/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingEmailObserver extends WorkObserver {

  AccountId? _currentAccountId;
  Session? _currentSession;
  SendingEmail? _sendingEmail;

  SendEmailInteractor? _sendEmailInteractor;
  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;
  DeleteSendingEmailInteractor? _deleteSendingEmailInteractor;
  SendingQueueIsolateManager? _sendingQueueIsolateManager;
  UpdateSendingEmailInteractor? _updateSendingEmailInteractor;
  SendingEmailCacheManager? _sendingEmailCacheManager;

  Completer<bool>? _completer;

  static SendingEmailObserver? _instance;

  SendingEmailObserver._();

  factory SendingEmailObserver() => _instance ??= SendingEmailObserver._();

  @override
  Future<void> observe(String taskId, Map<String, dynamic> inputData, Completer<bool> completer) async {
    _completer = completer;
    _sendingEmail = SendingEmail.fromJson(inputData);
    log('SendingEmailObserver::observe():_sendingEmail: $_sendingEmail');
    _updatingSendingStateToMainUI();
    _getAuthenticatedAccount();
  }

  @override
  Future<void> bindDI() async {
    await Future.wait([
      MainBindings().dependencies(),
      HiveCacheConfig().setUp()
    ]);

    await Future.sync(() {
      HomeBindings().dependencies();
      MailboxDashBoardBindings().dependencies();
      SendEmailInteractorBindings().dependencies();
    });

    await _getInteractorBindings();

    await _sendingEmailCacheManager?.closeSendingEmailHiveCacheBox();

    return Future.value();
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('SendingEmailObserver::_handleFailureViewState(): $failure');
    if (failure is SendEmailFailure) {
      _handleSendEmailFailure(failure);
    } else if (failure is DeleteSendingEmailFailure) {
      _handleDeleteSendingEmailFailure(failure);
    } else if (failure is GetAuthenticatedAccountFailure ||
        failure is NoAuthenticatedAccountFailure ||
        failure is GetSessionFailure ||
        failure is GetStoredTokenOidcFailure ||
        failure is GetCredentialFailure ||
        failure is UpdateSendingEmailFailure) {
      _handleTaskFailureInWorkManager();
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('SendingEmailObserver::handleSuccessViewState(): $success');
    if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetAccountByOidcSuccess(success);
    } else if (success is GetCredentialViewState) {
      _handleGetAccountByBasicAuthSuccess(success);
    } else if (success is SendEmailSuccess) {
      _handleSendEmailSuccess(success);
    } else if (success is DeleteSendingEmailSuccess) {
      _handleDeleteSendingEmailSuccess(success);
    } else if (success is UpdateSendingEmailSuccess) {
      _handleUpdateStoredSendingEmailSuccess(success);
    }
  }

  @override
  void handleOnError(Object? error, StackTrace stackTrace) {
    super.handleOnError(error, stackTrace);
    _handleTaskFailureInWorkManager();
  }

  Future<void> _getInteractorBindings() async {
    try {
      _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
      _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
      _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
      _getSessionInteractor = getBinding<GetSessionInteractor>();
      _sendEmailInteractor = getBinding<SendEmailInteractor>();
      _deleteSendingEmailInteractor = getBinding<DeleteSendingEmailInteractor>();
      _sendingQueueIsolateManager = getBinding<SendingQueueIsolateManager>();
      _updateSendingEmailInteractor = getBinding<UpdateSendingEmailInteractor>();
      _sendingEmailCacheManager = getBinding<SendingEmailCacheManager>();
    } catch (e) {
      logError('SendingEmailObserver::_getInteractorBindings(): ${e.toString()}');
      _handleTaskFailureInWorkManager();
    }
  }

  void _updatingSendingStateToMainUI({String? sendingId, SendingState? sendingState}) {
    final eventAction = _generateEventAction(
      sendingId ?? _sendingEmail!.sendingId,
      sendingState ?? _sendingEmail!.sendingState
    );
    log('SendingEmailObserver::_updatingSendingStateToMainUI():eventAction: $eventAction');
    _sendingQueueIsolateManager?.addEvent(eventAction);
  }

  void _getAuthenticatedAccount() {
    consumeState(_getAuthenticatedAccountInteractor!.execute());
  }

  void _getSessionAction() {
    consumeState(_getSessionInteractor!.execute());
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) async {
    _currentSession = success.session;
    _currentAccountId = success.session.personalAccount.accountId;
    final apiUrl = success.session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors?.jmapUrl);
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);
      _sendEmailAction();
    } else {
      _handleTaskFailureInWorkManager();
    }
  }

  void _handleGetAccountByBasicAuthSuccess(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors?.setJmapUrl(credentialViewState.baseUrl.toString());
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName.value,
      credentialViewState.password.value,
    );
    _dynamicUrlInterceptors?.changeBaseUrl(credentialViewState.baseUrl.toString());
    _getSessionAction();
  }

  void _sendEmailAction() {
    consumeState(
      _sendEmailInteractor!.execute(
        _currentSession!,
        _currentAccountId!,
        _sendingEmail!.toEmailRequest(),
        mailboxRequest: _getMailboxRequest()
      )
    );
  }

  CreateNewMailboxRequest? _getMailboxRequest() {
    if (_sendingEmail!.mailboxNameRequest != null &&
        _sendingEmail!.creationIdRequest != null) {
      return CreateNewMailboxRequest(
        _sendingEmail!.creationIdRequest!,
        _sendingEmail!.mailboxNameRequest!);
    } else {
      return null;
    }
  }

  void _handleGetAccountByOidcSuccess(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors?.setJmapUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
      newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
      newConfig: storedTokenOidcSuccess.oidcConfiguration
    );
    _dynamicUrlInterceptors?.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
    _getSessionAction();
  }

  void _handleSendEmailSuccess(SendEmailSuccess success) {
    _showLocalNotification();
    _updateStoredSendingEmail(SendingState.success);
  }

  void _handleSendEmailFailure(SendEmailFailure failure) {
    _updateStoredSendingEmail(SendingState.error);
  }

  void _deleteSendingEmailAction() {
    consumeState(
      _deleteSendingEmailInteractor!.execute(
        _currentAccountId!,
        _currentSession!.username,
        _sendingEmail!.sendingId
      )
    );
  }

  void _handleDeleteSendingEmailSuccess(DeleteSendingEmailSuccess success) {
    _handleTaskSuccessInWorkManager();
  }

  void _handleDeleteSendingEmailFailure(DeleteSendingEmailFailure failure) {
    _handleTaskFailureInWorkManager();
  }

  void _showLocalNotification() {
    LocalNotificationManager.instance.showPushNotification(
      id: _sendingEmail?.sendingId ?? '',
      title: _sendingEmail?.email.subject ?? LocalNotificationConfig.messageHasBeenSentSuccessfully,
      message: _sendingEmail?.presentationEmail.emailContentList.asHtmlString,
      isInboxStyle: false
    );
  }

  void _updateStoredSendingEmail(SendingState newState) {
    log('SendingEmailObserver::_updateStoredSendingEmail():newState: $newState');
    consumeState(
      _updateSendingEmailInteractor!.execute(
        _currentAccountId!,
        _currentSession!.username,
        _sendingEmail!.updatingSendingState(newState)
      )
    );
  }

  void _handleUpdateStoredSendingEmailSuccess(UpdateSendingEmailSuccess success) {
    log('SendingEmailObserver::_handleUpdateStoredSendingEmailSuccess(): $success');
    if (success.newSendingEmail.isSuccess) {
      _deleteSendingEmailAction();
    } else {
      _updatingSendingStateToMainUI(
        sendingState: success.newSendingEmail.sendingState,
        sendingId: success.newSendingEmail.sendingId);
    }
  }

  void _handleTaskFailureInWorkManager() async {
    log('SendingEmailObserver::_handleTaskFailureInWorkManager():');
    _updatingSendingStateToMainUI(sendingState: SendingState.error);

    await Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        _completer?.completeError(CannotCompleteTaskInWorkManagerException());
        _sendingEmail = null;
        _completer = null;
      }
    );
  }

  void _handleTaskSuccessInWorkManager() async {
    log('SendingEmailObserver::_handleTaskSuccessInWorkManager():');
    _updatingSendingStateToMainUI(sendingState: SendingState.success);

    await Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        _completer?.complete(true);
        _sendingEmail = null;
        _completer = null;
      }
    );
  }

  String _generateEventAction(String sendingId, SendingState sendingState) => TupleKey(sendingId, sendingState.name).toString();
}