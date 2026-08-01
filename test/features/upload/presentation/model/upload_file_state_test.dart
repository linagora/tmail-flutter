import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

void main() {
  const taskId = UploadTaskId('task-1');

  FileInfo localFile({required int fileSize}) => FileInfo(
        fileName: 'file-$fileSize',
        filePath: '/tmp/file-$fileSize',
        fileSize: fileSize,
      );

  Attachment uploadedAttachment({required int size}) => Attachment(
        blobId: Id('blob-$size'),
        size: UnsignedInt(size),
        disposition: ContentDisposition.attachment,
      );

  group('UploadFileState.fileSize:', () {
    test('Should report the local file size when only a picked file is present', () {
      final state = UploadFileState(taskId, file: localFile(fileSize: 1024));

      expect(state.fileSize, 1024);
    });

    test('Should report the server size when only an attachment is present', () {
      final state = UploadFileState(taskId, attachment: uploadedAttachment(size: 2048));

      expect(state.fileSize, 2048);
    });

    test(
        'Should prefer the attachment size over the local file size when both are present',
        () {
      // This precedence is what makes attachments carried into the composer by a
      // forward, reply or draft restore count toward the size limits: those
      // states are built from an Attachment with no local FileInfo behind them.
      final state = UploadFileState(
        taskId,
        file: localFile(fileSize: 1024),
        attachment: uploadedAttachment(size: 2048),
      );

      expect(state.fileSize, 2048);
    });

    test('Should report zero when neither a file nor an attachment is present', () {
      final state = UploadFileState(taskId);

      expect(state.fileSize, 0);
    });

    test('Should report zero when the attachment advertises no size', () {
      final state = UploadFileState(
        taskId,
        attachment: Attachment(blobId: Id('blob-no-size')),
      );

      expect(state.fileSize, 0);
    });
  });
}
