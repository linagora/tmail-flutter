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

    // These tests document the selective-deletion contract used by
    // UploadController.refreshInlineAttachments: only entries whose blobIds
    // were snapshotted before the server call are removed; images inserted
    // by the user after the last auto-save are preserved.
    group('refreshInlineAttachments contract — selective delete then add fresh', () {
      void simulateRefresh(
        UploadFileStateList list,
        Set<UploadTaskId> staleIds,
        List<UploadTaskId> freshIds,
      ) {
        for (final id in staleIds) {
          list.deleteElementByUploadTaskId(id);
        }
        list.addAll(freshIds.map(
          (id) => UploadFileState(id, uploadStatus: UploadFileStatus.succeed),
        ));
      }

      test('replaces stale draft-part blobIds with fresh ones', () {
        const stale1 = UploadTaskId('D1-part-1');
        const stale2 = UploadTaskId('D1-part-2');
        const fresh1 = UploadTaskId('D2-part-1');
        const fresh2 = UploadTaskId('D2-part-2');

        final list = makeList([stale1, stale2]);
        simulateRefresh(list, {stale1, stale2}, [fresh1, fresh2]);

        final ids = taskIds(list);
        expect(ids, containsAll([fresh1, fresh2]));
        expect(ids, isNot(contains(stale1)));
        expect(ids, isNot(contains(stale2)));
      });

      test('preserves user-inserted images not in the stale snapshot', () {
        const stale = UploadTaskId('D1-part-1');
        const userInserted = UploadTaskId('upload-new-image'); // added after last save
        const fresh = UploadTaskId('D2-part-1');

        final list = makeList([stale, userInserted]);
        simulateRefresh(list, {stale}, [fresh]);

        final ids = taskIds(list);
        expect(ids, contains(userInserted));
        expect(ids, contains(fresh));
        expect(ids, isNot(contains(stale)));
      });

      test('with empty staleIds — adds fresh entries without removing anything', () {
        const existing = UploadTaskId('existing-blob');
        const fresh = UploadTaskId('fresh-blob');

        final list = makeList([existing]);
        simulateRefresh(list, {}, [fresh]);

        expect(taskIds(list), containsAll([existing, fresh]));
      });

      test('with empty freshAttachments — removes only the stale entries', () {
        const stale = UploadTaskId('stale-blob');
        const kept = UploadTaskId('kept-blob');

        final list = makeList([stale, kept]);
        simulateRefresh(list, {stale}, []);

        expect(taskIds(list), isNot(contains(stale)));
        expect(taskIds(list), contains(kept));
      });
    });
  });
}
