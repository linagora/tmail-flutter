
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/notification/notification_payload.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_detailed_email_by_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_stored_state_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_list_detailed_email_by_id_interator.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_stored_email_state_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_list_new_email_interator.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_push_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_remove_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailboxes_not_put_notifications_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_new_receive_email_from_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_email_delivery_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_remove_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailboxes_not_put_notifications_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_new_receive_email_from_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailChangeListener extends ChangeListener {

  MailboxDashBoardController? _dashBoardController;
  GetStoredEmailDeliveryStateInteractor? _getStoredEmailDeliveryStateInteractor;
  StoreEmailDeliveryStateInteractor? _storeEmailDeliveryStateInteractor;
  GetEmailChangesToPushNotificationInteractor? _getEmailChangesToPushNotificationInteractor;
  GetStoredEmailStateInteractor? _getStoredEmailStateInteractor;
  StoreEmailStateToRefreshInteractor? _storeEmailStateToRefreshInteractor;
  GetMailboxesNotPutNotificationsInteractor? _getMailboxesNotPutNotificationsInteractor;
  GetEmailChangesToRemoveNotificationInteractor? _getEmailChangesToRemoveNotificationInteractor;
  GetNewReceiveEmailFromNotificationInteractor? _getNewReceiveEmailFromNotificationInteractor;
  GetListDetailedEmailByIdInteractor? _getListDetailedEmailByIdInteractor;
  DynamicUrlInterceptors? _dynamicUrlInterceptors;
  StoreListNewEmailInteractor? _storeListNewEmailInteractor;

  jmap.State? _newStateEmailDelivery;
  AccountId? _accountId;
  Session? _session;
  UserName? _userName;
  List<PresentationEmail> _emailsAvailablePushNotification = [];

  EmailChangeListener._internal() {
    try {
      _dashBoardController = getBinding<MailboxDashBoardController>();
      _getStoredEmailStateInteractor = getBinding<GetStoredEmailStateInteractor>();
      _getStoredEmailDeliveryStateInteractor = getBinding<GetStoredEmailDeliveryStateInteractor>();
      _storeEmailDeliveryStateInteractor = getBinding<StoreEmailDeliveryStateInteractor>();
      _getEmailChangesToPushNotificationInteractor = getBinding<GetEmailChangesToPushNotificationInteractor>();
      _storeEmailStateToRefreshInteractor = getBinding<StoreEmailStateToRefreshInteractor>();
      _getMailboxesNotPutNotificationsInteractor = getBinding<GetMailboxesNotPutNotificationsInteractor>();
      _getEmailChangesToRemoveNotificationInteractor = getBinding<GetEmailChangesToRemoveNotificationInteractor>();
      _getNewReceiveEmailFromNotificationInteractor = getBinding<GetNewReceiveEmailFromNotificationInteractor>();
      _getListDetailedEmailByIdInteractor = getBinding<GetListDetailedEmailByIdInteractor>();
      _dynamicUrlInterceptors = getBinding<DynamicUrlInterceptors>();
      _storeListNewEmailInteractor = getBinding<StoreListNewEmailInteractor>();
    } catch (e) {
      logError('EmailChangeListener::_internal(): IS NOT REGISTERED: ${e.toString()}');
    }
  }

  static final EmailChangeListener _instance = EmailChangeListener._internal();

  static EmailChangeListener get instance => _instance;

  @override
  void dispatchActions(List<Action> actions) {
    log('EmailChangeListener::dispatchActions():actions: $actions');
    for (var action in actions) {
      if (action is SynchronizeEmailOnForegroundAction) {
        if (PlatformInfo.isAndroid) {
          _handleRemoveNotificationWhenEmailMarkAsRead(action.newState, action.accountId, action.session);
        }
        _synchronizeEmailOnForegroundAction(action.newState);
        if (PlatformInfo.isMobile) {
          _getNewReceiveEmailFromNotificationAction(action.session, action.accountId, action.newState);
        }
      } else if (action is PushNotificationAction) {
        _pushNotificationAction(action.newState, action.accountId, action.userName, action.session);

        if (PlatformInfo.isAndroid) {
          _getNewReceiveEmailFromNotificationAction(action.session, action.accountId, action.newState);
        }
      } else if (action is StoreEmailStateToRefreshAction) {
        if (PlatformInfo.isAndroid) {
          _handleRemoveNotificationWhenEmailMarkAsRead(action.newState, action.accountId, action.session);
        }
        _handleStoreEmailStateToRefreshAction(action.accountId, action.userName, action.newState);
      }
    }
  }

  void _synchronizeEmailOnForegroundAction(jmap.State newState) {
    log('EmailChangeListener::_synchronizeEmailAction():newState: $newState');
    if (_dashBoardController != null) {
      _dashBoardController!.dispatchEmailUIAction(RefreshChangeEmailAction(newState));
    }
  }

  void _pushNotificationAction(jmap.State newState, AccountId accountId, UserName userName, Session? session) {
    _newStateEmailDelivery = newState;
    _accountId = accountId;
    _session = session;
    _userName = userName;
    log('EmailChangeListener::_pushNotificationAction():newState: $newState');

    if (PlatformInfo.isWeb) {
      _storeEmailDeliveryStateAction(accountId, userName, _newStateEmailDelivery!);
    } else if (PlatformInfo.isIOS) {
      _storeEmailDeliveryStateAction(accountId, userName, _newStateEmailDelivery!);
    } else if (PlatformInfo.isAndroid) {
      _getStoredEmailDeliveryState(accountId, userName);
    }
  }

  void _getStoredEmailDeliveryState(AccountId accountId, UserName userName) {
    if (_getStoredEmailDeliveryStateInteractor != null) {
      consumeState(_getStoredEmailDeliveryStateInteractor!.execute(accountId, userName));
    }
  }

  void _getStoredEmailState() {
    if (_getStoredEmailStateInteractor != null && _session != null && _accountId != null) {
      consumeState(_getStoredEmailStateInteractor!.execute(_session!, _accountId!));
    }
  }

  void _getEmailChangesAction(jmap.State state) {
    if (_getEmailChangesToPushNotificationInteractor != null &&
        _accountId != null &&
        _session != null &&
        _userName != null) {
      consumeState(_getEmailChangesToPushNotificationInteractor!.execute(
        _session!,
        _accountId!,
        _userName!,
        state,
        propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
      ));
    }
  }

  void _storeEmailDeliveryStateAction(AccountId accountId, UserName userName, jmap.State state) {
    if (_storeEmailDeliveryStateInteractor != null) {
      consumeState(_storeEmailDeliveryStateInteractor!.execute(accountId, userName, state));
    }
  }

  Future<void> _showLocalNotification({
    required UserName userName,
    required PresentationEmail presentationEmail,
    bool silent = false,
  }) async {
    return await LocalNotificationManager.instance.showPushNotification(
      id: presentationEmail.id?.id.value ?? '',
      title: presentationEmail.subject ?? '',
      message: presentationEmail.preview,
      emailAddress: presentationEmail.firstFromAddress,
      payload: NotificationPayload(emailId: presentationEmail.id).encodeToString,
      groupId: userName.value,
      silent: silent
    );
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('EmailChangeListener::_handleFailureViewState(): $failure');
    if (failure is GetStoredEmailDeliveryStateFailure &&
        failure.exception is NotFoundEmailDeliveryStateException) {
      _getStoredEmailState();
    } else if (failure is GetMailboxesNotPutNotificationsFailure) {
      final listEmails = _emailsAvailablePushNotification.toEmailsAvailablePushNotification();
      _handleLocalPushNotification(
        userName: failure.userName,
        emailList: listEmails
      );
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('EmailChangeListener::_handleSuccessViewState(): $success');
    if (success is GetStoredEmailDeliveryStateSuccess && _newStateEmailDelivery != success.state) {
      _getEmailChangesAction(success.state);
    } else if (success is GetStoredEmailStateSuccess) {
      _getEmailChangesAction(success.state);
    } else if (success is GetEmailChangesToPushNotificationSuccess && _newStateEmailDelivery != null) {
      _storeEmailDeliveryStateAction(success.accountId, success.userName, _newStateEmailDelivery!);

      if (PlatformInfo.isAndroid) {
        _handleListEmailToPushNotification(
          userName: success.userName,
          emailList: success.emailList
        );
      }
    } else if (success is GetMailboxesNotPutNotificationsSuccess) {
      final listEmails = _emailsAvailablePushNotification.toEmailsAvailablePushNotification(
        mailboxIdsNotPutNotifications: success.mailboxes.mailboxIds);
      _handleLocalPushNotification(
        userName: success.userName,
        emailList: listEmails
      );
    } else if (success is GetEmailChangesToRemoveNotificationSuccess) {
      _handleRemoveLocalNotification(
        userName: success.userName,
        emailIds: success.emailIds
      );
    } else if (success is GetNewReceiveEmailFromNotificationSuccess) {
      _getListDetailedEmailByIdAction(success.session, success.accountId, success.emailIds);
    } else if (success is GetDetailedEmailByIdSuccess) {
      _storeNewEmailAction(
        success.session,
        success.accountId,
        success.mapDetailedEmail);
    }
  }

  void _handleListEmailToPushNotification({
    required UserName userName,
    required List<PresentationEmail> emailList
  }) {
    _emailsAvailablePushNotification = emailList;
    if (_getMailboxesNotPutNotificationsInteractor != null && _accountId != null && _session != null) {
      consumeState(_getMailboxesNotPutNotificationsInteractor!.execute(_session!, _accountId!));
    } else {
      final listEmails = _emailsAvailablePushNotification.toEmailsAvailablePushNotification();
      _handleLocalPushNotification(
        userName: userName,
        emailList: listEmails
      );
    }
  }

  void _handleLocalPushNotification({
    required UserName userName,
    required List<PresentationEmail> emailList
  }) async {
    log('EmailChangeListener::_handleLocalPushNotification(): EMAIL_LENGTH = ${emailList.length}');
    if (emailList.isEmpty) {
      _emailsAvailablePushNotification.clear();
      return;
    }

    for (var presentationEmail in emailList) {
      await _showLocalNotification(
        userName: userName,
        presentationEmail: presentationEmail,
        silent: PlatformInfo.isAndroid
      );
    }

    if (PlatformInfo.isAndroid) {
      final countNotifications = await LocalNotificationManager.instance
        .getCountActiveNotificationByGroupOnAndroid(groupId: userName.value);

      await LocalNotificationManager.instance.groupPushNotificationOnAndroid(
        groupId: userName.value,
        countNotifications: countNotifications);
    }

    _emailsAvailablePushNotification.clear();
  }

  void _handleStoreEmailStateToRefreshAction(AccountId accountId, UserName userName, jmap.State newState) {
    log('EmailChangeListener::_handleStoreEmailStateToRefreshAction():newState: $newState');
    if (_storeEmailStateToRefreshInteractor != null) {
      consumeState(_storeEmailStateToRefreshInteractor!.execute(accountId, userName, newState));
    } else {
      logError('EmailChangeListener::_handleStoreEmailStateToRefreshAction():_storeEmailStateToRefreshInteractor is null');
    }
  }

  void _handleRemoveNotificationWhenEmailMarkAsRead(jmap.State newState, AccountId accountId, Session? session) {
    if (_getEmailChangesToRemoveNotificationInteractor != null && session != null) {
      consumeState(_getEmailChangesToRemoveNotificationInteractor!.execute(
        session,
        accountId,
        newState,
        propertiesCreated: Properties({EmailProperty.id, EmailProperty.keywords}),
        propertiesUpdated: Properties({EmailProperty.keywords}),
      ));
    }
  }

  void _handleRemoveLocalNotification({
    required UserName userName,
    required List<EmailId> emailIds
  }) async {
    log('EmailChangeListener::_handleRemoveLocalNotification():emailIds: $emailIds');
    await Future.wait(emailIds.map((emailId) => LocalNotificationManager.instance.removeNotification(emailId.id.value)));
    await LocalNotificationManager.instance.removeGroupPushNotification(userName.value);
  }

  void _getNewReceiveEmailFromNotificationAction(Session? session, AccountId accountId, jmap.State newState) {
    if (_getNewReceiveEmailFromNotificationInteractor != null && session != null) {
      consumeState(_getNewReceiveEmailFromNotificationInteractor!.execute(
        session: session,
        accountId: accountId,
        userName: session.username,
        newState: newState
      ));
    }
  }

  void _getListDetailedEmailByIdAction(Session? session, AccountId accountId, List<EmailId> emailIds) {
    log('EmailChangeListener::_getListDetailedEmailByIdAction():emailIds: $emailIds');
    if (_getListDetailedEmailByIdInteractor != null &&
        _dynamicUrlInterceptors != null &&
        session != null) {
      try {
        final baseDownloadUrl = session.getDownloadUrl(jmapUrl: _dynamicUrlInterceptors!.jmapUrl);
        consumeState(_getListDetailedEmailByIdInteractor!.execute(
            session,
            accountId,
            emailIds,
            baseDownloadUrl
        ));
      } catch (e) {
        logError('EmailChangeListener::_getListDetailedEmailByIdAction(): $e');
        consumeState(Stream.value(Left(GetDetailedEmailByIdFailure(e))));
      }
    }
  }

  void _storeNewEmailAction(
    Session session,
    AccountId accountId,
    Map<Email, DetailedEmail> mapDetailedEmails
  ) {
    log('EmailChangeListener::_storeNewEmailAction():mapDetailedEmails: ${mapDetailedEmails.length}');
    if (_storeListNewEmailInteractor != null) {
      consumeState(_storeListNewEmailInteractor!.execute(
        session,
        accountId,
        mapDetailedEmails
      ));
    }
  }
}