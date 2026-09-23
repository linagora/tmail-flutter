import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  DriveOversizeTransferState makeItem(String id, {int fileSize = 100}) =>
      DriveOversizeTransferState(
        taskId: UploadTaskId(id),
        fileName: '$id.txt',
        fileSize: fileSize,
        cancelToken: CancelToken(),
      );

  group('DriveOversizeTransfer::', () {
    test('start seeds the rows', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      final items = [makeItem('a'), makeItem('b')];

      notifier.start(items);

      expect(container.read(driveOversizeTransferProvider), equals(items));
    });

    test('reportProgress sets uploading and sentBytes', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a', fileSize: 1000)]);

      notifier.reportProgress(const UploadTaskId('a'), 400, 1000);

      final row = container.read(driveOversizeTransferProvider).single;
      expect(row.status, equals(DriveOversizeTransferStatus.uploading));
      expect(row.sentBytes, equals(400));
    });

    test('reportProgress drops a tick that does not move the bar a whole percent', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a', fileSize: 1000)]);
      notifier.reportProgress(const UploadTaskId('a'), 400, 1000);
      final before = container.read(driveOversizeTransferProvider);

      notifier.reportProgress(const UploadTaskId('a'), 404, 1000);

      expect(identical(container.read(driveOversizeTransferProvider), before), isTrue);
    });

    test('reportProgress applies a whole-percent move', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a', fileSize: 1000)]);
      notifier.reportProgress(const UploadTaskId('a'), 400, 1000);

      notifier.reportProgress(const UploadTaskId('a'), 410, 1000);

      expect(container.read(driveOversizeTransferProvider).single.sentBytes, equals(410));
    });

    test('reportProgress applies the first byte so the bar leaves indeterminate', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a', fileSize: 100000)]);
      notifier.markUploading(const UploadTaskId('a'));

      notifier.reportProgress(const UploadTaskId('a'), 1, 100000);

      expect(container.read(driveOversizeTransferProvider).single.sentBytes, equals(1));
    });

    test('an unknown task id leaves the state untouched', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a')]);
      final before = container.read(driveOversizeTransferProvider);

      notifier.markFailed(const UploadTaskId('zzz'));

      expect(identical(container.read(driveOversizeTransferProvider), before), isTrue);
    });

    test('markLinked forces sentBytes == fileSize', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a', fileSize: 1000)]);

      notifier.markLinked(const UploadTaskId('a'));

      final row = container.read(driveOversizeTransferProvider).single;
      expect(row.status, equals(DriveOversizeTransferStatus.linked));
      expect(row.sentBytes, equals(1000));
    });

    final cancelCases = <({
      String description,
      bool markLinkedFirst,
      DriveOversizeTransferStatus expectedStatus,
      bool expectedTokenCancelled,
    })>[
      (
        description: 'cancel cancels the token once and sets cancelled',
        markLinkedFirst: false,
        expectedStatus: DriveOversizeTransferStatus.cancelled,
        expectedTokenCancelled: true,
      ),
      (
        description: 'cancel on a settled row is a no-op and does not cancel its token',
        markLinkedFirst: true,
        expectedStatus: DriveOversizeTransferStatus.linked,
        expectedTokenCancelled: false,
      ),
    ];
    for (final cancelCase in cancelCases) {
      test(cancelCase.description, () {
        final notifier = container.read(driveOversizeTransferProvider.notifier);
        final item = makeItem('a');
        notifier.start([item]);
        if (cancelCase.markLinkedFirst) notifier.markLinked(const UploadTaskId('a'));

        notifier.cancel(const UploadTaskId('a'));

        final row = container.read(driveOversizeTransferProvider).single;
        expect(row.status, equals(cancelCase.expectedStatus));
        expect(item.cancelToken.isCancelled, equals(cancelCase.expectedTokenCancelled));
      });
    }

    test('cancelAll cancels only unsettled rows', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      final linked = makeItem('a');
      final waiting = makeItem('b');
      notifier.start([linked, waiting]);
      notifier.markLinked(const UploadTaskId('a'));

      notifier.cancelAll();

      final rows = container.read(driveOversizeTransferProvider);
      expect(rows[0].status, equals(DriveOversizeTransferStatus.linked));
      expect(rows[1].status, equals(DriveOversizeTransferStatus.cancelled));
      expect(linked.cancelToken.isCancelled, isFalse);
      expect(waiting.cancelToken.isCancelled, isTrue);
    });

    test('allSettled is false on an empty list', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      expect(notifier.allSettled, isFalse);
    });

    test('allSettled is true once every row reached a terminal status', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a'), makeItem('b')]);
      expect(notifier.allSettled, isFalse);

      notifier.markLinked(const UploadTaskId('a'));
      notifier.markFailed(const UploadTaskId('b'));

      expect(notifier.allSettled, isTrue);
    });

    test('clear resets to an empty list', () {
      final notifier = container.read(driveOversizeTransferProvider.notifier);
      notifier.start([makeItem('a')]);

      notifier.clear();

      expect(container.read(driveOversizeTransferProvider), isEmpty);
    });
  });
}
