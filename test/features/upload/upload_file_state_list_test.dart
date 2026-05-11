import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state_list.dart';

void main() {
  group('UploadFileStateList::refreshBlobId', () {
    late UploadFileStateList uploadFileStateList;

    Attachment createAttachment(String blobId) {
      return Attachment(
        blobId: Id(blobId),
        name: 'file.png',
        size: UnsignedInt(100),
        type: MediaType('image', 'png'),
      );
    }

    UploadFileState createUploadFileState({
      required String uploadTaskId,
      required String blobId,
    }) {
      return UploadFileState(
        UploadTaskId(uploadTaskId),
        attachment: createAttachment(blobId),
      );
    }

    setUp(() {
      uploadFileStateList = UploadFileStateList();
    });

    test(
      'should replace matching blobId',
      () {
        uploadFileStateList.add(
          createUploadFileState(
            uploadTaskId: 'task-1',
            blobId: 'draft-123_5',
          ),
        );

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final updatedState = uploadFileStateList.uploadingStateFiles.first;

        expect(
          updatedState?.attachment?.blobId?.value,
          'email-999_5',
        );
      },
    );

    test(
      'should update all matching blobIds',
      () {
        uploadFileStateList.addAll([
          createUploadFileState(
            uploadTaskId: 'task-1',
            blobId: 'draft-123_1',
          ),
          createUploadFileState(
            uploadTaskId: 'task-2',
            blobId: 'draft-123_2',
          ),
        ]);

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final states = uploadFileStateList.uploadingStateFiles;

        expect(
          states[0]?.attachment?.blobId?.value,
          'email-999_1',
        );

        expect(
          states[1]?.attachment?.blobId?.value,
          'email-999_2',
        );
      },
    );

    test(
      'should not update non matching blobId',
      () {
        uploadFileStateList.add(
          createUploadFileState(
            uploadTaskId: 'task-1',
            blobId: 'another-blob_1',
          ),
        );

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final state = uploadFileStateList.uploadingStateFiles.first;

        expect(
          state?.attachment?.blobId?.value,
          'another-blob_1',
        );
      },
    );

    test(
      'should skip upload file when attachment is null',
      () {
        uploadFileStateList.add(
          UploadFileState(
            const UploadTaskId('task-1'),
          ),
        );

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final state = uploadFileStateList.uploadingStateFiles.first;

        expect(state?.attachment, isNull);
      },
    );

    test(
      'should skip upload file when blobId is null',
      () {
        final attachment = Attachment(
          name: 'file.png',
          size: UnsignedInt(100),
          type: MediaType('image', 'png'),
        );

        uploadFileStateList.add(
          UploadFileState(
            const UploadTaskId('task-1'),
            attachment: attachment,
          ),
        );

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final state = uploadFileStateList.uploadingStateFiles.first;

        expect(
          state?.attachment?.blobId,
          isNull,
        );
      },
    );

    test(
      'should skip null upload file state',
      () {
        uploadFileStateList.addAll([
          createUploadFileState(
            uploadTaskId: 'task-1',
            blobId: 'draft-123_1',
          ),
        ]);

        uploadFileStateList.addNullableForTest(null);

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final states = uploadFileStateList.uploadingStateFiles;

        expect(
          states.first?.attachment?.blobId?.value,
          'email-999_1',
        );
      },
    );

    test(
      'should keep other attachment properties after updating blobId',
      () {
        final attachment = Attachment(
          blobId: Id('draft-123_1'),
          name: 'image.png',
          size: UnsignedInt(500),
          type: MediaType('image', 'png'),
          cid: 'cid-123',
        );

        uploadFileStateList.add(
          UploadFileState(
            const UploadTaskId('task-1'),
            attachment: attachment,
          ),
        );

        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        final updatedAttachment =
            uploadFileStateList.uploadingStateFiles.first?.attachment;

        expect(
          updatedAttachment?.blobId?.value,
          'email-999_1',
        );

        expect(updatedAttachment?.name, 'image.png');
        expect(updatedAttachment?.size?.value, 500);
        expect(updatedAttachment?.cid, 'cid-123');

        expect(updatedAttachment?.type?.type, 'image');
        expect(updatedAttachment?.type?.subtype, 'png');
      },
    );

    test(
      'should do nothing when list is empty',
      () {
        uploadFileStateList.refreshBlobId(
          oldBlobId: Id('draft-123'),
          newBlobId: Id('email-999'),
        );

        expect(
          uploadFileStateList.uploadingStateFiles,
          isEmpty,
        );
      },
    );
  });
}
