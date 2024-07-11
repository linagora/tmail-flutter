
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:rxdart/rxdart.dart';

class IOSNotificationManager {

  static const _notificationInteractionChannel = MethodChannel('notification_interaction_channel');

  static const String CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_FOREGROUND_OR_BACKGROUND = 'current_email_id_in_notification_click_when_app_foreground_or_background';
  static const String CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED = 'current_email_id_in_notification_click_when_app_terminated';

  BehaviorSubject<EmailId?> _pendingCurrentEmailIdInNotification = BehaviorSubject.seeded(null);
  BehaviorSubject<EmailId?> get pendingCurrentEmailIdInNotification => _pendingCurrentEmailIdInNotification;

  StreamSubscription<EmailId?>? _getCurrentEmailIdStreamSubscription;

  void listenClickNotification() {
    try {
      _notificationInteractionChannel.setMethodCallHandler((methodCall) async {
        log('IOSNotificationManager::listenClickNotification: $methodCall');
        if (methodCall.method == CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_FOREGROUND_OR_BACKGROUND
            && methodCall.arguments != null) {
          final emailId = EmailId(Id(methodCall.arguments));
          setPendingCurrentEmailId(emailId);
        }
      });

      _getCurrentEmailIdStreamSubscription = Stream.fromFuture(_getCurrentEmailIdInNotificationClick()).listen((emailId) {
        log('IOSNotificationManager::listenClickNotification:_getCurrentEmailIdInNotificationClick:EmailId = ${emailId?.asString}');
        if (emailId != null) {
          setPendingCurrentEmailId(emailId);
        }
      });
    } catch (e) {
      logError('IOSNotificationManager::listenClickNotification:Exception = $e');
    }
  }

  Future<EmailId?> _getCurrentEmailIdInNotificationClick() async {
    try {
      log('IOSNotificationManager::_getCurrentEmailIdInNotificationClick: START');
      final emailId = await _notificationInteractionChannel.invokeMethod<String?>(CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED);
      log('IOSNotificationManager::_getCurrentEmailIdInNotificationClick: END');
      if (emailId?.isNotEmpty == true) {
        return EmailId(Id(emailId!));
      } else {
        return null;
      }
    } catch (e) {
      logError('IOSNotificationManager::getCurrentEmailIdInNotificationClick:Exception = $e');
      return null;
    }
  }

  void setPendingCurrentEmailId(EmailId emailId) async {
    clearPendingCurrentEmailId();
    _pendingCurrentEmailIdInNotification.add(emailId);
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