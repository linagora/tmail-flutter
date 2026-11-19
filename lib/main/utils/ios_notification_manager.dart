
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:rxdart/rxdart.dart';

class IOSNotificationManager {

  static const _notificationInteractionChannel = MethodChannel('notification_interaction_channel');

  static const String CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_FOREGROUND_OR_BACKGROUND = 'current_email_id_in_notification_click_when_app_foreground_or_background';
  static const String CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED = 'current_email_id_in_notification_click_when_app_terminated';

  static const String _removeDeliveredNotificationsOfAccount = 'remove_delivered_notifications_of_account';

  static const String _emailIdKey = 'email_id';
  static const String _accountIdKey = 'account_id';

  BehaviorSubject<NotificationPayload?> _pendingCurrentEmailIdInNotification = BehaviorSubject.seeded(null);
  BehaviorSubject<NotificationPayload?> get pendingCurrentEmailIdInNotification => _pendingCurrentEmailIdInNotification;

  StreamSubscription<NotificationPayload?>? _getCurrentEmailIdStreamSubscription;

  Future<NotificationPayload?>? _terminatedTap;

  /// True when a tap on a notification started the app.
  Future<bool> wasAppLaunchedByNotification() async => await _terminatedTap != null;

  void listenClickNotification() {
    try {
      _notificationInteractionChannel.setMethodCallHandler((methodCall) async {
        log('IOSNotificationManager::listenClickNotification: $methodCall');
        if (methodCall.method == CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_FOREGROUND_OR_BACKGROUND) {
          final tap = notificationTapOf(methodCall.arguments);
          if (tap != null) setPendingCurrentEmailId(tap);
        }
      });

      _terminatedTap = _getCurrentEmailIdInNotificationClick();
      _getCurrentEmailIdStreamSubscription = Stream.fromFuture(_terminatedTap!).listen((tap) {
        log('IOSNotificationManager::listenClickNotification:_getCurrentEmailIdInNotificationClick:EmailId = ${tap?.emailId?.asString}');
        if (tap != null) {
          setPendingCurrentEmailId(tap);
        }
      });
    } catch (e) {
      logWarning('IOSNotificationManager::listenClickNotification:Exception = $e');
    }
  }

  Future<NotificationPayload?> _getCurrentEmailIdInNotificationClick() async {
    try {
      log('IOSNotificationManager::_getCurrentEmailIdInNotificationClick: START');
      final arguments = await _notificationInteractionChannel.invokeMethod<Object?>(CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED);
      log('IOSNotificationManager::_getCurrentEmailIdInNotificationClick: END');
      return notificationTapOf(arguments);
    } catch (e) {
      logWarning('IOSNotificationManager::getCurrentEmailIdInNotificationClick:Exception = $e');
      return null;
    }
  }

  /// Removes the notifications the NSE showed for the delegated mailbox [accountId].
  static Future<void> removeDeliveredNotificationsOf(AccountId accountId) =>
      _notificationInteractionChannel.invokeMethod<void>(
        _removeDeliveredNotificationsOfAccount,
        {_accountIdKey: accountId.asString},
      );

  /// Reads the click channel arguments: an email id, or a map with `email_id` and the `account_id` of a delegated mailbox.
  static NotificationPayload? notificationTapOf(Object? arguments) {
    final emailId = arguments is Map ? arguments[_emailIdKey] : arguments;
    if (emailId is! String || emailId.isEmpty) return null;
    final accountId = arguments is Map ? arguments[_accountIdKey] : null;
    return NotificationPayload(
      emailId: EmailId(Id(emailId)),
      accountId: accountId is String && accountId.isNotEmpty ? AccountId(Id(accountId)) : null,
    );
  }

  void setPendingCurrentEmailId(NotificationPayload tap) async {
    clearPendingCurrentEmailId();
    _pendingCurrentEmailIdInNotification.add(tap);
  }

  /// The pending tap with an email, cleared so it opens once.
  NotificationPayload? takePendingTap() {
    final tap = _pendingCurrentEmailIdInNotification.valueOrNull;
    if (tap?.emailId == null) return null;
    clearPendingCurrentEmailId();
    return tap;
  }

  void clearPendingCurrentEmailId() {
    if(_pendingCurrentEmailIdInNotification.isClosed) {
      _pendingCurrentEmailIdInNotification = BehaviorSubject.seeded(null);
    } else {
      _pendingCurrentEmailIdInNotification.add(null);
    }
  }

  void dispose() {
    _pendingCurrentEmailIdInNotification.close();
    _getCurrentEmailIdStreamSubscription?.cancel();
    _getCurrentEmailIdStreamSubscription = null;
  }
}