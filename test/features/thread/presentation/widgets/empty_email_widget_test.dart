import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  group('EmptyEmailsWidget::widgetTest', () {
    final responsiveUtils = ResponsiveUtils();
    final imagePaths = ImagePaths();

    setUp(() {
      Get.put<ResponsiveUtils>(responsiveUtils);
      Get.put<ImagePaths>(imagePaths);

      Get.testMode = true;
    });

    Widget makeTestableWidget({required Widget child}) {
      return GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(body: child),
      );
    }

    testWidgets(
      'should have CreateRuleFilter button and message correctly\n'
      'when search inactive and filter inactive',
    (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isSearchActive: false,
          isFilterMessageActive: false,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('empty_email_sub_message')),
        findsOneWidget);

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'You don’t have any emails\n in this folder.');
    });

    testWidgets(
      'should have message correctly and do not have CreateRuleFilter button\n'
      'when search inactive and filter active',
    (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isSearchActive: false,
          isFilterMessageActive: true,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('empty_email_sub_message')),
        findsNothing);

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'We\'re sorry, there are no emails that match your current filter.');
    });

    testWidgets(
      'should have message correctly and do not have CreateRuleFilter button\n'
      'when search active',
    (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isSearchActive: true,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('empty_email_sub_message')),
        findsNothing);

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'No emails are matching your search');
    });

    testWidgets(
      'should have message correctly and do not have CreateRuleFilter button\n'
      'when no network', (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isNetworkConnectionAvailable: false,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('empty_email_sub_message')),
        findsNothing);

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'No internet connection, try again later.');
    });

    testWidgets(
      'should have message correctly and do not have CreateRuleFilter button\n'
      'when no network, but search are still active', (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isNetworkConnectionAvailable: false,
          isSearchActive: true,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('empty_email_sub_message')),
        findsNothing);

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'No internet connection, try again later.');
    });

    testWidgets(
      'should have message correctly and do not have CreateRuleFilter button\n'
      'when no network, but filter are still active', (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isNetworkConnectionAvailable: false,
          isFilterMessageActive: true,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('empty_email_sub_message')),
        findsNothing);

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'No internet connection, try again later.');
    });

    testWidgets(
      'should have message correctly and do not have CreateRuleFilter button\n'
      'when no network, but filter and search are still active', (tester) async {
      final widget = makeTestableWidget(
        child: EmptyEmailsWidget(
          isNetworkConnectionAvailable: false,
          isFilterMessageActive: true,
        ),
      );

      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      final emptyEmailMessageWidgetFinder = find.byKey(const Key('empty_email_message'));
      final emptyEmailMessageWidget = tester.widget<Text>(emptyEmailMessageWidgetFinder);
      expect(
        emptyEmailMessageWidget.data,
        'No internet connection, try again later.');
    });
  });
}
