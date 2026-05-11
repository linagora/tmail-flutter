import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state_list.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

void main() {
  group('UploadFileStateList', () {
    UploadFileStateList makeList(List<UploadTaskId> ids) {
      final list = UploadFileStateList();
      list.addAll(ids.map(
        (id) => UploadFileState(id, uploadStatus: UploadFileStatus.succeed),
      ));
      return list;
    }

    Set<UploadTaskId> taskIds(UploadFileStateList list) =>
        list.uploadingStateFiles.map((s) => s!.uploadTaskId).toSet();

    group('deleteElementByUploadTaskId', () {
      test('removes the entry with the matching id', () {
        const target = UploadTaskId('target-blob');
        const other = UploadTaskId('other-blob');
        final list = makeList([target, other]);

        list.deleteElementByUploadTaskId(target);

        expect(taskIds(list), isNot(contains(target)));
        expect(taskIds(list), contains(other));
      });

      test('preserves all entries when id is not found', () {
        final list = makeList([const UploadTaskId('a'), const UploadTaskId('b')]);

        list.deleteElementByUploadTaskId(const UploadTaskId('unknown'));

        expect(list.uploadingStateFiles.length, 2);
      });

      test('is a no-op on an empty list', () {
        final list = UploadFileStateList();
        expect(
          () => list.deleteElementByUploadTaskId(const UploadTaskId('any')),
          returnsNormally,
        );
      });
    });
  });
}
