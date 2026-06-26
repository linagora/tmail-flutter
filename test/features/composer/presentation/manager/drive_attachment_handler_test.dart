import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/state/download_drive_file_state.dart';
import 'package:workplace/domain/usecases/download_drive_file_interactor.dart';

import 'drive_attachment_handler_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<UploadController>(fallbackGenerators: fallbackGenerators),
  MockSpec<DownloadDriveFileInteractor>(),
])
void main() {
  late MockUploadController mockUploadController;
  late MockDownloadDriveFileInteractor mockDownloadInteractor;
  late List<String> insertedHtml;
  late List<List<FileInfo>> uploadedFiles;
  late DriveAttachmentHandler handler;

  setUp(() {
    Get.testMode = true;
    mockUploadController = MockUploadController();
    mockDownloadInteractor = MockDownloadDriveFileInteractor();
    insertedHtml = [];
    uploadedFiles = [];

    handler = DriveAttachmentHandler(
      uploadController: mockUploadController,
      downloadDriveFileInteractor: mockDownloadInteractor,
      insertHtml: (html) => insertedHtml.add(html),
      uploadFiles: ({required pickedFiles}) => uploadedFiles.add(pickedFiles),
    );
  });

  tearDown(() => Get.reset());

  final linkDoc = DriveDocument(
    id: '1',
    name: 'Report',
    size: 100,
    mimeType: 'application/pdf',
    sharingLink: Uri.parse('https://drive.example.com/report'),
  );

  final attachmentDoc = DriveDocument(
    id: '2',
    name: 'Photo.jpg',
    size: 200,
    mimeType: 'image/jpeg',
    downloadLink: Uri.parse('https://drive.example.com/photo.jpg'),
  );

  const noLinkDoc = DriveDocument(
    id: '3',
    name: 'Unknown',
    size: 0,
    mimeType: 'application/octet-stream',
  );

  group('DriveAttachmentHandler::handleDrivePickResult::', () {
    test('Should insert link html for docs with sharingLink', () {
      handler.handleDrivePickResult([linkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('https://drive.example.com/report'));
      expect(insertedHtml.first, contains('Report'));
    });

    test('Should call validateTotalSizeAttachmentsBeforeUpload for docs with downloadLink', () {
      handler.handleDrivePickResult([attachmentDoc]);

      verify(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).called(1);
    });

    test('Should prefer sharingLink over downloadLink when doc has both', () {
      final bothLinksDoc = DriveDocument(
        id: '4',
        name: 'Both',
        size: 50,
        mimeType: 'application/pdf',
        sharingLink: Uri.parse('https://drive.example.com/both'),
        downloadLink: Uri.parse('https://drive.example.com/both-dl'),
      );

      handler.handleDrivePickResult([bothLinksDoc]);

      expect(insertedHtml, hasLength(1));
      verifyNever(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      ));
    });

    test('Should skip docs with neither sharingLink nor downloadLink', () {
      handler.handleDrivePickResult([noLinkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, isEmpty);
      verifyNever(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      ));
    });

    test('Should handle mixed docs correctly', () {
      handler.handleDrivePickResult([linkDoc, attachmentDoc, noLinkDoc]);

      expect(insertedHtml, hasLength(1));
      expect(insertedHtml.first, contains('Report'));
      verify(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).called(1);
    });
  });

  group('DriveAttachmentHandler::insertDriveLinkHtml::', () {
    test('Should generate anchor tag with escaped href and label', () {
      final doc = DriveDocument(
        id: '1',
        name: 'My <Report>',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('https://example.com/file?a=1&b=2'),
      );

      handler.insertDriveLinkHtml([doc]);

      expect(insertedHtml.first, contains('&amp;'));
      expect(insertedHtml.first, contains('My &lt;Report&gt;'));
      expect(insertedHtml.first, contains('<a href='));
    });

    test('Should join multiple links with <br>', () {
      final doc2 = DriveDocument(
        id: '2',
        name: 'Second',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('https://example.com/second'),
      );

      handler.insertDriveLinkHtml([linkDoc, doc2]);

      expect(insertedHtml.first, contains('<br>'));
    });

    test('Should produce empty string for docs with null sharingLink', () {
      handler.insertDriveLinkHtml([noLinkDoc]);

      expect(insertedHtml.first, isEmpty);
    });

    test('Should skip non-https links in release mode', () {
      final httpDoc = DriveDocument(
        id: '5',
        name: 'Insecure',
        size: 0,
        mimeType: 'text/plain',
        sharingLink: Uri.parse('http://example.com/file'),
      );

      handler.insertDriveLinkHtml([httpDoc]);

      if (kReleaseMode) {
        expect(insertedHtml.first, isEmpty);
      } else {
        expect(insertedHtml.first, contains('http://example.com/file'));
      }
    });
  });

  group('DriveAttachmentHandler::downloadAndUploadDriveFile::', () {
    test('Should skip validation when no docs have downloadLink', () {
      handler.downloadAndUploadDriveFile([noLinkDoc]);

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

      handler.downloadAndUploadDriveFile([attachmentDoc, doc2]);

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

      when(mockDownloadInteractor.execute(attachmentDoc)).thenAnswer(
        (_) => Stream.value(Right(DownloadDriveFileSuccess(fileInfo1))),
      );
      when(mockDownloadInteractor.execute(doc2)).thenAnswer(
        (_) => Stream.value(Right(DownloadDriveFileSuccess(fileInfo2))),
      );

      when(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).thenAnswer((invocation) {
        final callback = invocation.namedArguments[#onValidationSuccess] as VoidCallback?;
        callback?.call();
      });

      await handler.downloadAndUploadDriveFile([attachmentDoc, doc2]);

      await Future.delayed(Duration.zero);

      // uploadFiles called once with both files
      expect(uploadedFiles, hasLength(1));
      expect(uploadedFiles.first, containsAll([fileInfo1, fileInfo2]));
    });

    test('Should upload single file when only one download succeeds', () async {
      final fileInfo = FileInfo(fileName: 'photo.jpg', fileSize: 200, filePath: '/tmp/photo.jpg', type: 'image/jpeg');

      when(mockDownloadInteractor.execute(attachmentDoc)).thenAnswer(
        (_) => Stream.value(Right(DownloadDriveFileSuccess(fileInfo))),
      );

      when(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).thenAnswer((invocation) {
        final callback = invocation.namedArguments[#onValidationSuccess] as VoidCallback?;
        callback?.call();
      });

      await handler.downloadAndUploadDriveFile([attachmentDoc]);

      await Future.delayed(Duration.zero);

      expect(uploadedFiles, hasLength(1));
      expect(uploadedFiles.first, equals([fileInfo]));
    });

    test('Should not upload file when download emits failure', () async {
      when(mockDownloadInteractor.execute(attachmentDoc)).thenAnswer(
        (_) => Stream.value(Left(DownloadDriveFileFailure(Exception('Network error')))),
      );

      when(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).thenAnswer((invocation) {
        final callback = invocation.namedArguments[#onValidationSuccess] as VoidCallback?;
        callback?.call();
      });

      await handler.downloadAndUploadDriveFile([attachmentDoc]);

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

      when(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).thenAnswer((invocation) {
        final callback = invocation.namedArguments[#onValidationSuccess] as VoidCallback?;
        callback?.call();
      });

      await handler.downloadAndUploadDriveFile([attachmentDoc]);

      await Future.delayed(Duration.zero);

      expect(uploadedFiles, hasLength(1));
      expect(uploadedFiles.first, equals([fileInfo]));
    });

    test('Should not call onValidationSuccess when validation fails', () async {
      when(mockUploadController.validateTotalSizeAttachmentsBeforeUpload(
        totalSizePreparedFiles: anyNamed('totalSizePreparedFiles'),
        onValidationSuccess: anyNamed('onValidationSuccess'),
      )).thenReturn(null);

      await handler.downloadAndUploadDriveFile([attachmentDoc]);

      verifyNever(mockDownloadInteractor.execute(any));
      expect(uploadedFiles, isEmpty);
    });
  });
}
