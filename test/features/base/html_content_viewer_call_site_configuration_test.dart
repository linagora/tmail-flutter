import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_body_content_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/html_attachment_previewer.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_dialog_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/signature_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import 'fake_inappwebview_platform.dart';

/// TF-4799 replaced the flat `HtmlContentViewer` parameters with a nested
/// configuration object and rewrote every call site. Nothing else in the suite
/// touches these views, so these tests pin the values each view asks for
/// against the flat arguments it passed before the migration. A silently wrong
/// mapping (a dropped padding, a min height that reverts to the default) is
/// invisible to the compiler and would only show up as a visual defect.
///
/// Not covered here: `EmailView`, which needs a live `SingleEmailController`.
/// It stays on manual verification.
void main() {
  setUp(() {
    FakeInAppWebViewPlatform.install();
    Get.testMode = true;
    Get.put(ImagePaths());
    Get.put(ResponsiveUtils());
  });

  tearDown(Get.reset);

  group('SignatureBuilder', () {
    testWidgets(
      'keeps the zeroed heights, padding and locked scrolling',
      verifySignatureBuilderLayout,
    );
    testWidgets(
      'never opts in to the mobile responsive layout',
      verifySignatureBuilderSkipsResponsiveLayout,
    );
  });

  group('EmailPreviewerDialogView', () {
    testWidgets(
      'keeps the default font style and all three url delegates',
      verifyEmailPreviewerDialogDelegates,
    );
  });

  group('HtmlAttachmentPreviewer', () {
    testWidgets(
      'keeps the width while loading and the plain font style',
      verifyHtmlAttachmentPreviewerConfiguration,
    );
  });

  group('EventBodyContentWidget', () {
    testWidgets(
      'leaves the content height uncapped on android',
      verifyEventBodyHeightCapOnAndroid,
    );
    testWidgets(
      'caps the content height on ios',
      verifyEventBodyHeightCapOnIOS,
    );
  });
}

Future<HtmlContentViewer> pumpAndFindViewer(
  WidgetTester tester,
  Widget child,
) async {
  // `TopBarAttachmentViewer` reads `AppLocalizations`, so the delegates are
  // part of the harness rather than optional decoration.
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Scaffold(body: child),
  ));
  await tester.pump();

  // `FakeInAppWebViewPlatform` lets the viewer build, so nothing here is
  // expected to throw. Swallowing exceptions instead would hide a real build
  // or layout regression in the view under test.
  expect(tester.takeException(), isNull);

  final viewers = find.byType(HtmlContentViewer);
  expect(viewers, findsOneWidget);

  return tester.widget<HtmlContentViewer>(viewers);
}

Future<void> verifySignatureBuilderLayout(WidgetTester tester) async {
  final viewer = await pumpAndFindViewer(
    tester,
    const SignatureBuilder(
      value: '<p>Signature</p>',
      width: 280,
      height: 150,
    ),
  );

  expect(viewer.contentHtml, '<p>Signature</p>');
  expect(viewer.initialWidth, 280);
  expect(viewer.maxViewHeight, 150);
  expect(viewer.contentPadding, 0);
  // A default of 150 here would push the signature preview off its box.
  expect(viewer.htmlContentMinHeight, 0);
  expect(viewer.offsetHtmlContentHeight, 0);
  expect(viewer.keepAlive, isTrue);
  expect(viewer.disableScrolling, isTrue);
  expect(viewer.maxHtmlContentHeight, isNull);
  expect(viewer.useDefaultFontStyle, isFalse);
  expect(viewer.enableQuoteToggle, isFalse);
  expect(viewer.keepWidthWhileLoading, isFalse);
  expect(viewer.fontSize, 16);
}

Future<void> verifySignatureBuilderSkipsResponsiveLayout(
  WidgetTester tester,
) async {
  final viewer = await pumpAndFindViewer(
    tester,
    const SignatureBuilder(value: '<p>Signature</p>'),
  );

  expect(
    viewer.configuration.behavior.has(
      HtmlContentViewerFeature.mobileResponsiveLayout,
    ),
    isFalse,
    reason: 'the signature preview must not ask for the reflow at all',
  );
}

