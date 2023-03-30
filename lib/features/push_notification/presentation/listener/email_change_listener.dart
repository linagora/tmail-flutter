
import 'dart:io';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/notification/notification_payload.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_stored_state_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_stored_email_state_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailboxes_not_put_notifications_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_email_delivery_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailboxes_not_put_notifications_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_delivery_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/fcm_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/change_listener.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_config.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailChangeListener extends ChangeListener {

  MailboxDashBoardController? _dashBoardController;
  GetStoredEmailDeliveryStateInteractor? _getStoredEmailDeliveryStateInteractor;
  StoreEmailDeliveryStateInteractor? _storeEmailDeliveryStateInteractor;
  GetEmailChangesToPushNotificationInteractor? _getEmailChangesToPushNotificationInteractor;
  GetStoredEmailStateInteractor? _getStoredEmailStateInteractor;
  StoreEmailStateToRefreshInteractor? _storeEmailStateToRefreshInteractor;
  GetMailboxesNotPutNotificationsInteractor? _getMailboxesNotPutNotificationsInteractor;

  jmap.State? _newState;
  AccountId? _accountId;
  Session? _session;
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
        _synchronizeEmailOnForegroundAction(action.newState);
      } else if (action is PushNotificationAction) {
        _pushNotificationAction(action.newState, action.accountId, action.session);
      } else if (action is StoreEmailStateToRefreshAction) {
        _handleStoreEmailStateToRefreshAction(action.newState);
      }
    }
  }

  void _synchronizeEmailOnForegroundAction(jmap.State newState) {
    log('EmailChangeListener::_synchronizeEmailAction():newState: $newState');
    if (_dashBoardController != null) {
      _dashBoardController!.dispatchEmailUIAction(RefreshChangeEmailAction(newState));
    }
  }

  void _pushNotificationAction(jmap.State newState, AccountId accountId, Session? session) {
    _newState = newState;
    _accountId = accountId;
    _session = session;
    log('EmailChangeListener::_pushNotificationAction():newState: $newState');

    if (BuildUtils.isWeb) {
      _storeEmailDeliveryStateAction(_newState!);
    } else {
      if (Platform.isAndroid) {
        _getStoredEmailDeliveryState();
      } else if (Platform.isIOS) {
        _storeEmailDeliveryStateAction(_newState!);
        _showLocalNotificationForIOS(_newState!, _accountId!);
      } else {
        logError('EmailChangeListener::_pushNotificationAction(): NOT SUPPORTED PLATFORM');
      }
    }
  }



  void _getStoredEmailDeliveryState() {
    if (_getStoredEmailDeliveryStateInteractor != null) {
      consumeState(_getStoredEmailDeliveryStateInteractor!.execute());
    }
  }

  void _getStoredEmailState() {
    if (_getStoredEmailStateInteractor != null && _accountId != null) {
      consumeState(_getStoredEmailStateInteractor!.execute(_accountId!));
    } else {
      logError('EmailChangeListener::_getStoredEmailState(): _getStoredEmailStateInteractor is null');
    }
  }

  void _getEmailChangesAction(jmap.State state) {
    if (_getEmailChangesToPushNotificationInteractor != null && _accountId != null && _session != null) {
      consumeState(_getEmailChangesToPushNotificationInteractor!.execute(
        _session!,
        _accountId!,
        state,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
      ));
    }
  }

  void _storeEmailDeliveryStateAction(jmap.State state) {
    if (_storeEmailDeliveryStateInteractor != null) {
      consumeState(_storeEmailDeliveryStateInteractor!.execute(state));
    }
  }

  void _showLocalNotification(PresentationEmail presentationEmail) {
    final notificationPayload = NotificationPayload(emailId: presentationEmail.id);
    log('EmailChangeListener::_showLocalNotification():notificationPayload: $notificationPayload');
    LocalNotificationManager.instance.showPushNotification(
      id: presentationEmail.id?.id.value ?? '',
      title: presentationEmail.subject ?? '',
      message: presentationEmail.preview,
      emailAddress: presentationEmail.from?.first,
      payload: notificationPayload.encodeToString,
    );
  }

  void _showLocalNotificationForIOS(jmap.State newState, AccountId accountId) {
    final notificationPayload = NotificationPayload(newState: newState);
    log('EmailChangeListener::_showLocalNotificationForIOS():notificationPayload: $notificationPayload');
    LocalNotificationManager.instance.showPushNotification(
      id: '${FcmUtils.instance.platformOS}-${accountId.id.value}',
      title: currentContext != null
        ? AppLocalizations.of(currentContext!).appTitlePushNotification
        : LocalNotificationConfig.notificationTitle,
      message: currentContext != null
        ? AppLocalizations.of(currentContext!).youHaveNewMessages
        : LocalNotificationConfig.notificationMessage,
      payload: notificationPayload.encodeToString,
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
      _handleLocalPushNotification(listEmails);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('EmailChangeListener::_handleSuccessViewState(): $success');
    if (success is GetStoredEmailDeliveryStateSuccess) {
      if (_newState != success.state) {
        _getEmailChangesAction(success.state);
      }
    } else if (success is GetStoredEmailStateSuccess) {
      _getEmailChangesAction(success.state);
    } else if (success is GetEmailChangesToPushNotificationSuccess) {
      if (_newState != null) {
        _storeEmailDeliveryStateAction(_newState!);

        if (FcmUtils.instance.isMobileAndroid) {
          _handleListEmailToPushNotification(success.emailList);
        }
      }
    } else if (success is GetMailboxesNotPutNotificationsSuccess) {
      final listEmails = _emailsAvailablePushNotification.toEmailsAvailablePushNotification(
        mailboxIdsNotPutNotifications: success.mailboxes.mailboxIds);
      _handleLocalPushNotification(listEmails);
    }
  }

  void _handleListEmailToPushNotification(List<PresentationEmail> emailList) {
    _emailsAvailablePushNotification = emailList;
    if (_getMailboxesNotPutNotificationsInteractor != null && _accountId != null && _session != null) {
      consumeState(_getMailboxesNotPutNotificationsInteractor!.execute(_session!, _accountId!));
    } else {
      final listEmails = _emailsAvailablePushNotification.toEmailsAvailablePushNotification();
      _handleLocalPushNotification(listEmails);
    }
  }

  void _handleLocalPushNotification(List<PresentationEmail> emailList) {
    log('EmailChangeListener::_handleLocalPushNotification():emailList: $emailList');
    if (emailList.isEmpty) {
      return;
    }

    for (var presentationEmail in emailList) {
      _showLocalNotification(presentationEmail);
    }

    LocalNotificationManager.instance.groupPushNotification();

    _emailsAvailablePushNotification.clear();
  }

  void _handleStoreEmailStateToRefreshAction(jmap.State newState) {
    log('EmailChangeListener::_handleStoreEmailStateToRefreshAction():newState: $newState');
    if (_storeEmailStateToRefreshInteractor != null) {
      consumeState(_storeEmailStateToRefreshInteractor!.execute(newState));
    } else {
      logError('EmailChangeListener::_handleStoreEmailStateToRefreshAction():_storeEmailStateToRefreshInteractor is null');
    }
  }
}