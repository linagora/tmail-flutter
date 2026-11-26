import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/contact_input_tag_item.dart';
import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/my_delegates_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/add_delegates/add_delegates_dialog.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../../fixtures/delegate_fakes.dart';
import '../../../../../fixtures/delegation_fixtures.dart';
import '../../../../../fixtures/recording_app_toast.dart';

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
  final l10n = AppLocalizations();
  const openButtonLabel = 'open';

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late RecordingAppToast appToast;
  late List<AddDelegatesResult> addedResults;
  late List<String> suggestionQueries;
  late int failedAdds;

  Future<List<EmailAddress>> loadSuggestions(String query, {int? limit}) async {
    suggestionQueries.add(query);
    return [
      EmailAddress('Alice', DelegationFixtures.aliceAddress),
      EmailAddress('Bob', DelegationFixtures.bobAddress),
      EmailAddress('Carol', DelegationFixtures.carolAddress),
    ].where((contact) => contact.email!.contains(query)).toList();
  }

  Delegate delegate(String username) => Delegate(id: Id(username.split('@').first), username: username);

  setUp(() {
    repository = FakeDelegateRepository();
    appToast = RecordingAppToast();
    addedResults = [];
    suggestionQueries = [];
    failedAdds = 0;
    Get.put(ResponsiveUtils(), permanent: true);
    Get.put(ImagePaths(), permanent: true);
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
      appToastProvider.overrideWithValue(appToast.toast),
    ]);
    // Stands in for the section, which keeps the list alive and shows the re-read one.
    container.listen(myDelegatesProvider, (_, __) {});
    container.read(myDelegatesProvider.notifier).show([delegate(DelegationFixtures.carolAddress)]);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  Finder dialog() => find.byKey(const ValueKey(UiKeys.addDelegatesDialog));
  Finder addressInput() => find.descendant(
        of: find.byKey(const ValueKey(UiKeys.addDelegatesAddressField)),
        matching: find.byType(TextField),
      );
  bool isEnabled(WidgetTester tester, String key) {
    final button = find.descendant(of: find.byKey(ValueKey(key)), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    return tester.widget<ButtonStyleButton>(button.first).enabled;
  }

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
              onPressed: () => AddDelegatesDialog.show(AddDelegatesDialog(
                session: DelegationFixtures.session(),
                loadSuggestions: loadSuggestions,
                onDelegatesAdded: addedResults.add,
                onAddFailed: () => failedAdds++,
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

  Future<void> typeAddress(WidgetTester tester, String address) async {
    await tester.enterText(addressInput(), address);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> tapAdd(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey(UiKeys.addDelegatesSubmitButton)));
    await tester.pump();
  }

  Future<void> replyAdd(WidgetTester tester, AddDelegatesResult result) async {
    repository.pendingAdds.last.complete(result);
    await tester.pumpAndSettle();
  }

  Future<void> searchContacts(WidgetTester tester) async {
    await tester.enterText(addressInput(), 'domain');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  }

  Finder tappableSuggestion(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(InkWell));

  testWidgets('should keep Add disabled until an address is picked', (tester) async {
    await openDialog(tester);

    expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isFalse);

    await typeAddress(tester, DelegationFixtures.bobAddress);

    expect(find.text(DelegationFixtures.bobAddress), findsWidgets);
    expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isTrue);
  });

  testWidgets('should refuse my own address with a toast and keep the typed text', (tester) async {
    await openDialog(tester);

    await typeAddress(tester, DelegationFixtures.aliceAddress);

    expect(appToast.errorMessages, [l10n.cannotDelegateToYourself]);
    expect(tester.widget<TextField>(addressInput()).controller!.text, DelegationFixtures.aliceAddress);
  });

  testWidgets('should refuse an existing delegate with a toast', (tester) async {
    await openDialog(tester);

    await typeAddress(tester, DelegationFixtures.carolAddress);

    expect(appToast.errorMessages, [l10n.alreadyHasDelegateAccess(DelegationFixtures.carolAddress)]);
  });

  testWidgets('should not suggest my own address nor an existing delegate', (tester) async {
    await openDialog(tester);

    await searchContacts(tester);

    expect(suggestionQueries, ['domain']);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Alice'), findsNothing);
    expect(find.text('Carol'), findsNothing);
  });

  testWidgets('should show a typed address as a chip with an avatar', (tester) async {
    await openDialog(tester);

    await typeAddress(tester, DelegationFixtures.bobAddress);

    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.avatar, isA<GradientCircleAvatarIcon>());
    expect(find.descendant(of: find.byType(Chip), matching: find.text(DelegationFixtures.bobAddress)), findsOneWidget);
  });

  testWidgets('should close, report the result and toast when every address is added', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);
    final result = AddDelegatesResult(addedUsernames: [DelegationFixtures.bobAddress], rejectedUsernames: const {});

    await tapAdd(tester);
    await replyAdd(tester, result);

    expect(repository.addCalls, [
      {DelegationFixtures.bobAddress},
    ]);
    expect(addedResults, [result]);
    expect(failedAdds, 0);
    expect(appToast.successMessages, [l10n.delegateHasBeenAdded(DelegationFixtures.bobAddress)]);
    expect(dialog(), findsNothing);
  });

  testWidgets('should not close while the request runs', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);

    await tapAdd(tester);
    await tester.tap(find.byKey(const ValueKey(UiKeys.addDelegatesCancelButton)));
    await tester.tapAt(const Offset(4, 4));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.binding.handlePopRoute();
    // A closing route would finish within these frames, while the progress indicator never settles.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(dialog(), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
    expect(repository.addCalls, hasLength(1));

    await replyAdd(tester, AddDelegatesResult(addedUsernames: [DelegationFixtures.bobAddress], rejectedUsernames: const {}));
  });

  testWidgets('should lock the address field while the request runs and unlock it when it fails', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);
    bool isFieldEnabled() => tester.widget<TextField>(addressInput()).enabled ?? true;
    expect(isFieldEnabled(), isTrue);

    await tapAdd(tester);
    expect(isFieldEnabled(), isFalse);

    repository.pendingAdds.last.completeError(Exception('boom'));
    await tester.pumpAndSettle();
    expect(isFieldEnabled(), isTrue);
  });

  testWidgets('should keep the rejected chip with an error and toast the added ones', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);
    await typeAddress(tester, 'dave@domain.tld');
    final result = AddDelegatesResult(
      addedUsernames: [DelegationFixtures.bobAddress],
      rejectedUsernames: const {'dave@domain.tld': null},
    );

    await tapAdd(tester);
    await replyAdd(tester, result);

    expect(addedResults, [result]);
    expect(appToast.successMessages, [l10n.delegateHasBeenAdded(DelegationFixtures.bobAddress)]);
    expect(dialog(), findsOneWidget);
    expect(find.text(l10n.someDelegatesCouldNotBeAdded), findsOneWidget);
    expect(find.text('dave@domain.tld'), findsWidgets);
    expect(find.text(DelegationFixtures.bobAddress), findsNothing);
    final chipBorder = tester.widget<Chip>(find.byType(Chip)).shape as RoundedRectangleBorder;
    expect(chipBorder.side.color, AppColor.colorBorderEmailAddressInvalid);
    expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isFalse);
  });

  testWidgets('should neither suggest nor accept a delegate added before a partial reject', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);
    await typeAddress(tester, 'dave@domain.tld');
    await tapAdd(tester);
    await replyAdd(tester, AddDelegatesResult(
      addedUsernames: [DelegationFixtures.bobAddress],
      rejectedUsernames: const {'dave@domain.tld': null},
    ));
    container.read(myDelegatesProvider.notifier).show([
      delegate(DelegationFixtures.bobAddress),
      delegate(DelegationFixtures.carolAddress),
    ]);

    await searchContacts(tester);
    expect(suggestionQueries, ['domain']);
    expect(find.text('Bob'), findsNothing);

    await typeAddress(tester, DelegationFixtures.bobAddress);
    expect(appToast.errorMessages, [l10n.alreadyHasDelegateAccess(DelegationFixtures.bobAddress)]);
  });

  testWidgets('should show no success toast when every address is rejected', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);

    await tapAdd(tester);
    await replyAdd(tester, AddDelegatesResult(
      addedUsernames: const [],
      rejectedUsernames: const {DelegationFixtures.bobAddress: null},
    ));

    expect(appToast.successMessages, isEmpty);
    expect(find.text(l10n.someDelegatesCouldNotBeAdded), findsOneWidget);
  });

  testWidgets('should stay open with the chips and an error toast when the request fails', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);

    await tapAdd(tester);
    repository.pendingAdds.last.completeError(Exception('boom'));
    await tester.pumpAndSettle();

    expect(addedResults, isEmpty);
    expect(failedAdds, 1);
    expect(appToast.errorMessages, [l10n.couldNotAddDelegates]);
    expect(dialog(), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
    expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isTrue);
  });

  testWidgets('should leave the error to the urgent handler and not report a failed add when the request fails with an urgent error', (tester) async {
    final urgentHandler = _RecordingUrgentExceptionHandler();
    Get.put<UrgentExceptionHandler>(urgentHandler);
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);

    await tapAdd(tester);
    repository.pendingAdds.last.completeError(_UrgentError());
    await tester.pumpAndSettle();

    expect(urgentHandler.routed, hasLength(1));
    expect(failedAdds, 0);
    expect(appToast.errorMessages, isEmpty);
    expect(dialog(), findsOneWidget);
    expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isTrue);
  });

  testWidgets('should pick a tapped suggestion with its contact name and send its address on Add', (tester) async {
    await openDialog(tester);
    await searchContacts(tester);

    await tester.tap(tappableSuggestion('Bob'));
    await tester.pumpAndSettle();
    await tapAdd(tester);

    final chip = tester.widget<ContactInputTagItem>(find.byType(ContactInputTagItem));
    expect(chip.contact, EmailAddress('Bob', DelegationFixtures.bobAddress));
    expect(repository.addCalls, [
      {DelegationFixtures.bobAddress},
    ]);
    await replyAdd(tester, AddDelegatesResult(addedUsernames: [DelegationFixtures.bobAddress], rejectedUsernames: const {}));
  });

  testWidgets('should pick the highlighted suggestion on Enter', (tester) async {
    await openDialog(tester);
    await searchContacts(tester);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final chip = tester.widget<ContactInputTagItem>(find.byType(ContactInputTagItem));
    expect(chip.contact, EmailAddress('Bob', DelegationFixtures.bobAddress));
  });

  testWidgets('should not search contacts below the minimum query length', (tester) async {
    await openDialog(tester);

    await tester.enterText(addressInput(), 'do');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(suggestionQueries, isEmpty);
  });

  testWidgets('should mark an already picked suggestion and not pick it again', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);

    await searchContacts(tester);

    expect(find.text('Bob'), findsOneWidget);
    expect(tappableSuggestion('Bob'), findsNothing);
  });

  testWidgets('should remove a chip with its close icon and disable Add', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);

    await tester.tap(find.descendant(of: find.byType(Chip), matching: find.byType(SvgPicture)).last);
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNothing);
    expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isFalse);
  });

  group('a typed address not yet a chip', () {
    const daveAddress = 'dave@domain.tld';

    Future<void> typeWithoutEnter(WidgetTester tester, String address) async {
      await tester.enterText(addressInput(), address);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    testWidgets('should enable Add and be sent on it when no chip exists yet', (tester) async {
      await openDialog(tester);
      await typeWithoutEnter(tester, daveAddress);

      expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isTrue);
      await tapAdd(tester);

      expect(repository.addCalls, [
        {daveAddress},
      ]);
      await replyAdd(tester, AddDelegatesResult(addedUsernames: [daveAddress], rejectedUsernames: const {}));
    });

    testWidgets('should become a chip with the field cleared when Add fails, and be sent once on a retry', (tester) async {
      await openDialog(tester);
      await typeWithoutEnter(tester, daveAddress);

      await tapAdd(tester);
      repository.pendingAdds.last.completeError(Exception('boom'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(addressInput()).controller!.text, isEmpty);
      expect(tester.widget<ContactInputTagItem>(find.byType(ContactInputTagItem)).contact, EmailAddress(null, daveAddress));

      await tapAdd(tester);
      expect(repository.addCalls, [
        {daveAddress},
        {daveAddress},
      ]);
      await replyAdd(tester, AddDelegatesResult(addedUsernames: [daveAddress], rejectedUsernames: const {}));
    });

    testWidgets('should keep the text while typing an address that is already a chip', (tester) async {
      await openDialog(tester);
      await typeAddress(tester, daveAddress);

      await typeWithoutEnter(tester, daveAddress);

      expect(tester.widget<TextField>(addressInput()).controller!.text, daveAddress);
    });

    testWidgets('should keep Add disabled for blank text', (tester) async {
      await openDialog(tester);
      await typeWithoutEnter(tester, '   ');

      expect(isEnabled(tester, UiKeys.addDelegatesSubmitButton), isFalse);
    });

    testWidgets('should be sent on Add with the chips', (tester) async {
      await openDialog(tester);
      await typeAddress(tester, DelegationFixtures.bobAddress);
      await typeWithoutEnter(tester, daveAddress);

      await tapAdd(tester);

      expect(repository.addCalls, [
        {DelegationFixtures.bobAddress, daveAddress},
      ]);
      await replyAdd(tester, AddDelegatesResult(
        addedUsernames: [DelegationFixtures.bobAddress, daveAddress],
        rejectedUsernames: const {},
      ));
    });

    testWidgets('should send nothing, keep the text and toast the reason when refused on Add', (tester) async {
      await openDialog(tester);
      await typeAddress(tester, DelegationFixtures.bobAddress);
      await typeWithoutEnter(tester, DelegationFixtures.aliceAddress);

      await tapAdd(tester);

      expect(repository.addCalls, isEmpty);
      expect(dialog(), findsOneWidget);
      expect(appToast.errorMessages, [l10n.cannotDelegateToYourself]);
      expect(tester.widget<TextField>(addressInput()).controller!.text, DelegationFixtures.aliceAddress);
      expect(find.byType(Chip), findsOneWidget);
    });

  });

  testWidgets('should count the added delegates in the toast when several are added', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);
    await typeAddress(tester, 'dave@domain.tld');

    await tapAdd(tester);
    await replyAdd(tester, AddDelegatesResult(
      addedUsernames: [DelegationFixtures.bobAddress, 'dave@domain.tld'],
      rejectedUsernames: const {},
    ));

    expect(appToast.successMessages, [l10n.delegatesHaveBeenAdded(2)]);
    expect(dialog(), findsNothing);
  });

  testWidgets('should lay out the dialog with an 8 radius, 32 side insets and the explanation 96 below the top', (tester) async {
    await openDialog(tester);

    final surface = find.descendant(of: dialog(), matching: find.byType(Material)).first;
    final surfaceRect = tester.getRect(surface);
    final shape = tester.widget<Material>(surface).shape! as RoundedRectangleBorder;
    final titleRect = tester.getRect(find.text(l10n.delegateMailboxAccount));
    final explanationRect = tester.getRect(find.text(l10n.addDelegatesExplanation));

    expect(shape.borderRadius, BorderRadius.circular(8));
    expect(titleRect.left - surfaceRect.left, 32);
    expect(explanationRect.left - surfaceRect.left, 32);
    // 16 + 40 header row + 16, then 24 content inset.
    expect(explanationRect.top - surfaceRect.top, 96);
  });

  testWidgets('should outline the focused address field and its label in the brand blue', (tester) async {
    await openDialog(tester);
    final field = find.byKey(const ValueKey(UiKeys.addDelegatesAddressField));

    expect(tester.widget<InputDecorator>(field).isFocused, isFalse);

    await tester.tap(addressInput());
    await tester.pumpAndSettle();

    final decorator = tester.widget<InputDecorator>(field);
    expect(decorator.isFocused, isTrue);
    expect((decorator.decoration.focusedBorder! as OutlineInputBorder).borderSide.color, AppColor.primaryMain);
    expect(decorator.decoration.floatingLabelStyle!.color, AppColor.primaryMain);
  });

  testWidgets('should drop the focus outline and label colour when focus leaves the address field', (tester) async {
    await openDialog(tester);
    final field = find.byKey(const ValueKey(UiKeys.addDelegatesAddressField));
    await tester.tap(addressInput());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pumpAndSettle();

    final decorator = tester.widget<InputDecorator>(field);
    expect(decorator.isFocused, isFalse);
    expect(decorator.decoration.floatingLabelStyle!.color, AppColor.steelGrayA540);
  });

  testWidgets('should send one request on a double click on Add', (tester) async {
    await openDialog(tester);
    await typeAddress(tester, DelegationFixtures.bobAddress);
    final add = tester.getCenter(find.byKey(const ValueKey(UiKeys.addDelegatesSubmitButton)));

    await tester.tapAt(add);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tapAt(add);
    await tester.pump();

    expect(repository.addCalls, hasLength(1));
    await replyAdd(tester, AddDelegatesResult(addedUsernames: [DelegationFixtures.bobAddress], rejectedUsernames: const {}));
  });
}
