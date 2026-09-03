import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

import '../../../../fixtures/capturing_log_handler.dart';

/// Mirrors the production thrower closely enough for these tests: it maps the
/// raw error to a domain exception by throwing it.
class _RethrowingExceptionThrower extends ExceptionThrower {
  @override
  throwException(dynamic error, dynamic stackTrace) => throw error;
}

class _ThrowingFileUploader extends FileUploader {
  _ThrowingFileUploader(this._error) : super(DioClient(Dio()), FileUtils());

  final Object _error;

  @override
  Future<Attachment> uploadAttachment(
    UploadTaskId uploadId,
    FileInfo fileInfo,
    Uri uploadUri, {
    CancelToken? cancelToken,
    StreamController<Either<Failure, Success>>? onSendController,
  }) async => throw _error;
}

void main() {
  group('UploadAttachment::upload error reporting::', () {
    const taskId = UploadTaskId('upload-task-1');
    const sensitiveName = 'SENSITIVE-PAYSLIP-2026.pdf';
    final uploadUri = Uri.parse('https://mail.example.com/upload/account-1');

    late CapturingLogHandler logHandler;

    final fileInfo = FileInfo(
      fileName: sensitiveName,
      fileSize: 100,
      type: 'application/pdf',
      isInline: false,
    );

    setUp(() {
      logHandler = CapturingLogHandler();
      AppLoggerRegistry.instance.registerHandler(logHandler);
    });

    tearDown(() => AppLoggerRegistry.instance.resetForTesting());

    UploadAttachment makeUploadAttachment({
      required Object error,
      CancelToken? cancelToken,
    }) => UploadAttachment(
          taskId,
          fileInfo,
          uploadUri,
          _ThrowingFileUploader(error),
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
        final events = await runUpload(makeUploadAttachment(
          error: StateError('backend refused the upload'),
        ));

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
        final events = await runUpload(makeUploadAttachment(
          error: DioException.requestCancelled(
            requestOptions: RequestOptions(path: '/upload'),
            reason: null,
          ),
          cancelToken: CancelToken(),
        ));

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

  Future<HttpServer> startSuccessfulUploadServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      await request.drain<void>();
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-id',
        'type': 'application/pdf',
        'size': 3,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }

  Future<HttpServer> startFailingUploadServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      await request.drain<void>();
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'error': 'upload failed'}));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }

  UploadAttachment buildUploadAttachment({
    required UploadTaskId uploadTaskId,
    required FileInfo fileInfo,
    required Uri uploadUri,
  }) => UploadAttachment(
    uploadTaskId,
    fileInfo,
    uploadUri,
    FileUploader(DioClient(Dio()), FileUtils()),
    _RethrowingExceptionThrower(),
  );

  List<Object?> emittedStates(List<Either<Failure, Success>> states) {
    final emittedStates = <Object?>[];
    for (final state in states) {
      state.fold(emittedStates.add, emittedStates.add);
    }
    return emittedStates;
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
      _RethrowingExceptionThrower(),
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

  test('surfaces a missing attachment source as ErrorAttachmentUploadState', () async {
    const uploadTaskId = UploadTaskId('upload-no-source');
    final uploadAttachment = UploadAttachment(
      uploadTaskId,
      // Neither a usable path nor bytes: the upload must fail as an error state
      // rather than silently succeeding with an empty attachment.
      FileInfo(fileName: 'a.pdf', fileSize: 0, filePath: '', type: 'application/pdf'),
      Uri.parse('http://127.0.0.1:1/upload/account-id'),
      FileUploader(DioClient(Dio()), FileUtils()),
      _RethrowingExceptionThrower(),
    );

    final statesFuture = uploadAttachment.progressState.toList();
    uploadAttachment.upload();

    final states = await statesFuture.timeout(const Duration(seconds: 30));
    final emittedStates = <Object?>[];
    for (final state in states) {
      state.fold(emittedStates.add, emittedStates.add);
    }

    expect(emittedStates.whereType<CancelAttachmentUploadState>(), isEmpty);
    expect(emittedStates.last, isA<ErrorAttachmentUploadState>());
    expect(
      (emittedStates.last as ErrorAttachmentUploadState).exception,
      isA<MissingAttachmentSourceException>(),
    );
  });

  test('reports a completed upload as SuccessAttachmentUploadState', () async {
    const uploadTaskId = UploadTaskId('upload-success');
    final server = await startSuccessfulUploadServer();
    final uploadAttachment = buildUploadAttachment(
      uploadTaskId: uploadTaskId,
      fileInfo: FileInfo(
        fileName: 'a.pdf',
        fileSize: 3,
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        type: 'application/pdf',
      ),
      uploadUri: Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
    );

    final statesFuture = uploadAttachment.progressState.toList();
    uploadAttachment.upload();

    final states = emittedStates(await statesFuture.timeout(const Duration(seconds: 30)));

    expect(states.first, isA<PendingAttachmentUploadState>());
    expect(states.last, isA<SuccessAttachmentUploadState>());
    expect((states.last as SuccessAttachmentUploadState).uploadId, uploadTaskId);
    expect((states.last as SuccessAttachmentUploadState).attachment.name, 'a.pdf');
  });

  test('forwards send progress to progressState', () async {
    const uploadTaskId = UploadTaskId('upload-progress');
    final sourceBytes = Uint8List.fromList(
      List<int>.generate(4096, (index) => index % 256),
    );
    final server = await startSuccessfulUploadServer();
    final uploadAttachment = buildUploadAttachment(
      uploadTaskId: uploadTaskId,
      fileInfo: FileInfo(
        fileName: 'a.pdf',
        fileSize: sourceBytes.length,
        bytes: sourceBytes,
        type: 'application/pdf',
      ),
      uploadUri: Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
    );

    final statesFuture = uploadAttachment.progressState.toList();
    uploadAttachment.upload();

    final states = emittedStates(await statesFuture.timeout(const Duration(seconds: 30)));
    final progressStates = states.whereType<UploadingAttachmentUploadState>();

    expect(progressStates, isNotEmpty);
    expect(progressStates.last.uploadId, uploadTaskId);
    expect(progressStates.last.progress, sourceBytes.length);
    expect(progressStates.last.total, sourceBytes.length);
  });

  test('reports a failed upload as ErrorAttachmentUploadState', () async {
    const uploadTaskId = UploadTaskId('upload-failure');
    final server = await startFailingUploadServer();
    final uploadAttachment = buildUploadAttachment(
      uploadTaskId: uploadTaskId,
      fileInfo: FileInfo(
        fileName: 'a.pdf',
        fileSize: 3,
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        type: 'application/pdf',
      ),
      uploadUri: Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
    );

    final statesFuture = uploadAttachment.progressState.toList();
    uploadAttachment.upload();

    final states = emittedStates(await statesFuture.timeout(const Duration(seconds: 30)));

    expect(states.whereType<SuccessAttachmentUploadState>(), isEmpty);
    expect(states.whereType<CancelAttachmentUploadState>(), isEmpty);
    expect(states.last, isA<ErrorAttachmentUploadState>());
    expect(
      (states.last as ErrorAttachmentUploadState).exception,
      isA<DioException>().having(
        (exception) => exception.response?.statusCode,
        'status code',
        HttpStatus.internalServerError,
      ),
    );
  });
}
