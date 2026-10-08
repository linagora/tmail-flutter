import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';

void main() {
  DriveOversizeTransferState makeItem({required int fileSize, int sentBytes = 0}) =>
      DriveOversizeTransferState(
        taskId: const UploadTaskId('task-1'),
        fileName: 'file.bin',
        fileSize: fileSize,
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
  });
}
