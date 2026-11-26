import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/add_delegates/add_delegates_dialog.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/my_delegates_section.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/remove_delegate_dialog.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

class _FakeAutoCompleteRepository implements AutoCompleteRepository {
  final List<AutoCompletePattern> patterns = [];
  Object? error;

  @override
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern) async {
    patterns.add(autoCompletePattern);
    if (error != null) throw error!;
    return [EmailAddress(null, DelegationFixtures.bobAddress)];
  }
}

void main() {
  final bob = Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress);
  final carol = Delegate(id: Id('carol-delegate'), username: DelegationFixtures.carolAddress);
  final l10n = AppLocalizations();
  const emptyCard = ValueKey(UiKeys.myDelegatesEmptyCard);
  const list = ValueKey(UiKeys.myDelegatesList);
  const addButton = ValueKey(UiKeys.myDelegatesAddButton);

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late RecordingAppToast appToast;

  setUp(() {
    repository = FakeDelegateRepository();
    appToast = RecordingAppToast();
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
      appToastProvider.overrideWithValue(appToast.toast),
    ]);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  void useAutoComplete(AutoCompleteRepository autoComplete) {
    container.dispose();
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
      delegateAutoCompleteInteractorProvider.overrideWithValue(GetAutoCompleteInteractor(autoComplete)),
      appToastProvider.overrideWithValue(appToast.toast),
    ]);
  }

  Future<void> pumpSection(WidgetTester tester) async {
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
        home: Scaffold(body: MyDelegatesSection(session: DelegationFixtures.session())),
      ),
    ));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);
  }

  Future<void> completeLoad(WidgetTester tester, List<Delegate> delegates) async {
    repository.pendingGets.last.complete(delegates);
    await tester.pumpAndSettle();
  }

  Future<void> failLoad(WidgetTester tester) async {
    repository.pendingGets.last.completeError(Exception('boom'));
    await tester.pumpAndSettle();
  }

  testWidgets('should show a spinner and no add button while the list loads', (tester) async {
    await pumpSection(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(addButton), findsNothing);
    expect(repository.getCalls, hasLength(1));
  });

  testWidgets('should show an enabled add button inside the empty card when no one has access', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);

    expect(find.text(l10n.myDelegatesExplanation), findsOneWidget);
    expect(find.text(l10n.whoHasAccessToYourMailbox), findsOneWidget);
    expect(find.text(l10n.noOneHasAccessYet), findsOneWidget);
    expect(find.text(l10n.noOneHasAccessYetMessage), findsOneWidget);
    expect(find.byKey(list), findsNothing);
    expect(find.byKey(addButton), findsNothing);
    final cardAction = find.descendant(
      of: find.byKey(emptyCard),
      matching: find.byKey(LinagoraEmptyCard.actionKey),
    );
    final button = tester.widget<LinagoraButton>(cardAction);
    expect(button.label, l10n.addDelegate);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('should list every delegate with a remove action and an enabled add button below', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob, carol]);

    expect(find.byKey(list), findsOneWidget);
    expect(find.byKey(emptyCard), findsNothing);
    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
    expect(find.text(DelegationFixtures.carolAddress), findsOneWidget);
    expect(
      tester.widgetList<LinagoraPersonTile>(find.byType(LinagoraPersonTile)).map((tile) => tile.action?.tooltip),
      [l10n.removeAccess, l10n.removeAccess],
    );
    expect(tester.widget<LinagoraButton>(find.byKey(addButton)).onPressed, isNotNull);
  });

  testWidgets('should paint the add button below the list like the empty card one, not in the theme primary', (tester) async {
    final tokens = LinagoraEmptyCardStyle.material();
    await pumpSection(tester);
    await completeLoad(tester, [bob]);

    final material = tester.widget<Material>(
      find.descendant(of: find.byKey(addButton), matching: find.byType(Material)).first,
    );
    expect(material.color, tokens.actionBackgroundColor);
    expect(tester.getSize(find.byKey(addButton)).height, tokens.actionHeight);
  });

  testWidgets('should show the error card with Retry and no add button when the read fails', (tester) async {
    await pumpSection(tester);
    await failLoad(tester);

    expect(find.text(l10n.couldNotLoadDelegates), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);
    expect(find.byKey(addButton), findsNothing);
    expect(find.byKey(list), findsNothing);
  });

  testWidgets('should read again and list the delegates when Retry is tapped', (tester) async {
    await pumpSection(tester);
    await failLoad(tester);

    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);
    expect(repository.getCalls, hasLength(2));
    await completeLoad(tester, [bob]);

    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
    expect(find.text(l10n.couldNotLoadDelegates), findsNothing);
  });

  Future<AddDelegatesDialog> openAddDialog(WidgetTester tester, Finder add) async {
    await tester.tap(add);
    await tester.pumpAndSettle();
    return tester.widget<AddDelegatesDialog>(find.byType(AddDelegatesDialog));
  }

  Finder emptyCardAction() => find.descendant(
        of: find.byKey(emptyCard),
        matching: find.byKey(LinagoraEmptyCard.actionKey),
      );

  Future<RemoveDelegateDialog> openRemoveDialog(WidgetTester tester, Delegate delegate) async {
    await tester.tap(find.byKey(LinagoraPersonTile.actionKeyFor(delegate.username)));
    await tester.pumpAndSettle();
    return tester.widget<RemoveDelegateDialog>(find.byType(RemoveDelegateDialog));
  }

  testWidgets('should open the remove dialog for the delegate of the tapped row', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob, carol]);

    final dialog = await openRemoveDialog(tester, carol);

    expect(dialog.delegate, carol);
    expect(repository.removeCalls, isEmpty);
  });

  testWidgets('should show the empty state the remove request re-read without reading it again', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob]);
    final dialog = await openRemoveDialog(tester, bob);

    dialog.onDelegateRemoved(RemoveDelegateResult(removedDelegate: bob, delegates: const []));
    await tester.pumpAndSettle();

    expect(repository.getCalls, hasLength(1));
    expect(find.byKey(emptyCard), findsOneWidget);
    expect(find.byKey(list), findsNothing);
  });

  testWidgets('should read the list again when the remove request could not re-read it', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob]);
    final dialog = await openRemoveDialog(tester, bob);

    dialog.onDelegateRemoved(RemoveDelegateResult(removedDelegate: bob));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);

    expect(repository.getCalls, hasLength(2));
  });

  testWidgets('should read the list again when the remove request fails', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob]);
    final dialog = await openRemoveDialog(tester, bob);

    dialog.onRemoveFailed();
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);

    expect(repository.getCalls, hasLength(2));
  });

  Future<void> typeInDialog(WidgetTester tester, String address) async {
    await tester.enterText(
      find.descendant(of: find.byKey(const ValueKey(UiKeys.addDelegatesAddressField)), matching: find.byType(TextField)),
      address,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // The list may be reloading behind the dialog, and its spinner never settles.
    await tester.pump();
  }

  testWidgets('should open the add dialog from the empty card', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);

    await openAddDialog(tester, emptyCardAction());

    expect(find.byType(AddDelegatesDialog), findsOneWidget);
  });

  testWidgets('should refuse a listed delegate in the add dialog opened below the list', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob, carol]);
    await openAddDialog(tester, find.byKey(addButton));

    await typeInDialog(tester, DelegationFixtures.carolAddress);

    expect(appToast.errorMessages, [l10n.alreadyHasDelegateAccess(DelegationFixtures.carolAddress)]);
  });

  testWidgets('should refuse in the open dialog a delegate the list re-read after a failed add', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    dialog.onAddFailed();
    await tester.pump();
    await completeLoad(tester, [bob]);
    await typeInDialog(tester, DelegationFixtures.bobAddress);

    expect(appToast.errorMessages, [l10n.alreadyHasDelegateAccess(DelegationFixtures.bobAddress)]);
  });

  testWidgets('should keep refusing the listed delegates in the open dialog while the list reloads', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob]);
    final dialog = await openAddDialog(tester, find.byKey(addButton));

    dialog.onAddFailed();
    await tester.pump();
    await typeInDialog(tester, DelegationFixtures.bobAddress);

    expect(repository.pendingGets.last.isCompleted, isFalse);
    expect(appToast.errorMessages, [l10n.alreadyHasDelegateAccess(DelegationFixtures.bobAddress)]);
  });

  testWidgets('should show the list re-read by the add request without reading it again', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    dialog.onDelegatesAdded(AddDelegatesResult(
      addedUsernames: [DelegationFixtures.bobAddress],
      rejectedUsernames: const {},
      delegates: [bob],
    ));
    await tester.pumpAndSettle();

    expect(repository.getCalls, hasLength(1));
    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
  });

  testWidgets('should read the list again when the add request could not re-read it', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    dialog.onDelegatesAdded(AddDelegatesResult(
      addedUsernames: [DelegationFixtures.bobAddress],
      rejectedUsernames: const {},
    ));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);

    expect(repository.getCalls, hasLength(2));
  });

  testWidgets('should read the list again when the add request fails', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    dialog.onAddFailed();
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);

    expect(repository.getCalls, hasLength(2));
  });

  testWidgets('should keep the re-read list when an older read finishes after it', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());
    dialog.onAddFailed();
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);

    dialog.onDelegatesAdded(AddDelegatesResult(
      addedUsernames: [DelegationFixtures.bobAddress],
      rejectedUsernames: const {},
      delegates: [bob],
    ));
    await completeLoad(tester, []);

    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
  });

  testWidgets('should offer no suggestion when the server has no contact autocomplete', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    expect(await dialog.loadSuggestions('bo'), isEmpty);
  });

  testWidgets('should query the account contacts for suggestions', (tester) async {
    final autoComplete = _FakeAutoCompleteRepository();
    useAutoComplete(autoComplete);
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    final suggestions = await dialog.loadSuggestions('bo', limit: 5);

    expect(suggestions, [EmailAddress(null, DelegationFixtures.bobAddress)]);
    expect(autoComplete.patterns, [
      AutoCompletePattern(word: 'bo', limit: 5, accountId: DelegationFixtures.session().accountId),
    ]);
  });

  testWidgets('should offer no suggestion when the contact query fails', (tester) async {
    final autoComplete = _FakeAutoCompleteRepository()..error = Exception('boom');
    useAutoComplete(autoComplete);
    await pumpSection(tester);
    await completeLoad(tester, []);
    final dialog = await openAddDialog(tester, emptyCardAction());

    expect(await dialog.loadSuggestions('bo'), isEmpty);
  });
}
