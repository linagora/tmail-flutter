import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/concurrency_gate.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/features/upload/domain/state/upload_drive_document_from_url_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_transfer_placeholder.dart';
import 'package:uuid/uuid.dart';
import 'package:workplace/domain/entity/drive_document.dart';

/// Runs one gateway call; injected so this class never touches GetX.
typedef UploadFromUrlCall = Future<Either<Failure, Success>> Function(
  UploadFromUrlRequest request,
);

typedef OnPlaceholdersReady = void Function(List<DriveTransferPlaceholder> placeholders);
typedef OnDriveTransferSuccess = void Function(UploadTaskId taskId, Attachment attachment);
typedef OnDriveTransferFailure = void Function(UploadTaskId taskId);

/// One batch's input, bundled into a single param for [DriveAttachmentTransferRunner.transfer].
typedef DriveTransferRequest = ({
  List<DriveDocument> docs,
  AccountId accountId,
  Uri uploadUri,
  OnPlaceholdersReady onPlaceholdersReady,
  OnDriveTransferSuccess onSuccess,
  OnDriveTransferFailure onFailure,
});

/// One batch's result. [started] is false when the batch never ran; cancelled
/// tasks resolve neither counter.
typedef DriveTransferOutcome = ({bool started, int succeeded, int failed});

/// One in-flight unit of work: the doc plus its pre-minted placeholder.
typedef _DriveTransferTask = ({DriveDocument doc, DriveTransferPlaceholder placeholder});

/// Fans a batch of downloadable drive documents out to [uploadFromUrl] through
/// [gate]. The gate is owned by the caller, so concurrency stays bounded across
/// every batch rather than per runner. Pure logic, no GetX — fully unit-testable.
class DriveAttachmentTransferRunner {
  DriveAttachmentTransferRunner({
    required this.uploadFromUrl,
    required this.gate,
  });

  final UploadFromUrlCall uploadFromUrl;
  final ConcurrencyGate gate;

  static const notStartedOutcome =
      (started: false, succeeded: 0, failed: 0);

  Future<DriveTransferOutcome> transfer(DriveTransferRequest request) async {
    if (request.docs.isEmpty) return notStartedOutcome;

    final tasks = request.docs
        .map((doc) => (
              doc: doc,
              placeholder: DriveTransferPlaceholder(
                taskId: UploadTaskId(const Uuid().v4()),
                fileName: doc.name,
                fileSize: doc.size,
                mimeType: doc.mimeType,
                cancelToken: CancelToken(),
              ),
            ))
        .toList();

    try {
      request.onPlaceholdersReady(tasks.map((task) => task.placeholder).toList());
    } catch (e, s) {
      // Without chips nothing can resolve, so the batch never starts.
      logError(
        'DriveAttachmentTransferRunner::transfer: onPlaceholdersReady failed',
        exception: e,
        stackTrace: s,
      );
      return notStartedOutcome;
    }

    // Counted here so the caller can tell a fully clean batch from a partial one.
    var succeeded = 0;
    var failed = 0;
    final countingRequest = (
      docs: request.docs,
      accountId: request.accountId,
      uploadUri: request.uploadUri,
      onPlaceholdersReady: request.onPlaceholdersReady,
      onSuccess: (UploadTaskId taskId, Attachment attachment) {
        succeeded++;
        _notify('onSuccess', () => request.onSuccess(taskId, attachment));
      },
      onFailure: (UploadTaskId taskId) {
        failed++;
        _notify('onFailure', () => request.onFailure(taskId));
      },
    );

    await Future.wait(
      tasks.map((task) => gate.run(() => _runOne(task, countingRequest))),
    );
    return (started: true, succeeded: succeeded, failed: failed);
  }

  Future<void> _runOne(_DriveTransferTask task, DriveTransferRequest request) async {
    // Chip already deleted while this task waited its turn: its request would
    // only be rejected downstream, and a cancellation is not a failure.
    if (task.placeholder.cancelToken?.isCancelled == true) return;
    final taskId = task.placeholder.taskId;
    final downloadLink = task.doc.downloadLink;
    // Guarded here too: the runner is injectable, so it can't trust its caller's gate.
    if (downloadLink == null || downloadLink.toString().trim().isEmpty) {
      request.onFailure(taskId);
      return;
    }
    final Either<Failure, Success> either;
    try {
      either = await uploadFromUrl(UploadFromUrlRequest(
        accountId: request.accountId,
        uploadUri: request.uploadUri,
        attachmentUrl: downloadLink,
        name: task.doc.name,
        mimeType: task.doc.mimeType,
        cancelToken: task.placeholder.cancelToken,
      ));
    } catch (_) {
      // uploadFromUrl must resolve every task; a thrown error still counts as failure.
      request.onFailure(taskId);
      return;
    }
    // fold runs outside the try so a throw from onSuccess/onFailure isn't
    // mistaken for an upload failure and double-reported; the callbacks are
    // guarded by _notify instead, so one bad chip can't abort its siblings.
    either.fold(
      (failure) {
        // a user-cancelled transfer is not a failure; the chip is already gone.
        if (failure is UploadDriveDocumentFromUrlCancelled) return;
        request.onFailure(taskId);
      },
      (success) => success is UploadDriveDocumentFromUrlSuccess
          ? request.onSuccess(taskId, success.attachment)
          : request.onFailure(taskId),
    );
  }

  /// Runs a caller callback; a throw is logged and contained to this task.
  void _notify(String label, void Function() callback) {
    try {
      callback();
    } catch (e, s) {
      logError(
        'DriveAttachmentTransferRunner::_notify: $label failed',
        exception: e,
        stackTrace: s,
      );
    }
  }
}
