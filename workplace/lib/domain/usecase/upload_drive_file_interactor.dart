import '../entity/workplace_request_context.dart';
import '../entity/workplace_upload_file_spec.dart';
import '../entity/workplace_upload_transfer.dart';
import '../repository/workplace_repository.dart';

typedef DriveFileProgressCallback = void Function(int count, int total);

/// One oversize attachment: write it to the Mail magic folder, then mint a
/// public link for it. Both calls share the caller's access mode, so an
/// upload costs at most one token exchange.
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
    final uploaded = await _repository.uploadFile(
      context: context,
      spec: spec,
      transfer: WorkplaceUploadTransfer(
        onProgress: onProgress == null ? null : (count, total) => onProgress(count, total),
        cancelSignal: cancelSignal,
        timeout: _uploadTimeout,
      ),
    );
    return _repository.createShareLink(context: context, fileId: uploaded.fileId);
  }
}
