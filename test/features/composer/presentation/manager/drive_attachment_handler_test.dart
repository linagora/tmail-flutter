import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/drive_attachment_handler.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/usecases/download_drive_file_interactor.dart';

import 'drive_attachment_handler_test.mocks.dart';
import 'drive_attachment_handler_test_helper.dart';

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
}
