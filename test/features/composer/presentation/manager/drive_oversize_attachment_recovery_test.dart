import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio show Response;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_oversize_attachment_recovery.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_oversize_uploader_provider.dart';

import '../../../../fixtures/widget_fixtures.dart';
import 'package:workplace/domain/entity/drive_uploaded_file.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_request_context.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/entity/workplace_upload_transfer.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/domain/usecase/upload_drive_file_interactor.dart';
import 'package:workplace/data/transport/workplace_access_mode_runner.dart';

final _platformUrl = Uri.parse('https://platform.example.com');
const _failure = MaxEmailAttachmentSizeExceeded(1000);

// One outcome per fileName: a Uri (success), a String (upload fails), or a
// _Failure mirroring a real transport outcome.
enum _Failure { cancelled, uploadConflict, shareLinkForbidden }

DioException _httpError(int statusCode) => DioException(
      requestOptions: RequestOptions(path: ''),
      response: dio.Response(requestOptions: RequestOptions(path: ''), statusCode: statusCode),
      type: DioExceptionType.badResponse,
    );

/// The in-flight dialog reads only the attachment size limit from it.
class _FakeDashboardController extends Fake implements MailboxDashBoardController {
  @override
  InternalFinalCallback<void> get onStart => InternalFinalCallback<void>(callback: () {});

  @override
  InternalFinalCallback<void> get onDelete => InternalFinalCallback<void>(callback: () {});

  @override
  UnsignedInt? get maxSizeAttachmentsPerEmail => null;
}

class _FakeWorkplaceRepository implements WorkplaceRepository {
  final Map<String, dynamic> outcomesByFileName;
  /// When true every uploadFile call throws, simulating a runner-level
  /// failure that never reaches a per-file try/catch.
  final bool failEveryUpload;

  /// Every spec seen by [uploadFile], so a test can assert what reaches the wire.
  final capturedSpecs = <WorkplaceUploadFileSpec>[];

  /// Every transfer seen by [uploadFile], so a test can assert the cancel wiring.
  final capturedTransfers = <WorkplaceUploadTransfer>[];

  /// While set, an upload stays in flight until it completes.
  Completer<void>? holdUpload;

  _FakeWorkplaceRepository(this.outcomesByFileName, {this.failEveryUpload = false});

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async => 'drive-token';

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) => throw UnimplementedError();

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) async {
    capturedSpecs.add(spec);
    capturedTransfers.add(transfer);
    await holdUpload?.future;
    if (failEveryUpload) throw StateError('runner-level failure');
    return _uploadOutcome(spec);
  }

  /// One outcome per fileName: succeeds unless it maps to a specific failure.
  Future<DriveUploadedFile> _uploadOutcome(WorkplaceUploadFileSpec spec) async {
    switch (outcomesByFileName[spec.fileName]) {
      case _Failure.cancelled:
        throw WorkplaceUploadCancelledException();
      case _Failure.uploadConflict:
        throw _httpError(409);
      case 'not-a-uri':
        throw DioException(requestOptions: RequestOptions(path: ''), message: 'upload failed');
      default:
        return DriveUploadedFile(fileId: 'file-${spec.fileName}', name: spec.fileName);
    }
  }

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) async {
    final outcome = outcomesByFileName[fileId.replaceFirst('file-', '')];
    if (outcome is Uri) return outcome;
    throw _httpError(403);
  }
}

FileInfo _makeFile(String name, {bool isInline = false, String? sourceUrl}) => sourceUrl != null
    ? FileBlobInfo(
        fileName: name,
        fileSize: 100,
        isInline: isInline,
        sourceUrl: sourceUrl,
        openRead: ([start, end]) => const Stream<List<int>>.empty(),
      )
    : FileBytesInfo(
        fileName: name,
        fileSize: 100,
        isInline: isInline,
        bytes: Uint8List.fromList(List.filled(100, 1)),
      );

