import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/state/download_drive_file_state.dart';

import 'drive_attachment_handler_test.mocks.dart';
import 'drive_attachment_handler_test_helper.dart';

void _stubValidationSuccess(MockUploadController mock) {
  when(mock.validateTotalSizeAttachmentsBeforeUpload(
    totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
    onValidationSuccess: anyNamed('onValidationSuccess'),
  )).thenAnswer((invocation) {
    final callback = invocation.namedArguments[#onValidationSuccess] as VoidCallback?;
    callback?.call();
  });
}

void _stubDownloadSuccess(
  MockDownloadDriveFileInteractor mock,
  DriveDocument doc,
  FileInfo fileInfo,
) {
  when(mock.execute(doc)).thenAnswer(
    (_) => Stream.value(Right(DownloadDriveFileSuccess(fileInfo))),
  );
}

void main() {
  late MockUploadController mockUploadController;
  late MockDownloadDriveFileInteractor mockDownloadInteractor;
  late List<List<FileInfo>> uploadedFiles;
  late DriveAttachmentHandler handler;

  setUp(() {
    Get.testMode = true;
    mockUploadController = MockUploadController();
    mockDownloadInteractor = MockDownloadDriveFileInteractor();
    uploadedFiles = [];

    handler = DriveAttachmentHandler(
      uploadController: mockUploadController,
      downloadDriveFileInteractor: mockDownloadInteractor,
    );
  });

  tearDown(() => Get.reset());

  group('DriveAttachmentHandler::downloadAndUploadDriveFile::', () {
    test('Should skip validation when no docs have downloadLink', () {
      handler.downloadAndUploadDriveFile(
        [noLinkDoc],
        uploadFiles: ({required pickedFiles}) => uploadedFiles.add(pickedFiles),
      );

      verifyNever(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      ));
    });

    test('Should pass summed size to validateTotalSizeAttachmentsBeforeUpload', () {
      final doc2 = DriveDocument(
        id: '6',
        name: 'Second',
        size: 300,
        mimeType: 'image/png',
        downloadLink: Uri.parse('https://example.com/second.png'),
      );

        handler.downloadAndUploadDriveFile(
          [attachmentDoc, doc2],
          uploadFiles: ({required pickedFiles}) =>
              uploadedFiles.add(pickedFiles),
        );

      verify(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: 500,
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).called(1);
    });

    test('Should call uploadFiles once with all downloaded files', () async {
      final fileInfo1 = FileInfo(fileName: 'photo.jpg', fileSize: 200, filePath: '/tmp/photo.jpg', type: 'image/jpeg');
      final fileInfo2 = FileInfo(fileName: 'second.png', fileSize: 300, filePath: '/tmp/second.png', type: 'image/png');

      final doc2 = DriveDocument(
        id: '7',
        name: 'second.png',
        size: 300,
        mimeType: 'image/png',
        downloadLink: Uri.parse('https://example.com/second.png'),
      );

      _stubDownloadSuccess(mockDownloadInteractor, attachmentDoc, fileInfo1);
      _stubDownloadSuccess(mockDownloadInteractor, doc2, fileInfo2);

      _stubValidationSuccess(mockUploadController);

      await handler.downloadAndUploadDriveFile(
        [attachmentDoc, doc2],
        uploadFiles: ({required pickedFiles}) => uploadedFiles.add(pickedFiles),
      );
      await Future.delayed(Duration.zero);

      expect(uploadedFiles, hasLength(1));
      expect(uploadedFiles.first, containsAll([fileInfo1, fileInfo2]));
    });

    test('Should upload single file when only one download succeeds', () async {
      final fileInfo = FileInfo(fileName: 'photo.jpg', fileSize: 200, filePath: '/tmp/photo.jpg', type: 'image/jpeg');

      _stubDownloadSuccess(mockDownloadInteractor, attachmentDoc, fileInfo);
      _stubValidationSuccess(mockUploadController);

      await handler.downloadAndUploadDriveFile(
        [attachmentDoc],
        uploadFiles: ({required pickedFiles}) => uploadedFiles.add(pickedFiles),
      );
      await Future.delayed(Duration.zero);

      expect(uploadedFiles, hasLength(1));
      expect(uploadedFiles.first, equals([fileInfo]));
    });

    test('Should not upload file when download emits failure', () async {
      when(mockDownloadInteractor.execute(attachmentDoc)).thenAnswer(
        (_) => Stream.value(Left(DownloadDriveFileFailure(Exception('Network error')))),
      );

      _stubValidationSuccess(mockUploadController);

      await handler.downloadAndUploadDriveFile(
        [attachmentDoc],
        uploadFiles: ({required pickedFiles}) => uploadedFiles.add(pickedFiles),
      );
      await Future.delayed(Duration.zero);

      expect(uploadedFiles, isEmpty);
    });

    test('Should skip DownloadingDriveFile progress state and still upload success file', () async {
      final fileInfo = FileInfo(fileName: 'photo.jpg', fileSize: 200, filePath: '/tmp/photo.jpg', type: 'image/jpeg');

      when(mockDownloadInteractor.execute(attachmentDoc)).thenAnswer(
        (_) => Stream.fromIterable([
          Right(DownloadingDriveFile()),
          Right(DownloadDriveFileSuccess(fileInfo)),
        ]),
      );

      _stubValidationSuccess(mockUploadController);

        await handler.downloadAndUploadDriveFile(
          [attachmentDoc],
          uploadFiles: ({required pickedFiles}) =>
              uploadedFiles.add(pickedFiles),
        );
      await Future.delayed(Duration.zero);

      expect(uploadedFiles, hasLength(1));
      expect(uploadedFiles.first, equals([fileInfo]));
    });

    test('Should not call onValidationSuccess when validation fails', () async {
      when(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).thenReturn(null);

      await handler.downloadAndUploadDriveFile(
        [attachmentDoc],
        uploadFiles: ({required pickedFiles}) => uploadedFiles.add(pickedFiles),
      );

      verifyNever(mockDownloadInteractor.execute(any));
      expect(uploadedFiles, isEmpty);
    });
  });
}
