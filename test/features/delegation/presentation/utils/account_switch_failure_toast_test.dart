import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../fixtures/recording_app_toast.dart';

void main() {
  late RecordingAppToast appToast;

  setUp(() {
    appToast = RecordingAppToast();
  });

  Future<BuildContext> pumpWithContext(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [AppLocalizationsDelegate()],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Builder(builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        }),
      ),
    );
    await tester.pump();
    return captured;
  }

  group('showAccountSwitchFailureToast', () {
    for (final result in <AccountSwitchResult>[
      AccountSwitchFailed(Exception('load'), StackTrace.current),
      const AccountSwitchCancelled(),
      const AccountSwitchTimedOut(),
    ]) {
      testWidgets('toasts Could not open for ${result.runtimeType}',
          (tester) async {
        final context = await pumpWithContext(tester);
        showAccountSwitchFailureToast(
          context: context,
          appToast: appToast.toast,
          args: AccountSwitchFailureToastArgs(
            result: result,
            ownerDisplayName: 'bob@domain.tld',
          ),
        );

        expect(
          appToast.errorMessages,
          [
            AppLocalizations.of(context)
                .couldNotOpenOwnerMailbox('bob@domain.tld'),
          ],
        );
      });

      testWidgets(
          'toasts return-to-mine copy for ${result.runtimeType}',
          (tester) async {
        final context = await pumpWithContext(tester);
        showAccountSwitchFailureToast(
          context: context,
          appToast: appToast.toast,
          args: AccountSwitchFailureToastArgs(
            result: result,
            ownerDisplayName: 'alice@domain.tld',
            returningToMine: true,
          ),
        );

        expect(
          appToast.errorMessages,
          [AppLocalizations.of(context).couldNotReturnToYourMailbox],
        );
        expect(
          appToast.errorMessages.single,
          isNot(contains("alice@domain.tld's mailbox")),
        );
      });
    }

    testWidgets('toasts close-composer copy when composer is open',
        (tester) async {
      final context = await pumpWithContext(tester);
      showAccountSwitchFailureToast(
        context: context,
        appToast: appToast.toast,
        args: const AccountSwitchFailureToastArgs(
          result: AccountSwitchRefused(AccountSwitchRefusal.composerOpen),
          ownerDisplayName: 'bob@domain.tld',
        ),
      );

      expect(
        appToast.errorMessages,
        [AppLocalizations.of(context).closeComposerBeforeSwitchingAccounts],
      );
    });

    for (final result in <AccountSwitchResult>[
      const AccountSwitched(),
      const AccountSwitchRefused(AccountSwitchRefusal.accountAlreadyShown),
      const AccountSwitchRefused(AccountSwitchRefusal.switchInProgress),
      const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed),
    ]) {
      testWidgets('stays silent for $result', (tester) async {
        final context = await pumpWithContext(tester);
        showAccountSwitchFailureToast(
          context: context,
          appToast: appToast.toast,
          args: AccountSwitchFailureToastArgs(
            result: result,
            ownerDisplayName: 'bob@domain.tld',
          ),
        );

        expect(appToast.errorMessages, isEmpty);
      });
    }
  });
}