AttachmentUploadRequest _makeRequest(List<FileInfo> files) => AttachmentUploadRequest(
      sizes: const AttachmentUploadSizeSnapshot(
        currentAllAttachmentBytes: 0,
        proposedAllAttachmentBytes: 0,
        currentRegularAttachmentBytes: 0,
        proposedRegularAttachmentBytes: 0,
      ),
      limits: const AttachmentUploadLimits(warningLimitBytes: 1000),
      files: files,
    );

typedef _Setup = ({
  DriveOversizeAttachmentRecovery recovery,
  ProviderContainer container,
  _FakeWorkplaceRepository repository,
});

/// [platformUri] defaults to a non-null platform URL; pass `null` explicitly
/// to test the "Drive unavailable" decline path.
Future<_Setup> _setUpRecovery(
  WidgetTester tester, {
  bool driveAvailable = true,
  Map<String, dynamic> outcomesByFileName = const {},
  bool failEveryUpload = false,
  Future<bool> Function(String html)? insertHtml,
}) async {
  late BuildContext capturedContext;
  final repository = _FakeWorkplaceRepository(outcomesByFileName, failEveryUpload: failEveryUpload);
  final container = ProviderContainer(overrides: [
    driveAttachmentUriValueProvider.overrideWithValue(
      ValueNotifier<Uri?>(driveAvailable ? _platformUrl : null),
    ),
    driveOversizeUploaderProvider.overrideWithValue((
      runner: WorkplaceAccessModeRunner(
        exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
        oidcTokenGetter: () => 'oidc-token',
        oidcRefreshTrigger: () async => null,
      ),
      interactor: UploadDriveFileInteractor(repository),
    )),
  ]);
  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    providerContainer: container,
    child: Builder(builder: (context) {
      capturedContext = context;
      return const SizedBox.shrink();
    }),
  ));
  await tester.pumpAndSettle();
  return (
    recovery: DriveOversizeAttachmentRecovery(
      context: capturedContext,
      insertHtml: insertHtml ?? (_) async => true,
    ),
    container: container,
    repository: repository,
  );
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  group('DriveOversizeAttachmentRecovery::recover::', () {
    testWidgets('null Drive uri returns false, no dialog', (tester) async {
      final setup = await _setUpRecovery(tester, driveAvailable: false);

      final result = await setup.recovery.recover(_failure, _makeRequest([_makeFile('a.zip')]));

      expect(result, isFalse);
      expect(Get.isDialogOpen, isNot(true));
      setup.container.dispose();
    });

    testWidgets('inline-only files are uploaded like any other file', (tester) async {
      final link = Uri.parse('https://drive.example.com/public?sharecode=x');
      final setup = await _setUpRecovery(tester, outcomesByFileName: {'shot.png': link});

      final result = await setup.recovery.recover(
        _failure,
        _makeRequest([_makeFile('shot.png', isInline: true)]),
      );
      expect(result, isTrue);
      await tester.pumpAndSettle();

      expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
      setup.container.dispose();
    });

    testWidgets('success links every file and settles the batch', (tester) async {
      final link = Uri.parse('https://drive.example.com/public?sharecode=x');
      final setup = await _setUpRecovery(tester, outcomesByFileName: {'a.zip': link});

      final result = await setup.recovery.recover(_failure, _makeRequest([_makeFile('a.zip')]));
      expect(result, isTrue);

      // The transfer is unawaited; pump the event loop until it settles.
      await tester.pumpAndSettle();

      expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
      setup.container.dispose();
    });

    testWidgets('one file throws: that row fails, the other still links', (tester) async {
      final link = Uri.parse('https://drive.example.com/public?sharecode=x');
      final setup = await _setUpRecovery(tester, outcomesByFileName: {
        'ok.zip': link,
        'bad.zip': 'not-a-uri',
      });

      final result = await setup.recovery.recover(
        _failure,
        _makeRequest([_makeFile('ok.zip'), _makeFile('bad.zip')]),
      );
      expect(result, isTrue);
      await tester.pumpAndSettle();

      expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
      setup.container.dispose();
    });

    testWidgets('cancelling a row completes the cancel signal of its in-flight upload', (tester) async {
      Get.put<MailboxDashBoardController>(_FakeDashboardController());
      final setup = await _setUpRecovery(tester);
      final hold = Completer<void>();
      setup.repository.holdUpload = hold;

      await setup.recovery.recover(_failure, _makeRequest([_makeFile('c.zip')]));
      await tester.pump();

      final signal = setup.repository.capturedTransfers.single.cancelSignal!;
      var signalled = false;
      signal.then((_) => signalled = true);
      await tester.pump();
      expect(signalled, isFalse);

      setup.container.read(driveOversizeTransferProvider).single.cancelToken.cancel();
      await tester.pump();
      expect(signalled, isTrue);

      hold.complete();
      await tester.pumpAndSettle();
      setup.container.dispose();
    });

    testWidgets('a cancelled row stays cancelled, not failed', (tester) async {
      final setup = await _setUpRecovery(tester, outcomesByFileName: {'c.zip': _Failure.cancelled});

      final result = await setup.recovery.recover(_failure, _makeRequest([_makeFile('c.zip')]));
      expect(result, isTrue);
      await tester.pumpAndSettle();

      expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
      setup.container.dispose();
    });

    for (final failure in [_Failure.uploadConflict, _Failure.shareLinkForbidden]) {
      testWidgets('${failure.name} on one file: the others still reach the editor', (tester) async {
        final inserted = <String>[];
        final setup = await _setUpRecovery(
          tester,
          outcomesByFileName: {
            'one.zip': Uri.parse('https://drive.example.com/public?sharecode=one'),
            'bad.zip': failure,
            'two.zip': Uri.parse('https://drive.example.com/public?sharecode=two'),
          },
          insertHtml: (html) async {
            inserted.add(html);
            return true;
          },
        );

        await setup.recovery.recover(
          _failure,
          _makeRequest([_makeFile('one.zip'), _makeFile('bad.zip'), _makeFile('two.zip')]),
        );
        await tester.pumpAndSettle();

        expect(inserted, hasLength(1));
        expect(inserted.single, contains('sharecode=one'));
        expect(inserted.single, contains('sharecode=two'));
        expect(inserted.single, isNot(contains('bad.zip')));
        expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
        expect(Get.isDialogOpen, isNot(true));
        setup.container.dispose();
      });
    }

    testWidgets('an editor that throws still closes the dialog and clears the batch', (tester) async {
      final setup = await _setUpRecovery(
        tester,
        outcomesByFileName: {'a.zip': Uri.parse('https://drive.example.com/public?sharecode=x')},
        insertHtml: (_) async => throw StateError('editor gone'),
      );

      await setup.recovery.recover(_failure, _makeRequest([_makeFile('a.zip')]));
      await tester.pumpAndSettle();

      expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
      expect(Get.isDialogOpen, isNot(true));
      setup.container.dispose();
    });

    testWidgets('a web blob source sends no body and nests the url in extra', (tester) async {
      final link = Uri.parse('https://drive.example.com/public?sharecode=x');
      final setup = await _setUpRecovery(tester, outcomesByFileName: {'a.zip': link});

      await setup.recovery.recover(
        _failure,
        _makeRequest([_makeFile('a.zip', sourceUrl: 'blob:x')]),
      );
      await tester.pumpAndSettle();

      final source = setup.repository.capturedSpecs.single.source;
      // Bytes leave via the blob adapter, which keys on this exact extra shape.
      expect(source.requestData, isNull);
      final uploadExtra =
          source.dioExtra[UploadRequestExtra.uploadAttachmentKey] as Map;
      expect(uploadExtra[UploadRequestExtra.sourceUrlKey], 'blob:x');
      setup.container.dispose();
    });

    testWidgets('a runner-level failure fails every unsettled row', (tester) async {
      final setup = await _setUpRecovery(tester, failEveryUpload: true);

      final result = await setup.recovery.recover(_failure, _makeRequest([_makeFile('a.zip')]));
      expect(result, isTrue);
      await tester.pumpAndSettle();

      expect(setup.container.read(driveOversizeTransferProvider), isEmpty);
      setup.container.dispose();
    });
  });
}
