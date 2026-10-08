import 'package:core/presentation/resources/image_paths.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/twake_pdf_previewer.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/widget_fixtures.dart';

class _PendingDeviceInfoPlugin extends DeviceInfoPlugin {
  @override
  Future<BaseDeviceInfo> get deviceInfo => Future.any([]);
}

const _urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

void main() {
  late List<String> launchedUrls;
  late List<Uri> mailtoLinks;

  Widget buildViewerLauncher({bool withMailtoAction = true}) {
    return WidgetFixtures.makeTestableWidget(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => PDFViewer(
              attachment: Attachment(blobId: Id('blobId'), name: 'file.pdf'),
              accountId: AccountFixtures.aliceAccountId,
              downloadUrl: 'https://example.com/download/{accountId}/{blobId}',
              imagePaths: ImagePaths(),
              mailtoAction: withMailtoAction ? mailtoLinks.add : null,
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );
  }

  Future<void> openViewerAndTapLink(
    WidgetTester tester,
    String link, {
    bool withMailtoAction = true,
  }) async {
    await tester.pumpWidget(
      buildViewerLauncher(withMailtoAction: withMailtoAction),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pump();

    tester
        .widget<TwakePdfPreviewer>(find.byType(TwakePdfPreviewer))
        .onLinkTap!(Uri.parse(link));
    await tester.pump(const Duration(seconds: 1));
  }

  setUp(() {
    launchedUrls = [];
    mailtoLinks = [];
    Get.put<DeviceInfoPlugin>(_PendingDeviceInfoPlugin());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_urlLauncherChannel, (call) async {
      launchedUrls.add((call.arguments as Map)['url'] as String);
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_urlLauncherChannel, null);
    Get.reset();
  });

  group('PDFViewer::onLinkTap', () {
    testWidgets(
      'Should close the viewer and open the composer\n'
      'When a mailto link is tapped and a mailto action is set',
    (tester) async {
      await openViewerAndTapLink(tester, 'mailto:alice@example.com');

      expect(find.byType(PDFViewer), findsNothing);
      expect(mailtoLinks, [Uri.parse('mailto:alice@example.com')]);
      expect(launchedUrls, isEmpty);
    });

    testWidgets(
      'Should launch the link and keep the viewer open\n'
      'When an https link is tapped',
    (tester) async {
      await openViewerAndTapLink(tester, 'https://example.com/page');

      expect(find.byType(PDFViewer), findsOneWidget);
      expect(launchedUrls, ['https://example.com/page']);
      expect(mailtoLinks, isEmpty);
    });

    testWidgets(
      'Should launch the mailto link and keep the viewer open\n'
      'When a mailto link is tapped and no mailto action is set',
    (tester) async {
      await openViewerAndTapLink(
        tester,
        'mailto:alice@example.com',
        withMailtoAction: false,
      );

      expect(find.byType(PDFViewer), findsOneWidget);
      expect(launchedUrls, ['mailto:alice@example.com']);
    });

    testWidgets(
      'Should not launch the link nor close the viewer\n'
      'When a javascript link is tapped',
    (tester) async {
      await openViewerAndTapLink(tester, 'javascript:alert(1)');

      expect(find.byType(PDFViewer), findsOneWidget);
      expect(launchedUrls, isEmpty);
      expect(mailtoLinks, isEmpty);
    });
  });
}
