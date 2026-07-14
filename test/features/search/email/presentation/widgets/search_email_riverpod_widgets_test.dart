import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/riverpod_widgets/clear_search_filter_button.dart';
import 'package:tmail_ui_user/features/search/email/presentation/widgets/search_email_load_more_indicator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  late ProviderContainer container;

  Widget makeTestable(Widget child) => UncontrolledProviderScope(
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
          home: Scaffold(body: child),
        ),
      );

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('ClearSearchFilterButton', () {
    testWidgets('hides when the committed filter is not applied', (tester) async {
      await tester.pumpWidget(makeTestable(
        ClearSearchFilterButton(onClearFilter: () {}),
      ));

      expect(find.byType(TMailButtonWidget), findsNothing);
    });

    testWidgets('shows and calls clear when the committed filter is applied',
        (tester) async {
      var clearCount = 0;
      container
          .read(searchFilterProvider.notifier)
          .set(SearchEmailFilter(unread: true));

      await tester.pumpWidget(makeTestable(
        ClearSearchFilterButton(onClearFilter: () => clearCount++),
      ));
      await tester.pump();

      expect(find.byType(TMailButtonWidget), findsOneWidget);

      await tester.tap(find.byType(TMailButtonWidget));
      await tester.pump();

      expect(clearCount, 1);
    });
  });

  group('SearchEmailLoadMoreIndicator', () {
    testWidgets('hides when load-more is not waiting', (tester) async {
      await tester.pumpWidget(makeTestable(
        const SearchEmailLoadMoreIndicator(),
      ));

      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('shows when load-more is waiting', (tester) async {
      container
          .read(searchEmailPresentationProvider.notifier)
          .setSearchMoreState(SearchMoreState.waiting);

      await tester.pumpWidget(makeTestable(
        const SearchEmailLoadMoreIndicator(),
      ));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });
  });
}
