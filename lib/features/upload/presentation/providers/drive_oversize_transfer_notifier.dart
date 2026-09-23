import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';

part 'drive_oversize_transfer_notifier.g.dart';

/// Rows of the oversize-upload dialog. One batch at a time — the dialog is
/// modal, so a composer can only run one oversize pick concurrently.
@Riverpod(keepAlive: true)
class DriveOversizeTransfer extends _$DriveOversizeTransfer {
  @override
  List<DriveOversizeTransferState> build() => const [];

  void start(List<DriveOversizeTransferState> items) => state = items;

  void clear() => state = const [];

  /// True once every row reached a terminal status — the dialog closes on it.
  bool get allSettled =>
      state.isNotEmpty && state.every((item) => item.status.settled);

  /// The bridge path never calls this, so its rows stay indeterminate.
  /// XHR reports far more often than the bar can show, so sub-percent ticks are dropped.
  void reportProgress(UploadTaskId taskId, int sentBytes, int totalBytes) {
    _update(taskId, (item) {
      final next = item.copyWith(
        sentBytes: sentBytes,
        status: DriveOversizeTransferStatus.uploading,
      );
      final sameBar = next.status == item.status
          && next.percent == item.percent
          && (next.sentBytes > 0) == (item.sentBytes > 0);
      return sameBar ? item : next;
    });
  }

  void markUploading(UploadTaskId taskId) => _update(
      taskId, (item) => item.copyWith(status: DriveOversizeTransferStatus.uploading));

  void markLinked(UploadTaskId taskId) => _update(
      taskId, (item) => item.copyWith(
        sentBytes: item.fileSize,
        status: DriveOversizeTransferStatus.linked,
      ));

  void markFailed(UploadTaskId taskId) => _update(
      taskId, (item) => item.copyWith(status: DriveOversizeTransferStatus.failed));

  /// A settled row is left alone so a racing cancel can't un-link a finished file.
  void cancel(UploadTaskId taskId) {
    _update(taskId, (item) {
      if (item.status.settled) return item;
      if (!item.cancelToken.isCancelled) item.cancelToken.cancel();
      return item.copyWith(status: DriveOversizeTransferStatus.cancelled);
    });
  }

  void cancelAll() {
    for (final item in state) {
      cancel(item.taskId);
    }
  }

  void _update(
    UploadTaskId taskId,
    DriveOversizeTransferState Function(DriveOversizeTransferState item) transform,
  ) {
    final index = state.indexWhere((item) => item.taskId == taskId);
    if (index < 0) return;
    final next = transform(state[index]);
    if (identical(next, state[index])) return;
    state = [...state]..[index] = next;
  }
}
