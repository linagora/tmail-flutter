import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/remove_delegate_dialog.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

void main() {
  final l10n = AppLocalizations();
  final bob = Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress);
  const openButtonLabel = 'open';
  const submitButton = ValueKey(UiKeys.removeDelegateSubmitButton);
  const cancelButton = ValueKey(UiKeys.removeDelegateCancelButton);

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late RecordingAppToast appToast;
  late List<RemoveDelegateResult> removedResults;
  late int failedRemoves;

  setUp(() {
    repository = FakeDelegateRepository();
    appToast = RecordingAppToast();
    removedResults = [];
    failedRemoves = 0;
    Get.put(ResponsiveUtils(), permanent: true);
    Get.put(ImagePaths(), permanent: true);
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
      appToastProvider.overrideWithValue(appToast.toast),
    ]);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  Finder dialog() => find.byKey(const ValueKey(UiKeys.removeDelegateDialog));

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(
          body: Builder(
            builder: (_) => TextButton(
              onPressed: () => RemoveDelegateDialog.show(RemoveDelegateDialog(
                session: DelegationFixtures.session(),
                delegate: bob,
                onDelegateRemoved: removedResults.add,
                onRemoveFailed: () => failedRemoves++,
              )),
              child: const Text(openButtonLabel),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text(openButtonLabel));
    await tester.pumpAndSettle();
  }

  Future<void> tapRemove(WidgetTester tester) async {
    await tester.tap(find.byKey(submitButton));
    await tester.pump();
  }

  testWidgets('should ask with the delegate card and a red Remove access button', (tester) async {
    await openDialog(tester);

    expect(find.text(l10n.removeDelegateAccessTitle), findsOneWidget);
    expect(find.text(l10n.removeDelegateAccessMessage(DelegationFixtures.bobAddress)), findsOneWidget);
    expect(
      find.descendant(of: dialog(), matching: find.widgetWithText(LinagoraPersonTile, DelegationFixtures.bobAddress)),
      findsOneWidget,
    );
    expect(tester.widget<ConfirmDialogButton>(find.byKey(submitButton)).backgroundColor, AppColor.redFF3347);
    expect(repository.removeCalls, isEmpty);
  });

  testWidgets('should close without a request on Cancel', (tester) async {
    await openDialog(tester);

    await tester.tap(find.byKey(cancelButton));
    await tester.pumpAndSettle();

    expect(dialog(), findsNothing);
    expect(repository.removeCalls, isEmpty);
  });

  testWidgets('should close, report the result and toast when the delegate is removed', (tester) async {
    await openDialog(tester);
    final result = RemoveDelegateResult(removedDelegate: bob, delegates: const []);

    await tapRemove(tester);
    repository.pendingRemoves.last.complete(result);
    await tester.pumpAndSettle();

    expect(repository.removeCalls, [(DelegationFixtures.session().accountId, bob)]);
    expect(removedResults, [result]);
    expect(failedRemoves, 0);
    expect(appToast.successMessages, [l10n.delegateHasBeenRemoved(DelegationFixtures.bobAddress)]);
    expect(dialog(), findsNothing);
  });

  testWidgets('should not close nor send again while the request runs', (tester) async {
    await openDialog(tester);

    await tapRemove(tester);
    await tester.tap(find.byKey(cancelButton));
    await tester.tap(find.byTooltip(l10n.close));
    await tester.tapAt(const Offset(4, 4));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.binding.handlePopRoute();
    // A closing route would finish within these frames, while the progress indicator never settles.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(dialog(), findsOneWidget);
    expect(repository.removeCalls, hasLength(1));

    repository.pendingRemoves.last.complete(RemoveDelegateResult(removedDelegate: bob));
    await tester.pumpAndSettle();
  });

  testWidgets('should stay open with an error toast and Remove access enabled when the request fails', (tester) async {
    await openDialog(tester);

    await tapRemove(tester);
    repository.pendingRemoves.last.completeError(Exception('boom'));
    await tester.pumpAndSettle();

    expect(removedResults, isEmpty);
    expect(failedRemoves, 1);
    expect(appToast.errorMessages, [l10n.couldNotRemoveDelegate(DelegationFixtures.bobAddress)]);
    expect(appToast.successMessages, isEmpty);
    expect(dialog(), findsOneWidget);
    expect(tester.widget<ConfirmDialogButton>(find.byKey(submitButton)).onTapAction, isNotNull);
  });
}
