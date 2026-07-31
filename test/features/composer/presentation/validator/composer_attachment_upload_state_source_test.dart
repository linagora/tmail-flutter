import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/validator/composer_attachment_upload_state_source.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

import '../composer_controller_test.mocks.dart';

void main() {
  late MockUploadController mockUploadController;

  setUp(() {
    mockUploadController = MockUploadController();
    when(mockUploadController.regularAttachmentsTotalBytes).thenReturn(0);
    when(mockUploadController.inlineAttachmentsTotalBytes).thenReturn(0);
  });

  group('ComposerAttachmentUploadStateSource byte totals:', () {
    test('Should read regularAttachmentsTotalBytes/inlineAttachmentsTotalBytes live on every access', () {
      final stateSource = ComposerAttachmentUploadStateSource(
        uploadController: mockUploadController,
        warningLimitBytes: 1000,
        maxSizeAttachmentsPerEmailProvider: () => null,
      );

      expect(stateSource.currentAllAttachmentBytes, 0);
      expect(stateSource.currentRegularAttachmentBytes, 0);

      when(mockUploadController.regularAttachmentsTotalBytes).thenReturn(100);
      when(mockUploadController.inlineAttachmentsTotalBytes).thenReturn(50);

      expect(stateSource.currentAllAttachmentBytes, 150);
      expect(stateSource.currentRegularAttachmentBytes, 100);
    });
  });

  group('ComposerAttachmentUploadStateSource.fromServerCapability:', () {
    test('Should normalize a server capability value to an int hard limit', () {
      final stateSource = ComposerAttachmentUploadStateSource.fromServerCapability(
        uploadController: mockUploadController,
        maxSizeAttachmentsPerEmail: () => 20971520,
      );

      expect(stateSource.hardLimitBytes, 20971520);
    });

    test('Should yield a null hard limit when the server advertises no capability', () {
      final stateSource = ComposerAttachmentUploadStateSource.fromServerCapability(
        uploadController: mockUploadController,
        maxSizeAttachmentsPerEmail: () => null,
      );

      expect(stateSource.hardLimitBytes, isNull);
    });

    test('Should resolve the warning limit from AppConfig', () {
      final stateSource = ComposerAttachmentUploadStateSource.fromServerCapability(
        uploadController: mockUploadController,
        maxSizeAttachmentsPerEmail: () => null,
      );

      expect(
        stateSource.warningLimitBytes,
        AppConfig.warningAttachmentFileSizeInMegabytes * 1024 * 1024,
      );
    });

    test('Should read the hard limit live on every access', () {
      num? currentCapability = 1000;
      final stateSource = ComposerAttachmentUploadStateSource.fromServerCapability(
        uploadController: mockUploadController,
        maxSizeAttachmentsPerEmail: () => currentCapability,
      );

      expect(stateSource.hardLimitBytes, 1000);

      currentCapability = 5000;

      expect(stateSource.hardLimitBytes, 5000);
    });
  });
}
