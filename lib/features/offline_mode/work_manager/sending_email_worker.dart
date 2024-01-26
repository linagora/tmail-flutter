import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/bindings/sending_email_interactor_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/worker.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/bindings/sending_queue_interactor_bindings.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_isolate_manager.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingEmailWorker extends Worker {

  SendEmailInteractor? _sendEmailInteractor;
  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;
  SendingQueueIsolateManager? _sendingQueueIsolateManager;
  SendingEmailCacheManager? _sendingEmailCacheManager;
  UnsubscribeEmailInteractor? _unsubscribeEmailInteractor;

  late Completer<bool> _completer;
  late SendingEmail _sendingEmail;

  AccountId? _currentAccountId;
  Session? _currentSession;

  static SendingEmailWorker? _instance;

  SendingEmailWorker._();

  factory SendingEmailWorker() => _instance ??= SendingEmailWorker._();

  @override
  Future<bool> doWork(String taskId, Map<String, dynamic> inputData) {
    _completer = Completer<bool>();
    _sendingEmail = SendingEmail.fromJson(inputData);
    log('SendingEmailObserver::observe():_sendingEmail: $_sendingEmail');
    _updatingSendingStateToMainUI(
      sendingId: _sendingEmail.sendingId,
      sendingState: SendingState.running
    );
    _getAuthenticatedAccount();
    return _completer.future;
  }

  @override
  Future<void> bindDI() async {
    await Future.wait([
      MainBindings().dependencies(),
      HiveCacheConfig().setUp()
    ]);

    await Future.sync(() {
      SendingQueueInteractorBindings().dependencies();
      SendEmailInteractorBindings().dependencies();
      MailboxDashBoardBindings().dependencies();
    });

    _getInteractorBindings();

    await _sendingEmailCacheManager?.closeSendingEmailHiveCacheBox();
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('SendingEmailObserver::_handleFailureViewState(): $failure');
    if (failure is SendEmailFailure) {
      _handleSendEmailFailure(failure);
    } else if (failure is GetAuthenticatedAccountFailure ||
        failure is GetSessionFailure ||
        failure is GetStoredTokenOidcFailure ||
        failure is GetCredentialFailure) {
      _handleWorkerTaskToRetry();
    } else if (failure is UnsubscribeEmailFailure) {
      _handleWorkerTaskSuccess();
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
    } else if (success is UnsubscribeEmailSuccess) {
      _handleWorkerTaskSuccess();
    }
  }

  @override
  void handleOnError(Object? error, StackTrace stackTrace) {
    super.handleOnError(error, stackTrace);
    _handleWorkerTaskToRetry();
  }

  void _getInteractorBindings() {
    _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
    _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
    _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
    _getSessionInteractor = getBinding<GetSessionInteractor>();
    _sendEmailInteractor = getBinding<SendEmailInteractor>();
    _sendingQueueIsolateManager = getBinding<SendingQueueIsolateManager>();
    _sendingEmailCacheManager = getBinding<SendingEmailCacheManager>();
    _unsubscribeEmailInteractor = getBinding<UnsubscribeEmailInteractor>();
  }

  void _updatingSendingStateToMainUI({String? sendingId, SendingState? sendingState}) {
    final eventAction = _generateEventAction(
      sendingId ?? _sendingEmail.sendingId,
      sendingState ?? _sendingEmail.sendingState,
      accountId: _currentAccountId,
      userName: _currentSession?.username
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
    if (apiUrl.isNotEmpty && _currentSession != null && _currentAccountId != null) {
      _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);
      _sendEmailAction(_currentAccountId!, _currentSession!);
    } else {
      _handleWorkerTaskToRetry();
    }
  }

  void _handleGetAccountByBasicAuthSuccess(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors?.setJmapUrl(credentialViewState.baseUrl.toString());
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName,
      credentialViewState.password,
    );
    _dynamicUrlInterceptors?.changeBaseUrl(credentialViewState.baseUrl.toString());
    _getSessionAction();
  }

  void _sendEmailAction(AccountId accountId, Session session) {
    consumeState(
      _sendEmailInteractor!.execute(
        session,
        accountId,
        _sendingEmail.toEmailRequest(),
        mailboxRequest: _getMailboxRequest()
      )
    );
  }

  CreateNewMailboxRequest? _getMailboxRequest() {
    if (_sendingEmail.mailboxNameRequest != null &&
        _sendingEmail.creationIdRequest != null) {
      return CreateNewMailboxRequest(
        _sendingEmail.creationIdRequest!,
        _sendingEmail.mailboxNameRequest!);
    } else {
      return null;
    }
  }

  void _handleGetAccountByOidcSuccess(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors?.setJmapUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
      newToken: storedTokenOidcSuccess.tokenOidc,
      newConfig: storedTokenOidcSuccess.oidcConfiguration
    );
    _dynamicUrlInterceptors?.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
    _getSessionAction();
  }

  void _handleSendEmailSuccess(SendEmailSuccess success) {
    if (success.emailRequest.emailActionType == EmailActionType.composeFromUnsubscribeMailtoLink &&
        success.emailRequest.previousEmailId != null) {
      _unsubscribeMail(success.emailRequest.previousEmailId!);
    } else {
      _handleWorkerTaskSuccess();
    }
  }

  void _handleSendEmailFailure(SendEmailFailure failure) {
    _handleWorkerTaskFailure(failure.exception);
  }

  void _handleWorkerTaskToRetry() async {
    _updatingSendingStateToMainUI(sendingState: SendingState.canceled);
    log('SendingEmailObserver::_handleWorkerTaskToRetry():');
    await Future.delayed(
      const Duration(milliseconds: 1000),
      () => _completer.complete(false)
    );
  }

  void _handleWorkerTaskFailure(dynamic error) async {
    log('SendingEmailObserver::_handleWorkerTaskFailure():error: $error');
    _updatingSendingStateToMainUI(sendingState: SendingState.error);
    await Future.delayed(
      const Duration(milliseconds: 1000),
      () => _completer.completeError(error)
    );
  }

  void _handleWorkerTaskSuccess() async {
    log('SendingEmailObserver::_handleWorkerTaskSuccess():');
    _updatingSendingStateToMainUI(sendingState: SendingState.success);
    await Future.delayed(
      const Duration(milliseconds: 1000),
      () => _completer.complete(true)
    );
  }

  String _generateEventAction(
    String sendingId,
    SendingState sendingState,
    {
      AccountId? accountId,
      UserName? userName
    }
  ) => TupleKey(sendingId, sendingState.name, accountId?.asString, userName?.value).toString();

  void _unsubscribeMail(EmailId emailId) {
    if (_unsubscribeEmailInteractor != null &&
        _currentSession != null &&
        _currentAccountId != null
    ) {
      consumeState(
        _unsubscribeEmailInteractor!.execute(
          _currentSession!,
          _currentAccountId!,
          emailId
        )
      );
    } else {
      _handleWorkerTaskSuccess();
    }
  }
}