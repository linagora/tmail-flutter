import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/my_delegates_section.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

/// Stands for an error the app routes as urgent, such as a lost connection or expired credentials.
class _UrgentError implements Exception {}

class _RecordingUrgentExceptionHandler implements UrgentExceptionHandler {
  final List<Exception?> routed = [];

  @override
  bool validateUrgentException(dynamic exception) => exception is _UrgentError;

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) => routed.add(exception);
}

void main() {
  final bob = Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress);
  final carol = Delegate(id: Id('carol-delegate'), username: DelegationFixtures.carolAddress);
  final l10n = AppLocalizations();
  const removeDialog = ValueKey(UiKeys.removeDelegateDialog);
  const submitButton = ValueKey(UiKeys.removeDelegateSubmitButton);
  const emptyCard = ValueKey(UiKeys.myDelegatesEmptyCard);
  const homePage = 'home';

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late RecordingAppToast appToast;
  late _RecordingUrgentExceptionHandler urgentHandler;

  setUp(() {
    repository = FakeDelegateRepository();
    appToast = RecordingAppToast();
    urgentHandler = _RecordingUrgentExceptionHandler();
    Get.put(ResponsiveUtils(), permanent: true);
    Get.put(ImagePaths(), permanent: true);
    Get.put<UrgentExceptionHandler>(urgentHandler);
    container = ProviderContainer(
      overrides: [
        delegateRepositoryProvider.overrideWithValue(repository),
        appToastProvider.overrideWithValue(appToast.toast),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  /// Shows Bob in By me, on a page pushed over the home page like Settings, opens his remove dialog and taps Remove
  /// access.
  Future<void> tapRemoveBob(WidgetTester tester, {List<Delegate>? listed}) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GetMaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: Scaffold(body: Text(homePage)),
        ),
      ),
    );
    await tester.pump();
    Navigator.of(tester.element(find.text(homePage))).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(body: MyDelegatesSection(session: DelegationFixtures.session())),
      ),
    );
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);
    repository.pendingGets.last.complete(listed ?? [bob]);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(LinagoraPersonTile.actionKeyFor(bob.username)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(submitButton));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);
  }

  /// A failed remove leaves the dialog open, and GetX keeps its navigator across tests, so close it here.
  void testRemove(String description, Future<void> Function(WidgetTester tester) body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        final dialog = find.byKey(removeDialog);
        if (dialog.evaluate().isNotEmpty) {
          Navigator.of(tester.element(dialog)).pop();
          await tester.pumpAndSettle();
        }
      }
    });
  }

  Future<void> failRemove(WidgetTester tester, Object error) async {
    repository.pendingRemoves.last.completeError(error);
    await tester.pumpAndSettle();
    await tester.runAsync(untilRepositoryCalled);
  }

  group('a remove that fails with an error the app routes as urgent', () {
    testRemove('should leave the error message to the urgent handler', (tester) async {
      await tapRemoveBob(tester);

      await failRemove(tester, _UrgentError());

      expect(urgentHandler.routed, hasLength(1));
      expect(appToast.errorMessages, isEmpty);
    });

    testRemove('should route the error once, without a follow-up read that fails the same way', (tester) async {
      await tapRemoveBob(tester);

      await failRemove(tester, _UrgentError());
      for (final read in repository.pendingGets.skip(1)) {
        read.completeError(_UrgentError());
      }
      await tester.pumpAndSettle();

      expect(urgentHandler.routed, hasLength(1));
    });
  });

  testRemove('should toast the error and read the list again when the remove fails with a non-urgent error', (
    tester,
  ) async {
    await tapRemoveBob(tester);

    await failRemove(tester, Exception('boom'));

    expect(urgentHandler.routed, isEmpty);
    expect(appToast.errorMessages, [l10n.couldNotRemoveDelegate(bob.username)]);
    expect(repository.getCalls, hasLength(2));
  });

  testRemove('should not keep asking to remove a delegate the list read after a failed remove no longer has', (
    tester,
  ) async {
    await tapRemoveBob(tester);

    // The request timed out after the server had already removed Bob.
    await failRemove(tester, Exception('timeout'));
    repository.pendingGets.last.complete(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(emptyCard), findsOneWidget);
    expect(find.byKey(removeDialog), findsNothing);
  });

  testRemove('should close only the remove dialog, not the page under it, when the delegate is removed', (
    tester,
  ) async {
    await tapRemoveBob(tester);

    repository.pendingRemoves.last.complete(RemoveDelegateResult(removedDelegate: bob, delegates: const []));
    await tester.pumpAndSettle();

    expect(find.byKey(removeDialog), findsNothing);
    expect(find.byKey(emptyCard), findsOneWidget);
    expect(appToast.successMessages, [l10n.delegateHasBeenRemoved(bob.username)]);
  });

  testRemove(
    'should stay open while a retry runs, even when the read after the failed try no longer has the delegate',
    (tester) async {
      await tapRemoveBob(tester);
      await failRemove(tester, Exception('timeout'));

      await tester.tap(find.byKey(submitButton));
      await tester.pump();
      await tester.runAsync(untilRepositoryCalled);
      repository.pendingGets.last.complete(const []);
      // A closing route would finish within these frames, while the progress indicator never settles.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(removeDialog), findsOneWidget);
      expect(repository.removeCalls, hasLength(2));

      repository.pendingRemoves.last.complete(RemoveDelegateResult(removedDelegate: bob, delegates: const []));
      await tester.pumpAndSettle();

      expect(find.byKey(removeDialog), findsNothing);
      expect(find.byKey(emptyCard), findsOneWidget);
    },
  );

  testRemove('should show a red progress button while the request runs', (tester) async {
    await tapRemoveBob(tester);

    final progressButton = find.ancestor(
      of: find.descendant(of: find.byKey(removeDialog), matching: find.byType(CupertinoLoadingWidget)),
      matching: find.byType(ConfirmDialogButton),
    );
    expect(progressButton, findsOneWidget);
    expect(tester.widget<ConfirmDialogButton>(progressButton).backgroundColor, AppColor.redFF3347);

    repository.pendingRemoves.last.complete(RemoveDelegateResult(removedDelegate: bob, delegates: const []));
    await tester.pumpAndSettle();
  });

  testRemove('should close when the read after a failed remove lists the other delegates but not this one', (
    tester,
  ) async {
    await tapRemoveBob(tester, listed: [bob, carol]);

    await failRemove(tester, Exception('timeout'));
    repository.pendingGets.last.complete([carol]);
    await tester.pumpAndSettle();

    expect(find.byKey(removeDialog), findsNothing);
    expect(find.byKey(LinagoraPersonTile.actionKeyFor(carol.username)), findsOneWidget);
  });

  testRemove('should stay open when the read after a failed remove still lists the delegate', (tester) async {
    await tapRemoveBob(tester, listed: [bob, carol]);

    await failRemove(tester, Exception('boom'));
    repository.pendingGets.last.complete([bob, carol]);
    await tester.pumpAndSettle();

    expect(find.byKey(removeDialog), findsOneWidget);
    expect(tester.widget<ConfirmDialogButton>(find.byKey(submitButton)).onTapAction, isNotNull);
  });
}
