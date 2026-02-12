import 'dart:async';
import 'dart:typed_data';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/twake_pdf_previewer.dart';

import '../fixtures/widget_fixtures.dart';

class _FakeDeviceInfoPlugin extends DeviceInfoPlugin {
  final Future<BaseDeviceInfo> _deviceInfoFuture;
  _FakeDeviceInfoPlugin(this._deviceInfoFuture);

  @override
  Future<BaseDeviceInfo> get deviceInfo => _deviceInfoFuture;
}

class MockDownloadAttachmentForWebInteractor extends Mock
    implements DownloadAttachmentForWebInteractor {
  @override
  Stream<dartz.Either<Failure, Success>> execute(
    DownloadTaskId? taskId,
    Attachment? attachment,
    AccountId? accountId,
    String? baseDownloadUrl, {
    StreamController<dartz.Either<Failure, Success>>? onReceiveController,
    dynamic cancelToken,
    bool previewerSupported = false,
    dynamic sourceView,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #execute,
        [taskId, attachment, accountId, baseDownloadUrl],
        {
          #onReceiveController: onReceiveController,
          #cancelToken: cancelToken,
          #previewerSupported: previewerSupported,
          #sourceView: sourceView,
        },
      ),
      returnValue: const Stream<dartz.Either<Failure, Success>>.empty(),
    ) as Stream<dartz.Either<Failure, Success>>;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('PDFViewer does not copy downloaded bytes on rebuild',
      (tester) async {
    final mockInteractor = MockDownloadAttachmentForWebInteractor();

    // Keep the FutureBuilder pending; PDFViewer should still render and update
    // based on the download stream.
    final fakeDeviceInfoPlugin =
        _FakeDeviceInfoPlugin(Completer<BaseDeviceInfo>().future);

    final attachment = Attachment(
      blobId: Id('blob-1'),
      name: 'a.pdf',
    );
    final accountId = AccountId(Id('acc-1'));
    final downloadedBytes = Uint8List.fromList(List<int>.generate(32, (i) => i));

    when(mockInteractor.execute(
      any,
      any,
      any,
      any,
      onReceiveController: anyNamed('onReceiveController'),
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) {
      return Stream<dartz.Either<Failure, Success>>.fromIterable([
        dartz.Right<Failure, Success>(
          StartDownloadAttachmentForWeb(
            DownloadTaskId('task-1'),
            attachment,
          ),
        ),
        dartz.Right<Failure, Success>(
          DownloadAttachmentForWebSuccess(
            DownloadTaskId('task-1'),
            attachment,
            downloadedBytes,
            true,
            null,
          ),
        ),
      ]);
    });

    Get.put<DeviceInfoPlugin>(fakeDeviceInfoPlugin);
    Get.put<DownloadAttachmentForWebInteractor>(mockInteractor);

    await tester.pumpWidget(
      WidgetFixtures.makeTestableWidget(
        child: PDFViewer(
          attachment: attachment,
          accountId: accountId,
          downloadUrl: 'https://example.invalid/download',
        ),
      ),
    );

    // Let initState subscriptions run and stream events be processed.
    await tester.pump();
    await tester.pump();

    final previewer =
        tester.widget<TwakePdfPreviewer>(find.byType(TwakePdfPreviewer));
    expect(identical(previewer.bytes, downloadedBytes), isTrue);

    // Rebuild again; bytes should still be the same instance (no cloning).
    await tester.pump();
    final previewer2 =
        tester.widget<TwakePdfPreviewer>(find.byType(TwakePdfPreviewer));
    expect(identical(previewer2.bytes, downloadedBytes), isTrue);
  });
}