Future<void> verifyEmailPreviewerDialogDelegates(WidgetTester tester) async {
  var mailto = 0;
  var previewEml = 0;
  var download = 0;

  final viewer = await pumpAndFindViewer(
    tester,
    EmailPreviewerDialogView(
      emlPreviewer: EMLPreviewer(
        id: 'eml-1',
        title: 'forward.eml',
        content: '<p>Forwarded</p>',
      ),
      imagePaths: ImagePaths(),
      onMailtoDelegateAction: (_) async => mailto++,
      onPreviewEMLDelegateAction: (_) async => previewEml++,
      onDownloadAttachmentDelegateAction: (_) async => download++,
    ),
  );

  expect(viewer.contentHtml, '<p>Forwarded</p>');
  expect(viewer.useDefaultFontStyle, isTrue);
  expect(viewer.initialWidth, isNotNull);
  expect(viewer.htmlContentMinHeight, ConstantsUI.htmlContentMinHeight);
  expect(viewer.offsetHtmlContentHeight, ConstantsUI.htmlContentOffsetHeight);
  expect(viewer.disableScrolling, isFalse);
  expect(viewer.keepAlive, isFalse);

  // Each delegate must reach a distinct callback, not share one slot.
  await viewer.onMailtoDelegateAction!(null);
  await viewer.onPreviewEMLDelegateAction!(null);
  await viewer.onDownloadAttachmentDelegateAction!(null);
  expect([mailto, previewEml, download], [1, 1, 1]);
}

Future<void> verifyHtmlAttachmentPreviewerConfiguration(
  WidgetTester tester,
) async {
  var mailto = 0;

  final viewer = await pumpAndFindViewer(
    tester,
    HtmlAttachmentPreviewer(
      title: 'invoice.html',
      htmlContent: '<p>Invoice</p>',
      mailToClicked: (_) => mailto++,
      downloadAttachmentClicked: () {},
      responsiveUtils: ResponsiveUtils(),
    ),
  );

  expect(viewer.contentHtml, '<p>Invoice</p>');
  expect(viewer.keepWidthWhileLoading, isTrue);
  expect(viewer.initialWidth, isNotNull);
  // The attachment previewer never used the default font style.
  expect(viewer.useDefaultFontStyle, isFalse);
  expect(viewer.enableQuoteToggle, isFalse);
  expect(viewer.contentPadding, isNull);

  await viewer.onMailtoDelegateAction!(null);
  expect(mailto, 1);
}

Future<void> verifyEventBodyHeightCapOnAndroid(WidgetTester tester) =>
    _verifyEventBodyHeightCap(
      tester,
      platform: TargetPlatform.android,
      expectedMaxContentHeight: isNull,
    );

Future<void> verifyEventBodyHeightCapOnIOS(WidgetTester tester) =>
    _verifyEventBodyHeightCap(
      tester,
      platform: TargetPlatform.iOS,
      expectedMaxContentHeight: ConstantsUI.htmlContentMaxHeight,
    );

/// The cap is the only value that moves with the platform, so both cases share
/// one arrangement and differ by the expected height alone.
Future<void> _verifyEventBodyHeightCap(
  WidgetTester tester, {
  required TargetPlatform platform,
  required Object? expectedMaxContentHeight,
}) async {
  // The binding asserts every foundation debug variable is reset before the
  // test body returns, so the override cannot be undone in a tear down.
  final HtmlContentViewer viewer;
  debugDefaultTargetPlatformOverride = platform;
  try {
    viewer = await pumpAndFindViewer(
      tester,
      const EventBodyContentWidget(content: '<p>Invitation</p>'),
    );
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }

  expect(viewer.contentHtml, '<p>Invitation</p>');
  expect(viewer.useDefaultFontStyle, isTrue);
  expect(viewer.initialWidth, isNotNull);
  expect(viewer.htmlContentMinHeight, ConstantsUI.htmlContentMinHeight);
  expect(viewer.maxHtmlContentHeight, expectedMaxContentHeight);
}
