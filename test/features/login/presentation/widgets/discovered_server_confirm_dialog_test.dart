import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/discovered_server_confirm_dialog.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

const _outsideWarning =
    'This server is not part of your email domain. Continue only if your administrator told you to use it.';

void main() {
  const dialog = DiscoveredServerConfirmDialog();

  setUp(() {
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        home: Scaffold(),
      ),
    );
    await tester.pumpAndSettle();
  }

  String messageText() {
    final texts = find
        .byType(RichText)
        .evaluate()
        .map((element) => (element.widget as RichText).text.toPlainText());
    return texts.firstWhere((text) => text.contains('corp.example'));
  }

  Future<bool> ask(WidgetTester tester, {required String jmapUrl}) {
    final result = dialog.confirm(
      tester.element(find.byType(Scaffold)),
      answer: DNSLookupToGetJmapUrlSuccess(jmapUrl, email: 'bob@corp.example'),
      currentEmail: () => 'bob@corp.example',
    );
    return result;
  }

  testWidgets(
    'SHOULD warn WHEN the server is outside the email domain and continue accepts it',
    (tester) async {
      await pumpApp(tester);

      final result = ask(tester, jmapUrl: 'https://mail.attacker.example');
      await tester.pumpAndSettle();

      expect(messageText(), contains('corp.example'));
      expect(messageText(), contains('mail.attacker.example'));
      expect(messageText(), contains(_outsideWarning));

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
    },
  );

  testWidgets(
    'SHOULD show the domain and host without a warning WHEN the server is in the email domain',
    (tester) async {
      await pumpApp(tester);

      final result = ask(tester, jmapUrl: 'https://jmap.corp.example');
      await tester.pumpAndSettle();

      expect(messageText(), contains('corp.example'));
      expect(messageText(), contains('jmap.corp.example'));
      expect(messageText(), isNot(contains(_outsideWarning)));

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    },
  );

  testWidgets('SHOULD return false WHEN the user cancels', (tester) async {
    await pumpApp(tester);

    final result = ask(tester, jmapUrl: 'https://mail.attacker.example');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets(
    'SHOULD return false WHEN the dialog is dismissed without a button',
    (tester) async {
      await pumpApp(tester);

      final result = ask(tester, jmapUrl: 'https://mail.attacker.example');
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('confirm_discovered_server_dialog')),
        findsNothing,
      );
      expect(await result, isFalse);
    },
  );

  testWidgets(
    'SHOULD accept a server found over DNS-over-HTTPS without asking',
    (tester) async {
      await pumpApp(tester);

      final result = await dialog.confirm(
        tester.element(find.byType(Scaffold)),
        answer: DNSLookupToGetJmapUrlSuccess(
          'https://mail.corp.example', email: 'bob@corp.example', isEncryptedSource: true),
        currentEmail: () => 'bob@corp.example',
      );

      expect(result, isTrue);
      expect(find.byType(Dialog), findsNothing);
    },
  );

  testWidgets(
    'SHOULD refuse a DNS-over-HTTPS server WHEN the email was edited since the lookup',
    (tester) async {
      await pumpApp(tester);

      final result = await dialog.confirm(
        tester.element(find.byType(Scaffold)),
        answer: DNSLookupToGetJmapUrlSuccess(
          'https://mail.corp.example', email: 'bob@corp.example', isEncryptedSource: true),
        currentEmail: () => 'bob@other.example',
      );

      expect(result, isFalse);
      expect(find.byType(Dialog), findsNothing);
    },
  );
}
