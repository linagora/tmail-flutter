import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:delegation/model/delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/my_delegates_section.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final bob = Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress);
  final carol = Delegate(id: Id('carol-delegate'), username: DelegationFixtures.carolAddress);
  final l10n = AppLocalizations();
  const emptyCard = ValueKey(UiKeys.myDelegatesEmptyCard);
  const list = ValueKey(UiKeys.myDelegatesList);
  const addButton = ValueKey(UiKeys.myDelegatesAddButton);

  late ProviderContainer container;
  late FakeDelegateRepository repository;

  setUp(() {
    repository = FakeDelegateRepository();
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
    ]);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

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

  testWidgets('should show a disabled add button inside the empty card when no one has access', (tester) async {
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
    expect(button.onPressed, isNull);
  });

  testWidgets('should list every delegate without a row action and a disabled add button below', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bob, carol]);

    expect(find.byKey(list), findsOneWidget);
    expect(find.byKey(emptyCard), findsNothing);
    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
    expect(find.text(DelegationFixtures.carolAddress), findsOneWidget);
    for (final tile in tester.widgetList<LinagoraPersonTile>(find.byType(LinagoraPersonTile))) {
      expect(tile.action, isNull);
    }
    expect(tester.widget<LinagoraButton>(find.byKey(addButton)).onPressed, isNull);
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
}
