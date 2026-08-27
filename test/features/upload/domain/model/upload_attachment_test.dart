import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

import '../../../../fixtures/capturing_log_handler.dart';
import 'upload_attachment_test.mocks.dart';

/// Mirrors the production thrower closely enough for these tests: it maps the
/// raw error to a domain exception by throwing it.
class _RethrowingExceptionThrower extends ExceptionThrower {
  @override
  throwException(dynamic error, dynamic stackTrace) => throw error;
}

class _RethrowExceptionThrower extends ExceptionThrower {
  @override
  throwException(dynamic error, dynamic stackTrace) => throw error;
}

@GenerateNiceMocks([MockSpec<FileUploader>()])
void main() {
  group('UploadAttachment::upload error reporting::', () {
    const taskId = UploadTaskId('upload-task-1');
    const sensitiveName = 'SENSITIVE-PAYSLIP-2026.pdf';
    final uploadUri = Uri.parse('https://mail.example.com/upload/account-1');

    late MockFileUploader fileUploader;
    late CapturingLogHandler logHandler;

    final fileInfo = FileInfo(
      fileName: sensitiveName,
      fileSize: 100,
      type: 'application/pdf',
      isInline: false,
    );

    setUp(() {
      fileUploader = MockFileUploader();
      logHandler = CapturingLogHandler();
      AppLoggerRegistry.instance.registerHandler(logHandler);
    });

    tearDown(() => AppLoggerRegistry.instance.resetForTesting());

    UploadAttachment makeUploadAttachment({CancelToken? cancelToken}) => UploadAttachment(
          taskId,
          fileInfo,
          uploadUri,
          fileUploader,
          _RethrowingExceptionThrower(),
          cancelToken: cancelToken,
        );

    /// Drives [upload] to completion; the stream closes in its finally block.
    Future<List<Either<Failure, Success>>> runUpload(UploadAttachment attachment) {
      final events = attachment.progressState.toList();
      attachment.upload();
      return events;
    }

    test(
      'WHEN the uploader throws\n'
      'THEN exactly ONE error event is emitted with its exception and stack\n'
      'AND the file name is not part of it',
      () async {
        when(fileUploader.uploadAttachment(
          any,
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          onSendController: anyNamed('onSendController'),
        )).thenThrow(StateError('backend refused the upload'));

        final events = await runUpload(makeUploadAttachment());

        expect(
          events.any((e) => e.fold((l) => l is ErrorAttachmentUploadState, (_) => false)),
          isTrue,
        );

        expect(logHandler.errorRecords, hasLength(1));
        final record = logHandler.errorRecords.single;
        expect(record.exception, isA<StateError>());
        expect(record.stackTrace, isNotNull);
        expect(record.extras?.keys, isNot(contains('fileName')));
        expect(record.rawMessage, isNot(contains(sensitiveName)));
        expect(record.extras, containsPair('mimeType', fileInfo.mimeType));
        expect(record.extras, containsPair('isInline', false));
      },
    );

    test(
      'WHEN the upload is cancelled\n'
      'THEN it emits CancelAttachmentUploadState and NO error event',
      () async {
        when(fileUploader.uploadAttachment(
          any,
          any,
          any,
          cancelToken: anyNamed('cancelToken'),
          onSendController: anyNamed('onSendController'),
        )).thenThrow(DioException.requestCancelled(
          requestOptions: RequestOptions(path: '/upload'),
          reason: null,
        ));

        final events = await runUpload(makeUploadAttachment(cancelToken: CancelToken()));

        expect(
          events.any((e) => e.fold((l) => l is CancelAttachmentUploadState, (_) => false)),
          isTrue,
        );
        expect(
          logHandler.errorRecords,
          isEmpty,
          reason: 'a cancelled upload is not a failure worth reporting',
        );
      },
    );
  });

  Future<HttpServer> startStalledUploadServer({
    required Completer<void> requestReceived,
    required Completer<void> releaseResponse,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      await request.drain<void>();
      if (!requestReceived.isCompleted) {
        requestReceived.complete();
      }
      await releaseResponse.future;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-id',
        'type': 'application/pdf',
        'size': 0,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      if (!releaseResponse.isCompleted) {
        releaseResponse.complete();
      }
      await server.close(force: true);
    });
    return server;
  }

  test('reports a cancelled upload as CancelAttachmentUploadState, not an error', () async {
    final sourceBytes = List<int>.generate(2048, (index) => index % 256);
    final directory = await Directory.systemTemp.createTemp('cancel-attachment-');
    addTearDown(() async {
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/a.pdf');
    await file.writeAsBytes(sourceBytes);

    final requestReceived = Completer<void>();
    final releaseResponse = Completer<void>();
    final server = await startStalledUploadServer(
      requestReceived: requestReceived,
      releaseResponse: releaseResponse,
    );
    final cancelToken = CancelToken();
    const uploadTaskId = UploadTaskId('upload-cancel');
    final uploadAttachment = UploadAttachment(
      uploadTaskId,
      FileInfo(fileName: 'a.pdf', fileSize: sourceBytes.length, filePath: file.path),
      Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
      FileUploader(DioClient(Dio()), FileUtils()),
      _RethrowExceptionThrower(),
      cancelToken: cancelToken,
    );

    final statesFuture = uploadAttachment.progressState.toList();
    uploadAttachment.upload();

    await requestReceived.future.timeout(const Duration(seconds: 30));
    cancelToken.cancel();

    final states = await statesFuture.timeout(const Duration(seconds: 30));
    final emittedStates = <Object?>[];
    for (final state in states) {
      state.fold(emittedStates.add, emittedStates.add);
    }

    // Cancelling now aborts the socket, so a real DioExceptionType.cancel
    // reaches UploadAttachment instead of the upload running to completion.
    expect(emittedStates.whereType<ErrorAttachmentUploadState>(), isEmpty);
    expect(emittedStates.last, isA<CancelAttachmentUploadState>());
    expect(
      (emittedStates.last as CancelAttachmentUploadState).uploadId,
      uploadTaskId,
    );
  });
}
