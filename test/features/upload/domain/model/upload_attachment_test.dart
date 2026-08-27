import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
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
}
