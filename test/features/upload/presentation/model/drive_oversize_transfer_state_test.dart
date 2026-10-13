import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';

void main() {
  DriveOversizeTransferState makeItem({
    required int fileSize,
    int sentBytes = 0,
    String fileName = 'file.bin',
    String mimeType = Constant.octetStreamMimeType,
  }) =>
      DriveOversizeTransferState(
        taskId: const UploadTaskId('task-1'),
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
        sentBytes: sentBytes,
        cancelToken: CancelToken(),
      );

  group('DriveOversizeTransferState.progress:', () {
    test('Should report the sent fraction of the file', () {
      final item = makeItem(fileSize: 1000, sentBytes: 250);

      expect(item.progress, 0.25);
      expect(item.percent, 25);
    });

    test('Should cap the bar at 1.0 when more bytes than the file size were sent', () {
      final item = makeItem(fileSize: 1000, sentBytes: 1200);

      expect(item.progress, 1.0);
      expect(item.percent, 100);
    });

    test('Should report 0 when the file size is unknown', () {
      final item = makeItem(fileSize: 0);

      expect(item.progress, 0);
      expect(item.percent, 0);
    });
  });

  group('DriveOversizeTransferState.copyWith:', () {
    test('Should keep the status and the cancel token when only the bytes change', () {
      final item = makeItem(fileSize: 1000);

      final next = item.copyWith(sentBytes: 500);

      expect(next.sentBytes, 500);
      expect(next.status, DriveOversizeTransferStatus.waiting);
      expect(identical(next.cancelToken, item.cancelToken), isTrue);
    });

    test('Should keep the mime type when the status changes', () {
      final item = makeItem(fileSize: 1000, mimeType: 'video/mp4');

      final next = item.copyWith(status: DriveOversizeTransferStatus.uploading);

      expect(next.mimeType, 'video/mp4');
    });
  });

  group('DriveOversizeTransferState equality:', () {
    test('Should differ when only the mime type differs', () {
      expect(
        makeItem(fileSize: 1000, mimeType: 'video/mp4'),
        isNot(equals(makeItem(fileSize: 1000, mimeType: 'image/png'))),
      );
    });
  });

  group('DriveOversizeTransferState.getIcon:', () {
    final imagePaths = ImagePaths();

    test('Should pick the icon from the file extension', () {
      final item = makeItem(fileSize: 1000, fileName: 'report.pdf');

      expect(item.getIcon(imagePaths), imagePaths.icFilePdf);
    });

    test('Should pick the icon from the mime type when the name has no extension', () {
      final item = makeItem(fileSize: 1000, fileName: 'clip', mimeType: 'video/mp4');

      expect(item.getIcon(imagePaths), imagePaths.icFileVideo);
    });

    test('Should fall back to the default icon when the mime type cannot be parsed', () {
      final item = makeItem(fileSize: 1000, fileName: 'clip', mimeType: 'not a mime type');

      expect(item.getIcon(imagePaths), imagePaths.icFileDefault);
    });

    test('Should fall back to the default icon for an unknown extension and an octet-stream type', () {
      final item = makeItem(fileSize: 1000, fileName: 'file.bin');

      expect(item.getIcon(imagePaths), imagePaths.icFileDefault);
    });
  });
}
