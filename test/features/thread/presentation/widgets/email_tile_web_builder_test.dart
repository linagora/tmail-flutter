import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

void main() {
  setUpAll(() {
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
  });

  group('EmailTileBuilder test:', () {
    testWidgets(
      'Should display checkbox image '
      'and InkWell with hover color AppColor.colorEmailTileHoverWeb '
      'when app is running in desktop layout',
    (tester) async {
      // arrange
      final widgetUnderTest = EmailTileBuilder(
        presentationEmail: PresentationEmail(),
        selectAllMode: SelectMode.INACTIVE,
        isShowingEmailContent: false,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final dpi = tester.view.devicePixelRatio;
      tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

      // act
      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate],
          supportedLocales: LocalizationService.supportedLocales,
          home: Scaffold(body: widgetUnderTest)));
      await tester.pump();

      BuildContext context = tester.element(find.byType(EmailTileBuilder));

      // assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SvgPicture 
            && widget.bytesLoader is SvgAssetLoader
            && (widget.bytesLoader as SvgAssetLoader).assetName == ImagePaths().icCheckboxUnselected
        ),
        findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is InkWell
            && widget.hoverColor == Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)
        ),
        findsOneWidget);

      // clean up
      debugDefaultTargetPlatformOverride = null;
      tester.view.reset();
    });

    testWidgets(
      'Should not display any checkbox image '
      'and InkWell with hover color AppColor.colorEmailTileHoverWeb '
      'when app is not running in desktop layout',
    (tester) async {
      // arrange
      final widgetUnderTest = EmailTileBuilder(
        presentationEmail: PresentationEmail(),
        selectAllMode: SelectMode.INACTIVE,
        isShowingEmailContent: false,
      );

      // act
      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate],
          supportedLocales: LocalizationService.supportedLocales,
          home: Scaffold(body: widgetUnderTest)));
      await tester.pump();

      BuildContext context = tester.element(find.byType(EmailTileBuilder));
      // assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SvgPicture 
            && widget.bytesLoader is SvgAssetLoader
            && (widget.bytesLoader as SvgAssetLoader).assetName == ImagePaths().icCheckboxUnselected
        ),
        findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is InkWell
            && widget.hoverColor == Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)
        ),
        findsOneWidget);
    });

    testWidgets(
      'Should display icRead image '
      'when app is running in desktop layout '
      'and email is unread '
      'and widget is hovered',
    (tester) async {
      // arrange
      final widgetUnderTest = EmailTileBuilder(
        presentationEmail: PresentationEmail(),
        selectAllMode: SelectMode.INACTIVE,
        isShowingEmailContent: false,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final dpi = tester.view.devicePixelRatio;
      tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);

      // act
      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate],
          supportedLocales: LocalizationService.supportedLocales,
          home: Scaffold(body: widgetUnderTest)));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(EmailTileBuilder)));
      await tester.pump();

      // assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SvgPicture 
            && widget.bytesLoader is SvgAssetLoader
            && (widget.bytesLoader as SvgAssetLoader).assetName == ImagePaths().icRead
        ),
        findsOneWidget);

      // clean up
      debugDefaultTargetPlatformOverride = null;
      tester.view.reset();
      gesture.removePointer();
    });

    testWidgets(
      'Should display icUnread image '
      'when app is running in desktop layout '
      'and email is read '
      'and widget is hovered',
    (tester) async {
      // arrange
      final widgetUnderTest = EmailTileBuilder(
        presentationEmail: PresentationEmail(keywords: {KeyWordIdentifier.emailSeen: true}),
        selectAllMode: SelectMode.INACTIVE,
        isShowingEmailContent: false,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final dpi = tester.view.devicePixelRatio;
      tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);

      // act
      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate],
          supportedLocales: LocalizationService.supportedLocales,
          home: Scaffold(body: widgetUnderTest)));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(EmailTileBuilder)));
      await tester.pump();

      // assert
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SvgPicture 
            && widget.bytesLoader is SvgAssetLoader
            && (widget.bytesLoader as SvgAssetLoader).assetName == ImagePaths().icUnread
        ),
        findsOneWidget);

      // clean up
      debugDefaultTargetPlatformOverride = null;
      tester.view.reset();
      gesture.removePointer();
    });
  });
}