import 'package:dio/dio.dart';
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
        const a = UploadTaskId('a');
        const b = UploadTaskId('b');
        final list = makeList([a, b]);

        list.deleteElementByUploadTaskId(const UploadTaskId('unknown'));

        expect(list.uploadingStateFiles.length, 2);
        expect(taskIds(list), equals({a, b}));
      });

      test('is a no-op on an empty list', () {
        final list = UploadFileStateList();
        expect(
          () => list.deleteElementByUploadTaskId(const UploadTaskId('any')),
          returnsNormally,
        );
      });
    });

    group('by-id lookup index', () {
      test('finds every entry after an earlier one is deleted', () {
        const a = UploadTaskId('a');
        const b = UploadTaskId('b');
        const c = UploadTaskId('c');
        final list = makeList([a, b, c]);

        list.deleteElementByUploadTaskId(a);

        expect(list.getUploadFileStateById(a), isNull);
        expect(list.getUploadFileStateById(b)?.uploadTaskId, b);
        expect(list.getUploadFileStateById(c)?.uploadTaskId, c);
      });

      test('updates the right entry after a delete shifts the indices', () {
        const a = UploadTaskId('a');
        const b = UploadTaskId('b');
        final list = makeList([a, b]);

        list.deleteElementByUploadTaskId(a);
        list.updateElementByUploadTaskId(
          b,
          (state) => state?.copyWith(uploadingProgress: 42),
        );

        expect(list.getUploadFileStateById(b)?.uploadingProgress, 42);
      });

      test('finds an entry added after a delete', () {
        const a = UploadTaskId('a');
        const b = UploadTaskId('b');
        final list = makeList([a]);

        list.deleteElementByUploadTaskId(a);
        list.add(UploadFileState(b, uploadStatus: UploadFileStatus.waiting));

        expect(list.getUploadFileStateById(b)?.uploadTaskId, b);
      });

      test('is empty again after clear', () {
        const a = UploadTaskId('a');
        final list = makeList([a]);

        list.clear();

        expect(list.getUploadFileStateById(a), isNull);
      });

      test('keeps resolving ids when a predicate update replaces an entry', () {
        const a = UploadTaskId('a');
        const b = UploadTaskId('b');
        final list = makeList([a, b]);

        list.updateElementBy(
          (state) => state?.uploadTaskId == a,
          (_) => UploadFileState(const UploadTaskId('renamed'), uploadStatus: UploadFileStatus.waiting),
        );

        expect(list.getUploadFileStateById(a), isNull);
        expect(list.getUploadFileStateById(const UploadTaskId('renamed')), isNotNull);
        expect(list.getUploadFileStateById(b)?.uploadTaskId, b);
      });
    });

    group('updateElementByUploadTaskId', () {
      test('is a no-op for an id no longer in the list', () {
        const a = UploadTaskId('a');
        final list = makeList([a]);
        list.deleteElementByUploadTaskId(a);

        list.updateElementByUploadTaskId(
          a,
          (state) => UploadFileState(a, uploadStatus: UploadFileStatus.succeed),
        );

        expect(list.uploadingStateFiles, isEmpty);
      });
    });

    group('cancelAll', () {
      test('cancels every pending token and empties the list', () {
        final tokenA = CancelToken();
        final tokenB = CancelToken();
        final list = UploadFileStateList();
        list.addAll([
          UploadFileState(
            const UploadTaskId('a'),
            uploadStatus: UploadFileStatus.uploading,
            cancelToken: tokenA,
          ),
          UploadFileState(
            const UploadTaskId('b'),
            uploadStatus: UploadFileStatus.uploading,
            cancelToken: tokenB,
          ),
        ]);

        list.cancelAll();

        expect(tokenA.isCancelled, isTrue);
        expect(tokenB.isCancelled, isTrue);
        expect(list.uploadingStateFiles, isEmpty);
      });

      test('skips entries with no token without throwing', () {
        final list = makeList([const UploadTaskId('no-token')]);

        expect(() => list.cancelAll(), returnsNormally);
        expect(list.uploadingStateFiles, isEmpty);
      });

      test('is a no-op on an empty list', () {
        final list = UploadFileStateList();
        expect(() => list.cancelAll(), returnsNormally);
      });
    });
  });
}
