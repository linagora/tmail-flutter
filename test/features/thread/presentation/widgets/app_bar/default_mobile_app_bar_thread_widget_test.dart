import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/compact_account_switcher.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/default_mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

import '../../../../../fixtures/delegation_fixtures.dart';

void main() {
  Future<void> pumpAppBar(
    WidgetTester tester, {
    required bool isWeb,
    bool insideCozy = false,
  }) async {
    PlatformInfo.isTestingForWeb = isWeb;
    addTearDown(() => PlatformInfo.isTestingForWeb = false);

    final container = ProviderContainer(
      overrides: [insideCozyProvider.overrideWith((ref) async => insideCozy)],
    );
    addTearDown(container.dispose);
    container.read(activeAccountProvider.notifier)
      ..applySession(DelegationFixtures.session())
      ..select(DelegationFixtures.bobAccountId);
    DelegationFixtures.turnDelegationOn(container);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizationsDelegate()],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(
          body: DefaultMobileAppBarThreadWidget(
            responsiveUtils: ResponsiveUtils(),
            imagePaths: ImagePaths(),
            mailboxSelected: null,
            filterOption: FilterMessageOption.all,
            openMailboxAction: () {},
          ),
        ),
      ),
    ));
    // insideCozyProvider resolves after the first frame.
    await tester.pump();
    await tester.pump();
  }

  group('DefaultMobileAppBarThreadWidget', () {
    for (final isWeb in [false, true]) {
      testWidgets(
        'SHOULD show the compact account switcher on ${isWeb ? 'web' : 'the Android and iOS app'} '
        'while a delegated mailbox is shown',
      (tester) async {
        await pumpAppBar(tester, isWeb: isWeb);

        expect(find.byKey(CompactAccountSwitcher.switcherKey), findsOneWidget);
      });
    }

    testWidgets('SHOULD NOT show the compact account switcher inside Twake Workplace', (tester) async {
      await pumpAppBar(tester, isWeb: true, insideCozy: true);

      expect(find.byKey(CompactAccountSwitcher.switcherKey), findsNothing);
    });
  });
}
