import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderContainer;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/mockito.dart';
import 'package:model/notification/notification_payload.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'mailbox_dashboard_controller_test_harness.dart';

void main() {
  setUpMailboxDashboardControllerTest();

  // Same start as the iOS notification tap group of mailbox_dashboard_controller_test.dart: no session
  // in the route arguments, so the dashboard reloads it and handleReloaded sets it up.
  group('Android notification tap:', () {
    final emailId = EmailId(Id('e-1'));
    final session = DelegationFixtures.session();
    final android = TargetPlatformVariant.only(TargetPlatform.android);
    String payloadOf({AccountId? accountId}) =>
        NotificationPayload(emailId: emailId, accountId: accountId).encodeToString;

    VerificationResult verifyEmailFetched() => verify(getEmailByIdInteractor.execute(
          session,
          DelegationFixtures.aliceAccountId,
          emailId,
          properties: anyNamed('properties'),
        ));

    Future<void> startDashboard(WidgetTester tester, {ProviderContainer? container}) async {
      final appContainer = container ?? ProviderContainer();
      addTearDown(appContainer.dispose);
      await pumpLocalizedApp(tester, container: appContainer);
      Get.delete<MailboxDashBoardController>(force: true);
      Get.put(mailboxDashboardController);
      mailboxDashboardController.onReady();
    }

    void tapInRunningApp(String payload) =>
        LocalNotificationManager.instance.localNotificationsController.add(NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: payload,
        ));

    setUp(() async {
      // A closed dashboard closes the shared stream, a starting app finds it open.
      await LocalNotificationManager.instance.recreateStreamController();
      final platform = FlutterLocalNotificationsPlatform.instance;
      FlutterLocalNotificationsPlatform.instance = _AppLaunchedFromNotification(payloadOf());
      addTearDown(() => FlutterLocalNotificationsPlatform.instance = platform);
      when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
      when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
      when(labelController.isLabelSettingEnabled).thenReturn(RxBool(false));
      reset(getEmailByIdInteractor);
      when(getEmailByIdInteractor.execute(any, any, any, properties: anyNamed('properties')))
          .thenAnswer((_) => const Stream.empty());
    });

    tearDown(() => reset(getEmailByIdInteractor));

    testWidgets('opens the tap that started the app once the reloaded session loads', (tester) async {
      await startDashboard(tester);

      mailboxDashboardController.handleReloaded(session);
      await tester.pump();

      verifyEmailFetched().called(1);
    }, variant: android);

    // onInit and every session set-up both listen to the same open stream.
    testWidgets('a tap of the running app SHOULD open its email once', (tester) async {
      await startDashboard(tester);
      mailboxDashboardController.handleReloaded(session);
      await tester.pump();

      tapInRunningApp(payloadOf());
      await tester.pump();

      verifyEmailFetched().called(1);
    }, variant: android);
  });
}

/// Android started the app from a tap on a notification with [payload].
class _AppLaunchedFromNotification extends AndroidFlutterLocalNotificationsPlugin {
  final String payload;

  _AppLaunchedFromNotification(this.payload);

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async =>
      NotificationAppLaunchDetails(
        true,
        notificationResponse: NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: payload,
        ),
      );
}
