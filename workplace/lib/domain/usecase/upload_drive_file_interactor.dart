import '../entity/workplace_request_context.dart';
import '../entity/workplace_upload_file_spec.dart';
import '../entity/workplace_upload_transfer.dart';
import '../exceptions/workplace_exceptions.dart';
import '../repository/workplace_repository.dart';

typedef DriveFileProgressCallback = void Function(int count, int total);

/// One oversize attachment: write it to the Mail magic folder, then mint a
/// public link for it. Both calls share the caller's access mode, so an
/// upload costs at most one token exchange.
/// Throws [WorkplaceUploadCancelledException] once [cancelSignal] fires.
class UploadDriveFileInteractor {
  /// A streamed upload outlives `WorkplaceDio`'s default request timeouts.
  static const _uploadTimeout = Duration(minutes: 30);

  final WorkplaceRepository _repository;

  UploadDriveFileInteractor(this._repository);

  Future<Uri> execute({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    DriveFileProgressCallback? onProgress,
    Future<void>? cancelSignal,
  }) async {
    var cancelled = false;
    // A failed signal cancels too, like the datasource's cancel token.
    cancelSignal?.then((_) => cancelled = true, onError: (_) => cancelled = true);
    final uploaded = await _repository.uploadFile(
      context: context,
      spec: spec,
      transfer: WorkplaceUploadTransfer(
        onProgress: onProgress == null ? null : (count, total) => onProgress(count, total),
        cancelSignal: cancelSignal,
        timeout: _uploadTimeout,
      ),
    );
    // Cancelled after the upload landed: mint no public link.
    if (cancelled) throw WorkplaceUploadCancelledException();
    final link = await _repository.createShareLink(context: context, fileId: uploaded.fileId);
    // Cancelled while minting: drop the link so it never reaches the mail.
    if (cancelled) throw WorkplaceUploadCancelledException();
    return link;
  }
}
