import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state_list.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

void main() {
  group('UploadFileStateList', () {
    late UploadFileStateList uploadFileStateList;

    Attachment createAttachment(String blobId, {String? cid}) {
      return Attachment(
        blobId: Id(blobId),
        name: 'file.png',
        size: UnsignedInt(100),
        type: MediaType('image', 'png'),
        cid: cid,
      );
    }

    UploadFileState createUploadFileState({
      required String uploadTaskId,
      required String blobId,
    }) {
      return UploadFileState(
        UploadTaskId(uploadTaskId),
        uploadStatus: UploadFileStatus.succeed,
        attachment: createAttachment(blobId),
      );
    }

    void populateWithTwoItems() {
      uploadFileStateList.addAll([
        createUploadFileState(uploadTaskId: 'task-1', blobId: 'blob-1'),
        createUploadFileState(uploadTaskId: 'task-2', blobId: 'blob-2'),
      ]);
    }

    setUp(() {
      uploadFileStateList = UploadFileStateList();
    });

    group('add / addAll', () {
      test('should contain added element', () {
        uploadFileStateList.add(createUploadFileState(
          uploadTaskId: 'task-1',
          blobId: 'blob-1',
        ));

        expect(uploadFileStateList.uploadingStateFiles, hasLength(1));
        expect(
          uploadFileStateList.uploadingStateFiles.first?.attachment?.blobId?.value,
          'blob-1',
        );
      });

      test('should contain all added elements', () {
        populateWithTwoItems();

        expect(uploadFileStateList.uploadingStateFiles, hasLength(2));
      });
    });

    group('clear', () {
      test('should be empty after clear', () {
        populateWithTwoItems();

        uploadFileStateList.clear();

        expect(uploadFileStateList.uploadingStateFiles, isEmpty);
      });
    });

    group('updateElementByUploadTaskId', () {
      late UploadFileState? Function(UploadFileState?) updater;

      setUp(() {
        uploadFileStateList.add(createUploadFileState(
          uploadTaskId: 'task-1',
          blobId: 'blob-1',
        ));
        updater = (state) => state?.copyWith(
          attachment: createAttachment('blob-updated'),
        );
      });

      void actAndAssert({
        required String taskId,
        required String expectedBlobId,
      }) {
        uploadFileStateList.updateElementByUploadTaskId(
          UploadTaskId(taskId),
          updater,
        );
        expect(
          uploadFileStateList.uploadingStateFiles.first?.attachment?.blobId?.value,
          expectedBlobId,
        );
      }

      test('should update element matching the given upload task id', () {
        actAndAssert(taskId: 'task-1', expectedBlobId: 'blob-updated');
      });

      test('should not update element when task id does not match', () {
        actAndAssert(taskId: 'task-2', expectedBlobId: 'blob-1');
      });
    });

    group('deleteElementByUploadTaskId', () {
      test('should remove element with matching task id', () {
        populateWithTwoItems();

        uploadFileStateList.deleteElementByUploadTaskId(const UploadTaskId('task-1'));

        expect(uploadFileStateList.uploadingStateFiles, hasLength(1));
        expect(
          uploadFileStateList.uploadingStateFiles.first?.attachment?.blobId?.value,
          'blob-2',
        );
      });
    });

    group('allSuccess', () {
      test('should return true when all elements have succeed status', () {
        populateWithTwoItems();

        expect(uploadFileStateList.allSuccess, isTrue);
      });

      test('should return false when list is empty', () {
        expect(uploadFileStateList.allSuccess, isFalse);
      });

      test('should return false when list contains a null element', () {
        uploadFileStateList.addNullableForTest(null);

        expect(uploadFileStateList.allSuccess, isFalse);
      });
    });

    group('getUploadFileStateById', () {
      setUp(() => populateWithTwoItems());

      test('should return state matching the given task id', () {
        final result = uploadFileStateList.getUploadFileStateById(const UploadTaskId('task-1'));

        expect(result, isNotNull);
        expect(result?.attachment?.blobId?.value, 'blob-1');
      });

      test('should return null when task id does not match any element', () {
        final result = uploadFileStateList.getUploadFileStateById(const UploadTaskId('task-99'));

        expect(result, isNull);
      });
    });
  });
}
