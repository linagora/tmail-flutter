import 'dart:async';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/password_aware_pdf_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:twake_previewer_flutter/core/widgets/top_bar_widget.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/widget_fixtures.dart';

class _FakeDeviceInfoPlugin implements DeviceInfoPlugin {
  @override
  Future<BaseDeviceInfo> get deviceInfo => Completer<BaseDeviceInfo>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadAttachmentForWebInteractor
    implements DownloadAttachmentForWebInteractor {
  @override
  Stream<Either<Failure, Success>> execute(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
    bool previewerSupported = false,
    DownloadSourceView? sourceView,
  }) =>
      Stream.value(Right(DownloadAttachmentForWebSuccess(
        taskId,
        attachment,
        Uint8List.fromList([1, 2, 3]),
        true,
        null,
      )));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

void main() {
  final attachment = Attachment(
    blobId: Id('blob-id'),
    name: 'report.pdf',
  );

  late AppLocalizations appLocalizations;

  setUp(() {
    Get.put<DeviceInfoPlugin>(_FakeDeviceInfoPlugin());
    Get.put<DownloadAttachmentForWebInteractor>(
      _FakeDownloadAttachmentForWebInteractor(),
    );
  });

  tearDown(Get.reset);

  const homePageText = 'Home page';

  Future<void> pumpViewer(WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: Text(homePageText)),
      ),
    );
    await tester.pump();
    Navigator.of(tester.element(find.text(homePageText))).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: PDFViewer(
            attachment: attachment,
            accountId: AccountId(Id('account-id')),
            downloadUrl: 'https://example.com/download',
            imagePaths: ImagePaths(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    appLocalizations = AppLocalizations.of(
      tester.element(find.byType(PDFViewer)),
    );
  }

  Future<PdfViewer> pumpPdfViewer(WidgetTester tester) async {
    await pumpViewer(tester);
    return tester.widget<PdfViewer>(find.byType(PdfViewer));
  }

  Future<String?> enterPassword(
    WidgetTester tester,
    FutureOr<String?> passwordRequest,
    String password,
  ) async {
    await tester.enterText(find.byType(TextField), password);
    await tester.tap(find.text(appLocalizations.open));
    await tester.pumpAndSettle();
    return passwordRequest;
  }

  group('PDFViewer password prompt', () {
    testWidgets(
      'should forward a password provider to the pdf viewer document',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);

        expect(pdfViewer.documentRef.passwordProvider, isNotNull);
        expect(pdfViewer.documentRef.firstAttemptByEmptyPassword, isTrue);
        expect(pdfViewer.documentRef.sourceName, 'report.pdf');
      },
    );

    testWidgets(
      'should keep the upstream previewer settings on the pdf viewer',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);

        expect(pdfViewer.controller, isNotNull);
        expect(pdfViewer.params.panAxis, PanAxis.vertical);
        expect(pdfViewer.params.minScale, 1);
        expect(pdfViewer.params.maxScale, 4);
        expect(pdfViewer.params.layoutPages, isNotNull);
        expect(pdfViewer.params.onViewerReady, isNotNull);
        expect(pdfViewer.params.errorBannerBuilder, isNotNull);
      },
    );

    testWidgets(
      'should ask for the password without an error on the first prompt',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);

        final passwordRequest = pdfViewer.documentRef.passwordProvider!();
        await tester.pumpAndSettle();

        final dialog = tester.widget<EditTextDialogBuilder>(
          find.byType(EditTextDialogBuilder),
        );
        expect(dialog.title, appLocalizations.pdfPasswordRequired);
        expect(dialog.obscureText, isTrue);
        expect(dialog.initialError, isNull);
        expect(find.text(appLocalizations.incorrectPdfPassword), findsNothing);

        expect(await enterPassword(tester, passwordRequest, 'secret'), 'secret');
        expect(find.byType(EditTextDialogBuilder), findsNothing);
      },
    );

    testWidgets(
      'should show the incorrect password error on every prompt after the first',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);
        final passwordProvider = pdfViewer.documentRef.passwordProvider!;

        final firstRequest = passwordProvider();
        await tester.pumpAndSettle();
        await enterPassword(tester, firstRequest, 'wrong');

        for (final password in ['still-wrong', 'secret']) {
          final retryRequest = passwordProvider();
          await tester.pumpAndSettle();

          expect(find.text(appLocalizations.incorrectPdfPassword), findsOneWidget);
          expect(await enterPassword(tester, retryRequest, password), password);
        }
      },
    );

    testWidgets(
      'should return no password when the prompt is cancelled',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);

        final passwordRequest = pdfViewer.documentRef.passwordProvider!();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'typed');
        await tester.tap(find.text(appLocalizations.cancel));
        await tester.pumpAndSettle();

        expect(await passwordRequest, isNull);
        expect(find.byType(EditTextDialogBuilder), findsNothing);
      },
    );

    testWidgets(
      'should not close the prompt when tapping outside of it',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);

        pdfViewer.documentRef.passwordProvider!();
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();

        expect(find.byType(EditTextDialogBuilder), findsOneWidget);
      },
    );
  });

  group('PDFViewer top bar', () {
    testWidgets(
      'should offer download and print once the pdf is downloaded',
      (tester) async {
        await pumpViewer(tester);

        final topBar = tester.widget<TopBarWidget>(find.byType(TopBarWidget));
        expect(topBar.title, 'report.pdf');
        expect(topBar.downloadAction, isNotNull);
        expect(topBar.closeAction, isNotNull);
      },
    );

    testWidgets(
      'should only offer close when the pdf could not be downloaded',
      (tester) async {
        Get.delete<DownloadAttachmentForWebInteractor>();
        await pumpViewer(tester);

        final topBar = tester.widget<TopBarWidget>(find.byType(TopBarWidget));
        expect(find.byType(PdfViewer), findsNothing);
        expect(topBar.title, isEmpty);
        expect(topBar.downloadAction, isNull);
        expect(topBar.printAction, isNull);
        expect(topBar.closeAction, isNotNull);
      },
    );

    testWidgets('should close the viewer on Escape', (tester) async {
      await pumpViewer(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(PDFViewer), findsNothing);
      expect(find.text(homePageText), findsOneWidget);
    });
  });

  group('PDFViewer disposed', () {
    testWidgets(
      'should return no password without a prompt once the viewer is closed',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);
        final passwordProvider = pdfViewer.documentRef.passwordProvider!;

        await tester.pumpWidget(const SizedBox.shrink());
        final password = await passwordProvider();
        await tester.pump();

        expect(password, isNull);
        expect(find.byType(EditTextDialogBuilder), findsNothing);
      },
    );
  });

  group('PDFViewer error banner', () {
    ConfirmationDialogBuilder buildErrorBanner(
      WidgetTester tester,
      PdfViewer pdfViewer,
      Object error,
    ) =>
        pdfViewer.params.errorBannerBuilder!(
          tester.element(find.byType(PdfViewer)),
          error,
          null,
          pdfViewer.documentRef,
        ) as ConfirmationDialogBuilder;

    testWidgets(
      'should say the pdf is password-protected when no password is supplied',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);

        final banner = buildErrorBanner(
          tester,
          pdfViewer,
          const PdfPasswordException('No password supplied by PasswordProvider.'),
        );

        expect(banner.title, appLocalizations.cannotPreviewPdf);
        expect(banner.textContent, appLocalizations.pdfPasswordNotProvided);
      },
    );

    testWidgets(
      'should show the error itself for any other load failure',
      (tester) async {
        final pdfViewer = await pumpPdfViewer(tester);
        const error = PdfException('Failed to load PDF document');

        final banner = buildErrorBanner(tester, pdfViewer, error);

        expect(banner.textContent, error.toString());
      },
    );
  });

  group('PDFViewer::onLinkTap', () {
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
          .widget<PasswordAwarePdfPreviewer>(find.byType(PasswordAwarePdfPreviewer))
          .onLinkTap!(Uri.parse(link));
      await tester.pump(const Duration(seconds: 1));
    }

    setUp(() {
      launchedUrls = [];
      mailtoLinks = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_urlLauncherChannel, (call) async {
        launchedUrls.add((call.arguments as Map)['url'] as String);
        return true;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_urlLauncherChannel, null);
    });

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

    testWidgets(
      'Should launch the link\n'
      'When pdfrx reports a tap on a link of the password-aware document',
    (tester) async {
      await tester.pumpWidget(buildViewerLauncher());
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      tester
          .widget<PdfViewer>(find.byType(PdfViewer))
          .params
          .linkHandlerParams!
          .onLinkTap(PdfLink(const [], url: Uri.parse('https://example.com/page')));
      await tester.pump(const Duration(seconds: 1));

      expect(launchedUrls, ['https://example.com/page']);
    });
  });
}
