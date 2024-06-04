import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/toggle_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_controller.dart';

import 'notification_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetNotificationSettingInteractor>(),
  MockSpec<ToggleNotificationSettingInteractor>(),
  MockSpec<SettingsController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ManageAccountDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  final getNotificationSettingInteractor 
    = MockGetNotificationSettingInteractor();
  final toggleNotificationSettingInteractor 
    = MockToggleNotificationSettingInteractor();
  late NotificationController notificationController;

  final settingsController = MockSettingsController();

  setUpAll(() {
    Get.put<SettingsController>(settingsController);
  });

  setUp(() {
    notificationController = NotificationController(
      getNotificationSettingInteractor,
      toggleNotificationSettingInteractor);
  });

  group('notification controller test', () {
    test(
      'should call execute on getNotificationSettingInteractor '
      'when init',
    () async {
      // arrange
      final userName = UserName('value');
      final manageAccountDashboardController = MockManageAccountDashBoardController();
      when(manageAccountDashboardController.sessionCurrent).thenReturn(
        Session(
          {}, {}, {},
          userName,
          Uri(), Uri(), Uri(), Uri(), State('value'))
      );
      when(settingsController.manageAccountDashboardController).thenReturn(
        manageAccountDashboardController);
      when(getNotificationSettingInteractor.execute(any))
        .thenAnswer((_) => Stream.value(Left(GetNotificationSettingFailure())));

      // act
      notificationController.onInit();
      
      // assert
      verify(getNotificationSettingInteractor.execute(userName)).called(1);
    });

    test(
      'should call execute on toggleNotificationSettingInteractor '
      'when toggleNotificationSetting is triggered',
    () {
      // arrange
      notificationController.notificationSettingEnabled.value = true;
      when(toggleNotificationSettingInteractor.execute())
        .thenAnswer((_) => Stream.value(Left(ToggleNotificationSettingFailure())));

      // act
      notificationController.toggleNotificationSetting();
      
      // assert
      verify(toggleNotificationSettingInteractor.execute()).called(1);
    });

    test(
      'should change the value of notificationSettingEnabled '
      'when GetNotificationSettingSuccess is emitted',
    () async {
      // arrange
      const isEnabled = true;
      final userName = UserName('value');
      final manageAccountDashboardController = MockManageAccountDashBoardController();
      when(manageAccountDashboardController.sessionCurrent).thenReturn(
        Session(
          {}, {}, {},
          userName,
          Uri(), Uri(), Uri(), Uri(), State('value'))
      );
      when(settingsController.manageAccountDashboardController).thenReturn(
        manageAccountDashboardController);
      when(getNotificationSettingInteractor.execute(any))
        .thenAnswer((_) => Stream.value(Right(GetNotificationSettingSuccess(isEnabled: isEnabled))));

      // act
      await notificationController.onInit();
      
      // assert
      expect(notificationController.notificationSettingEnabled.value, isEnabled);
    });

    test(
      'should change the value of notificationSettingEnabled to false '
      'when GetNotificationSettingFailure is emitted',
    () async {
      // arrange
      final userName = UserName('value');
      final manageAccountDashboardController = MockManageAccountDashBoardController();
      when(manageAccountDashboardController.sessionCurrent).thenReturn(
        Session(
          {}, {}, {},
          userName,
          Uri(), Uri(), Uri(), Uri(), State('value'))
      );
      when(settingsController.manageAccountDashboardController).thenReturn(
        manageAccountDashboardController);
      when(getNotificationSettingInteractor.execute(any)).thenAnswer((_) => Stream.value(Left(GetNotificationSettingFailure())));

      // act
      await notificationController.onInit();
      
      // assert
      expect(notificationController.notificationSettingEnabled.value, false);
    });
  });
}