
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_limits.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_request.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_size_snapshot.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_state_source.dart';

final class AttachmentUploadRequestFactory {
  const AttachmentUploadRequestFactory();

  AttachmentUploadRequest fromProposedFiles({
    required Iterable<FileInfo> files,
    required AttachmentUploadStateSource state,
  }) {
    final candidate = List<FileInfo>.unmodifiable(files);
    final proposedAllBytes = candidate.fold<int>(0, (total, file) => total + _byteCount(file));
    final proposedRegularBytes = candidate
        .where((file) => file.isInline != true)
        .fold<int>(0, (total, file) => total + _byteCount(file));
    return AttachmentUploadRequest(
      sizes: AttachmentUploadSizeSnapshot(
        currentAllAttachmentBytes: _requireNonNegative(state.currentAllAttachmentBytes, 'currentAllAttachmentBytes'),
        proposedAllAttachmentBytes: proposedAllBytes,
        currentRegularAttachmentBytes: _requireNonNegative(state.currentRegularAttachmentBytes, 'currentRegularAttachmentBytes'),
        proposedRegularAttachmentBytes: proposedRegularBytes,
      ),
      limits: _limitsOf(state),
    );
  }

  AttachmentUploadRequest fromProposedBytes({
    required int proposedAllAttachmentBytes,
    required int proposedRegularAttachmentBytes,
    required AttachmentUploadStateSource state,
  }) {
    return AttachmentUploadRequest(
      sizes: AttachmentUploadSizeSnapshot(
        currentAllAttachmentBytes: _requireNonNegative(state.currentAllAttachmentBytes, 'currentAllAttachmentBytes'),
        proposedAllAttachmentBytes: _requireNonNegative(proposedAllAttachmentBytes, 'proposedAllAttachmentBytes'),
        currentRegularAttachmentBytes: _requireNonNegative(state.currentRegularAttachmentBytes, 'currentRegularAttachmentBytes'),
        proposedRegularAttachmentBytes: _requireNonNegative(proposedRegularAttachmentBytes, 'proposedRegularAttachmentBytes'),
      ),
      limits: _limitsOf(state),
    );
  }

  AttachmentUploadLimits _limitsOf(AttachmentUploadStateSource state) => AttachmentUploadLimits(
        warningLimitBytes: state.warningLimitBytes,
        hardLimitBytes: state.hardLimitBytes,
      );

  int _byteCount(FileInfo file) {
    return _requireNonNegative(file.fileSize, 'file.fileSize');
  }

  int _requireNonNegative(int value, String name) {
    if (value < 0) throw ArgumentError.value(value, name, 'must be non-negative');
    return value;
  }

  static int? normalizeServerLimitBytes(num? value) {
    if (value == null) return null;
    if (value is double && !value.isFinite) {
      throw ArgumentError.value(value, 'value', 'must be finite');
    }
    if (value < 0 || value != value.truncate()) {
      throw ArgumentError.value(value, 'value', 'must be a non-negative integer');
    }
    return value.toInt();
  }
}
