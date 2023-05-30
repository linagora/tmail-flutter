import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/offline_mode/biding/sending_email_biding.dart';
import 'package:tmail_ui_user/features/offline_mode/observer/work_observer.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingEmailObserver extends WorkObserver {

  AccountId? _currentAccountId;
  Session? _currentSession;
  UserName? _userName;
  SendingEmail? _sendingEmail;

  AppToast? _appToast;
  ImagePaths? _imagePaths;
  SendEmailInteractor? _sendEmailInteractor;
  GetAuthenticatedAccountInteractor? _getAuthenticatedAccountInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  AuthorizationInterceptors? _authorizationInterceptors;
  GetSessionInteractor? _getSessionInteractor;
  DeleteSendingEmailInteractor? _deleteSendingEmailInteractor;

  static SendingEmailObserver? _instance;

  SendingEmailObserver._();

  factory SendingEmailObserver() => _instance ??= SendingEmailObserver._();

  @override
  Future<void> observe(String taskId, Map<String, dynamic> inputData) async {
    log('SendingEmailObserver::observe():taskId: $taskId | inputData: $inputData');
    _sendingEmail = SendingEmail.fromJson(inputData);
    _getAuthenticatedAccount();
    return Future.value();
  }

  @override
  Future<void> bindDI() async {
    return await _initialAppConfig();
  }


  Future<void> _initialAppConfig() async {
    await Future.wait([
      MainBindings().dependencies(),
      HiveCacheConfig().setUp()
    ]);

    await Future.sync(() {
      HomeBindings().dependencies();
      MailboxDashBoardBindings().dependencies();
      SendingEmailBindings().dependencies();
    });

    return await _getInteractorBindings();
  }

  @override
  void handleFailureViewState(Failure failure) {
    _clearDataQueue();
    log('SendingEmailObserver::_handleFailureViewState(): $failure');
  }


  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAuthenticatedAccountSuccess) {
      _handleGetAuthenticatedAccountSuccess(success);
    } else if (success is GetSessionSuccess) {
      _handleGetSessionSuccess(success);
    } else if (success is GetStoredTokenOidcSuccess) {
      _handleGetAccountByOidcSuccess(success);
    } else if (success is GetCredentialViewState) {
      _handleGetAccountByBasicAuthSuccess(success);
    } else if (success is SendEmailSuccess) {
      _handleSendEmailSuccess(success);
    }
  }

  Future<void> _getInteractorBindings() {
    try {
      _getAuthenticatedAccountInteractor = getBinding<GetAuthenticatedAccountInteractor>();
      _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
      _authorizationInterceptors = getBinding<AuthorizationInterceptors>();
      _getSessionInteractor = getBinding<GetSessionInteractor>();
      _appToast = getBinding<AppToast>();
      _imagePaths = getBinding<ImagePaths>();
      _sendEmailInteractor = getBinding<SendEmailInteractor>();
      _deleteSendingEmailInteractor = getBinding<DeleteSendingEmailInteractor>();
    } catch (e) {
      logError('SendingEmailObserver::_getInteractorBindings(): ${e.toString()}');
    }
    return Future.value(null);
  }

  void _handleGetAuthenticatedAccountSuccess(GetAuthenticatedAccountSuccess success) {
    _currentAccountId = success.account.accountId;
    _userName = success.account.userName;
    _dynamicUrlInterceptors?.changeBaseUrl(success.account.apiUrl);
    log('SendingEmailObserver::_handleGetAuthenticatedAccountSuccess():_currentAccountId: $_currentAccountId | _userName: $_userName');
  }

  void _getSessionAction() {
    if (_getSessionInteractor != null) {
      consumeState(_getSessionInteractor!.execute());
    } else {
      _clearDataQueue();
      logError('SendingEmailObserver::_getSessionAction():_getSessionInteractor is null');
    }
  }

  void _getAuthenticatedAccount() {
    if (_getAuthenticatedAccountInteractor != null) {
      consumeState(_getAuthenticatedAccountInteractor!.execute(needToReopen: true));
    } else {
      _clearDataQueue();
      logError('SendingEmailObserver::_getAuthenticatedAccount():_getAuthenticatedAccountInteractor is null');
    }
  }

  void _handleGetSessionSuccess(GetSessionSuccess success) {
    _currentSession = success.session;
    _userName = success.session.username;
    final jmapUrl = _dynamicUrlInterceptors?.jmapUrl;
    final apiUrl = jmapUrl != null
        ? success.session.apiUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl)).toString()
        : success.session.apiUrl.toString();
    log('SendingEmailObserver::_handleGetSessionSuccess():jmapUrl: $jmapUrl | apiUrl: $apiUrl');
    if (apiUrl.isNotEmpty) {
      _dynamicUrlInterceptors?.changeBaseUrl(apiUrl);
      _sendEmailAction();
    } else {
      _clearDataQueue();
      logError('SendingEmailObserver::_handleGetSessionSuccess():apiUrl is null');
    }
  }

  void _handleGetAccountByBasicAuthSuccess(GetCredentialViewState credentialViewState) {
    log('SendingEmailObserver::_handleGetAccountByBasicAuthSuccess()');
    _dynamicUrlInterceptors?.setJmapUrl(credentialViewState.baseUrl.toString());
    _authorizationInterceptors?.setBasicAuthorization(
      credentialViewState.userName.value,
      credentialViewState.password.value,
    );
    _dynamicUrlInterceptors?.changeBaseUrl(credentialViewState.baseUrl.toString());
    _getSessionAction();
  }

  void _sendEmailAction() {
    log('SendingEmailObserver::_sendEmailAction()');
    if (_sendEmailInteractor != null && _sendingEmail != null && _currentSession != null && _currentAccountId != null) {
      consumeState(_sendEmailInteractor!.execute(
        _currentSession!,
        _currentAccountId!,
        _sendingEmail!.toEmailRequest(),
        mailboxRequest: CreateNewMailboxRequest(
          _sendingEmail!.creationIdRequest!,
          _sendingEmail!.mailboxNameRequest!,
          isSubscribed: true,
        )
      ));
    } else {
      logError('SendingEmailObserver::_sendEmailAction():_sendEmailInteractor is null');
    }
  }

  void _handleGetAccountByOidcSuccess(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    log('FcmMessageController::_handleGetAccountByOidcSuccess():');
    _dynamicUrlInterceptors?.setJmapUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors?.setTokenAndAuthorityOidc(
        newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
        newConfig: storedTokenOidcSuccess.oidcConfiguration
    );

    _dynamicUrlInterceptors?.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
    _getSessionAction();
  }

  void _handleSendEmailSuccess(SendEmailSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast?.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
        leadingSVGIcon: _imagePaths?.icSendSuccessToast);
      _deleteSendingEmailAction();
    }
  }

  void _deleteSendingEmailAction() {
    if (_deleteSendingEmailInteractor != null && _currentSession != null && _currentAccountId != null && _sendingEmail != null) {
      consumeState(_deleteSendingEmailInteractor!.execute(
        _currentAccountId!,
        _currentSession!.username,
        _sendingEmail!.email.id!,
      ));
    } else {
      logError('SendingEmailObserver::_deleteSendingEmailAction():_deleteSendingEmailInteractor is null');
    }
  }

  void _clearDataQueue() {
    _sendingEmail = null;
  }
}