import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
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
}

Future<void> _pumpNavigationBar(
  WidgetTester tester, {
  double? leadingWidth,
}) async {
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
          searchForm: const SizedBox(key: Key('search-form')),
          settingActionTypes: const <ProfileSettingActionType>[],
          onProfileSettingActionTypeClick: (_) {},
        )
      : NavigationBarWidget(
          imagePaths: ImagePaths(),
          accountId: null,
          ownEmailAddress: 'user@example.com',
          searchForm: const SizedBox(key: Key('search-form')),
          settingActionTypes: const <ProfileSettingActionType>[],
          onProfileSettingActionTypeClick: (_) {},
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
