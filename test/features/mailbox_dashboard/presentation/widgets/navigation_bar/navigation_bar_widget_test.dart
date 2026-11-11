import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  testWidgets('aligns the search form with the supplied sidebar width',
      (tester) async {
    await _pumpNavigationBar(
      tester,
      leadingWidth: ResponsiveUtils.sidebarMenuWidth,
    );

    expect(
      tester.getTopLeft(find.byKey(const Key('search-form'))).dx,
      ResponsiveUtils.sidebarMenuWidth,
    );
  });

  testWidgets('keeps the existing leading width by default', (tester) async {
    await _pumpNavigationBar(tester);

    expect(
      tester.getTopLeft(find.byKey(const Key('search-form'))).dx,
      ResponsiveUtils.defaultSizeMenu,
    );
  });

  for (final withSearchForm in [true, false]) {
    final layout = withSearchForm ? 'with' : 'without';

    testWidgets('shows the supplied profile menu in place of the profile icon $layout a search form',
        (tester) async {
      await _pumpNavigationBar(
        tester,
        withSearchForm: withSearchForm,
        profileMenu: const SizedBox(key: Key('profile-menu')),
      );

      expect(find.byKey(const Key('profile-menu')), findsOneWidget);
      expect(find.byType(ProfileSettingIcon), findsNothing);
    });

    testWidgets('keeps the profile icon when no profile menu is supplied $layout a search form',
        (tester) async {
      await _pumpNavigationBar(tester, withSearchForm: withSearchForm);

      expect(find.byType(ProfileSettingIcon), findsOneWidget);
    });
  }
}

Future<void> _pumpNavigationBar(
  WidgetTester tester, {
  double? leadingWidth,
  bool withSearchForm = true,
  Widget? profileMenu,
}) async {
  const searchForm = SizedBox(key: Key('search-form'));
  Get.put<ImagePaths>(ImagePaths());
  addTearDown(Get.reset);
  final dpi = tester.view.devicePixelRatio;
  tester.view.physicalSize = Size(1440 * dpi, 800 * dpi);
  addTearDown(tester.view.resetPhysicalSize);

  final navigationBar = leadingWidth == null
      ? NavigationBarWidget(
          imagePaths: ImagePaths(),
          accountId: null,
          ownEmailAddress: 'user@example.com',
          searchForm: withSearchForm ? searchForm : null,
          settingActionTypes: const <ProfileSettingActionType>[],
          onProfileSettingActionTypeClick: (_) {},
          profileMenu: profileMenu,
        )
      : NavigationBarWidget(
          imagePaths: ImagePaths(),
          accountId: null,
          ownEmailAddress: 'user@example.com',
          searchForm: withSearchForm ? searchForm : null,
          settingActionTypes: const <ProfileSettingActionType>[],
          onProfileSettingActionTypeClick: (_) {},
          profileMenu: profileMenu,
          leadingWidth: leadingWidth,
        );

  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Portal(
      child: Scaffold(
        body: navigationBar,
      ),
    ),
  ));
  await tester.pump();
}
