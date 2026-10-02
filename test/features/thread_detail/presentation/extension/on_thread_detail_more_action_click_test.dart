import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_a_thread_state.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/on_thread_detail_action_click.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import 'on_thread_detail_more_action_click_test.mocks.dart';

/// TF-4894: on desktop the thread detail more menu dropped the « Label as »
/// click and relied on a hover submenu that did not always show up.
@GenerateNiceMocks([
  MockSpec<ThreadDetailController>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<LabelController>(),
  MockSpec<Session>(),
])
void main() {
  late MockThreadDetailController controller;

  setUp(() {
    Get.testMode = true;
    Get.put(ImagePaths());
    Get.put(ResponsiveUtils());
    controller = buildController();
  });

  tearDown(Get.reset);

  group('ThreadDetailController.onThreadDetailMoreActionClick on desktop', () {
    testWidgets(
      'should open the label picker when « Label as » is clicked',
      (tester) => verifyLabelAsOpensPicker(tester, controller),
      variant: desktop,
    );
    testWidgets(
      'should run another action when it is clicked',
      (tester) => verifyOtherActionRuns(tester, controller),
      variant: desktop,
    );
    testWidgets(
      'should not open the label picker when a label is picked from the hover submenu',
      (tester) => verifySubmenuLabelDoesNotOpenPicker(tester, controller),
      variant: desktop,
    );
  });
}

/// `flutter_test` defaults to Android, where the old guard let `labelAs` through
final desktop = TargetPlatformVariant.desktop();

final label = Label(id: Id('label-1'), displayName: 'Work');

const labelPickerKey = Key('add_label_to_thread_modal');

MockThreadDetailController buildController() {
  final controller = MockThreadDetailController();
  final dashboard = MockMailboxDashBoardController();
  final labelController = MockLabelController();

  when(controller.mailboxDashBoardController).thenReturn(dashboard);
  when(controller.imagePaths).thenReturn(ImagePaths());
  when(controller.emailsInThreadDetailInfo).thenReturn(RxList([
    EmailInThreadDetailInfo(
      emailId: EmailId(Id('email-1')),
      keywords: null,
      mailboxIds: null,
      isValidToDisplay: true,
    ),
  ]));
  // Labels available: setting on, capability supported for this account
  when(dashboard.labelController).thenReturn(labelController);
  when(dashboard.accountId).thenReturn(Rxn(AccountId(Id('account-1'))));
  when(dashboard.sessionCurrent).thenReturn(MockSession());
  when(labelController.isLabelSettingEnabled).thenReturn(RxBool(true));
  when(labelController.isLabelCapabilitySupported(any, any)).thenReturn(true);
  when(labelController.labels).thenReturn(RxList([label]));
  return controller;
}

Future<void> openMoreMenu(
  WidgetTester tester,
  MockThreadDetailController controller,
) async {
  await tester.pumpWidget(GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: const Scaffold(),
    // As in the app: the hover submenu opens in this root overlay
    builder: FlutterSmartDialog.init(),
  ));
  // The localization delegates load asynchronously: settle so the navigator
  // behind `currentContext` exists.
  await tester.pumpAndSettle();

  // A position means the desktop popup menu, not the mobile bottom sheet
  controller.onThreadDetailMoreActionClick(
    const RelativeRect.fromLTRB(100, 100, 100, 100),
  );
  await tester.pumpAndSettle();
}

Finder menuItem(EmailActionType action) =>
    find.byKey(Key('${action.name}_action')).first;

List<dynamic> consumedStates(MockThreadDetailController controller) =>
    verify(controller.consumeState(captureAny)).captured;

Future<void> verifyLabelAsOpensPicker(
  WidgetTester tester,
  MockThreadDetailController controller,
) async {
  await openMoreMenu(tester, controller);

  await tester.tap(menuItem(EmailActionType.labelAs));
  await tester.pumpAndSettle();

  expect(find.byKey(labelPickerKey), findsOneWidget);
}

Future<void> verifyOtherActionRuns(
  WidgetTester tester,
  MockThreadDetailController controller,
) async {
  await openMoreMenu(tester, controller);

  // No session: the action reports its failure instead of calling the server
  await tester.tap(menuItem(EmailActionType.markAsRead));
  await tester.pumpAndSettle();

  final states = consumedStates(controller);
  expect(states, hasLength(1));
  final state = await (states.single as Stream).single;
  expect((state as Left).value, isA<MarkAsMultipleEmailReadFailure>());
  expect(find.byKey(labelPickerKey), findsNothing);
}

Future<void> verifySubmenuLabelDoesNotOpenPicker(
  WidgetTester tester,
  MockThreadDetailController controller,
) async {
  await openMoreMenu(tester, controller);

  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(menuItem(EmailActionType.labelAs)));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Work'));
  await tester.pumpAndSettle();

  // The label has no keyword: the add is reported as failed, no server call
  final states = consumedStates(controller);
  expect(states, hasLength(1));
  final state = await (states.single as Stream).single;
  expect((state as Left).value, isA<AddALabelToAThreadFailure>());
  expect(find.byKey(labelPickerKey), findsNothing);
}
