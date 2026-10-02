import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/annotations.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import 'handle_more_email_action_test.mocks.dart';

/// TF-4894: on desktop the reading pane more menu dropped the « Label as »
/// click and relied on a hover submenu that did not always show up.
@GenerateNiceMocks([
  MockSpec<MarkAsEmailReadInteractor>(),
  MockSpec<MarkAsStarEmailInteractor>(),
  MockSpec<CreateNewEmailRuleFilterInteractor>(),
  MockSpec<PrintEmailInteractor>(),
  MockSpec<GetEmailContentInteractor>(),
])
void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('EmailActionReactor.handleMoreEmailAction on desktop', () {
    testWidgets(
      'should run handleEmailAction for labelAs when « Label as » is clicked',
      (tester) => verifyClickRunsAction(tester, EmailActionType.labelAs),
      variant: desktop,
    );
    testWidgets(
      'should run handleEmailAction for another action when it is clicked',
      (tester) => verifyClickRunsAction(tester, EmailActionType.markAsUnread),
      variant: desktop,
    );
    testWidgets(
      'should not run handleEmailAction when a label is picked from the hover submenu',
      verifySubmenuLabelDoesNotRunAction,
      variant: desktop,
    );
  });
}

/// `flutter_test` defaults to Android, where the old guard let `labelAs` through
final desktop = TargetPlatformVariant.desktop();

typedef HandledAction = (PresentationEmail, EmailActionType);

final email = PresentationEmail(id: EmailId(Id('email-1')));
final label = Label(id: Id('label-1'), displayName: 'Work');

Future<void> openMoreMenu(
  WidgetTester tester, {
  required List<HandledAction> handled,
  OnSelectLabelAction? onSelectLabelAction,
}) async {
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

  EmailActionReactor(
    MockMarkAsEmailReadInteractor(),
    MockMarkAsStarEmailInteractor(),
    MockCreateNewEmailRuleFilterInteractor(),
    MockPrintEmailInteractor(),
    MockGetEmailContentInteractor(),
  ).handleMoreEmailAction(
    presentationEmail: email,
    mailboxContain: null,
    // A position means the desktop popup menu, not the mobile bottom sheet
    position: const RelativeRect.fromLTRB(100, 100, 100, 100),
    responsiveUtils: ResponsiveUtils(),
    imagePaths: ImagePaths(),
    ownEmailAddress: 'me@example.com',
    handleEmailAction: (email, action) => handled.add((email, action)),
    additionalActions: const [],
    emailIsRead: true,
    isLabelAvailable: true,
    openBottomSheetContextMenu: ({
      required context,
      required itemActions,
      required onContextMenuActionClick,
      key,
      useGroupedActions = false,
    }) async {},
    openPopupMenu: (context, position, menu) => menu.show(context, position),
    onCreateANewLabelAction: () {},
    labels: [label],
    onSelectLabelAction: onSelectLabelAction,
  );
  await tester.pumpAndSettle();
}

Finder menuItemKey(EmailActionType action) =>
    find.byKey(Key('${action.name}_action'));

Finder menuItem(EmailActionType action) => menuItemKey(action).first;

Future<void> verifyClickRunsAction(
  WidgetTester tester,
  EmailActionType action,
) async {
  final handled = <HandledAction>[];
  await openMoreMenu(tester, handled: handled);

  await tester.tap(menuItem(action));
  await tester.pumpAndSettle();

  expect(handled, [(email, action)]);
  expect(menuItemKey(action), findsNothing);
}

Future<void> verifySubmenuLabelDoesNotRunAction(WidgetTester tester) async {
  final handled = <HandledAction>[];
  final selected = <Label>[];
  await openMoreMenu(
    tester,
    handled: handled,
    onSelectLabelAction: (label, _) => selected.add(label),
  );

  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(menuItem(EmailActionType.labelAs)));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Work'));
  await tester.pumpAndSettle();

  expect(selected, [label]);
  expect(handled, isEmpty);
}
