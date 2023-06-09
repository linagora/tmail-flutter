import 'dart:async';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/model.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
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
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker_state.dart';
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

  Completer<bool>? _completer;

  static SendingEmailObserver? _instance;

  SendingEmailObserver._();

  factory SendingEmailObserver() => _instance ??= SendingEmailObserver._();

  @override
  Future<void> observe(String taskId, Map<String, dynamic> inputData, Completer<bool> completer) async {
    log('SendingEmailObserver::observe():taskId: $taskId | inputData: $inputData');
    _completer = completer;
    _sendingEmail = SendingEmail.fromJson(inputData);
    log('SendingEmailObserver::observe():_sendingEmail: $_sendingEmail');
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

    return await _getInteractorBindings();
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('SendingEmailObserver::_handleFailureViewState(): $failure');
    if (failure is SendEmailFailure) {
      _updateStoredSendingEmail(SendingState.error);
    } else if (failure is DeleteSendingEmailFailure) {
      _showLocalNotification();
      _updateStoredSendingEmail(SendingState.error);
    } else if (failure is GetAuthenticatedAccountFailure ||
        failure is NoAuthenticatedAccountFailure ||
        failure is GetSessionFailure ||
        failure is GetStoredTokenOidcFailure ||
        failure is GetCredentialFailure ||
        failure is UpdateSendingEmailFailure) {
      _invokeCompleteWorkManager();
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
      _handleDeleteSendingEmailSuccess();
    } else if (success is UpdateSendingEmailSuccess) {
      _handleUpdateStoredSendingEmailSuccess(success);
    }
  }

  @override
  void handleOnError(Object? error, StackTrace stackTrace) {
    super.handleOnError(error, stackTrace);
    _invokeCompleteWorkManager();
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
    } catch (e) {
      logError('SendingEmailObserver::_getInteractorBindings(): ${e.toString()}');
      _invokeCompleteWorkManager();
    }
  }

  void _getSessionAction() {
    if (_getSessionInteractor != null) {
      consumeState(_getSessionInteractor!.execute());
    } else {
      _invokeCompleteWorkManager();
    }
  }

  void _getAuthenticatedAccount() {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute());
    } else {
      _invokeCompleteWorkManager();
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) async {
    _currentSession = success.session;
    _currentAccountId = success.session.personalAccount.accountId;
    final apiUrl = success.session.getQualifiedApiUrl(baseUrl: _dynamicUrlInterceptors?.jmapUrl);
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);

      _updateStoredSendingEmail(SendingState.delivering);

      await Future.delayed(
        const Duration(milliseconds: 2000),
        _sendEmailAction
      );
    } else {
      _invokeCompleteWorkManager();
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
    final mailboxRequestNotNull = _sendingEmail?.mailboxNameRequest != null && _sendingEmail?.creationIdRequest != null;

    if (_sendEmailInteractor != null && _isDataParameterNotNull) {
      consumeState(_sendEmailInteractor!.execute(
        _currentSession!,
        _currentAccountId!,
        _sendingEmail!.toEmailRequest(),
        mailboxRequest: mailboxRequestNotNull
          ? CreateNewMailboxRequest(_sendingEmail!.creationIdRequest!, _sendingEmail!.mailboxNameRequest!)
          : null
      ));
    } else {
      _updateStoredSendingEmail(SendingState.error);
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
    _deleteSendingEmailAction();
  }

  void _deleteSendingEmailAction() {
    log('SendingEmailObserver::_deleteSendingEmailAction():');
    if (_deleteSendingEmailInteractor != null && _isDataParameterNotNull) {
      consumeState(_deleteSendingEmailInteractor!.execute(
        _currentAccountId!,
        _currentSession!.username,
        _sendingEmail!.sendingId,
        needToReopen: true
      ));
    } else {
      log('SendingEmailObserver::_deleteSendingEmailAction(): NOT CALLED');
      _updateStoredSendingEmail(SendingState.error);
    }
  }

  void _handleDeleteSendingEmailSuccess() async {
    _showLocalNotification();
    _sendingQueueIsolateManager?.addEvent(WorkerState.success.name);
    await Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        _completer?.complete(true);
        _completer = null;
      }
    );
  }

  void _showLocalNotification() {
    LocalNotificationManager.instance.showPushNotification(
      id: _sendingEmail?.sendingId ?? '',
      title: _sendingEmail?.email.subject ?? LocalNotificationConfig.messageHasBeenSentSuccessfully,
      message: _sendingEmail?.presentationEmail.emailContentList.asHtmlString,
      isInboxStyle: false
    );
  }

  bool get _isDataParameterNotNull => _currentSession != null && _currentAccountId != null && _sendingEmail != null;

  void _updateStoredSendingEmail(SendingState newState) {
    log('SendingEmailObserver::_updateStoredSendingEmail():');
    if (_updateSendingEmailInteractor != null && _isDataParameterNotNull) {
      consumeState(_updateSendingEmailInteractor!.execute(
        _currentAccountId!,
        _currentSession!.username,
        _sendingEmail!.updatingSendingState(newState),
        needToReopen: true
      ));
    } else {
      _invokeCompleteWorkManager();
    }
  }

  void _handleUpdateStoredSendingEmailSuccess(UpdateSendingEmailSuccess success) {
    log('SendingEmailObserver::_handleUpdateStoredSendingEmailSuccess():sendingState: ${success.newSendingEmail.sendingState}');
    switch (success.newSendingEmail.sendingState) {
      case SendingState.ready:
        break;
      case SendingState.delivering:
        _sendingQueueIsolateManager?.addEvent(WorkerState.pending.name);
        break;
      case SendingState.error:
        _invokeCompleteWorkManager();
        break;
    }
  }

  void _invokeCompleteWorkManager() async {
    log('SendingEmailObserver::_invokeCompleteWorkManager():');
    _sendingEmail = null;
    _sendingQueueIsolateManager?.addEvent(WorkerState.failed.name);
    await Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        _completer?.completeError(CannotCompleteTaskInWorkManagerException());
        _completer = null;
      }
    );
  }
}