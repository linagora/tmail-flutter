import 'package:flutter/foundation.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';

/// Bundles the inputs [DriveAttachmentPickerButton] and
/// [DriveAttachmentContextMenuTile] both need to open the Drive picker, so
/// callers thread one object instead of duplicating four constructor params.
class DrivePickerSession {
  final ValueGetter<bool> uploadFromUrlSupported;
  final num? Function() maxAttachmentSizeBytesGetter;

  /// Bytes still attachable once what the composer already holds is deducted.
  final num? Function() remainingAttachmentCapacityBytesGetter;
  final FetchDriveIntentCallback onFetchIntent;

  const DrivePickerSession({
    required this.uploadFromUrlSupported,
    required this.maxAttachmentSizeBytesGetter,
    required this.remainingAttachmentCapacityBytesGetter,
    required this.onFetchIntent,
  });
}

/// Snapshot of the capability-gated values a picker tap needs, read once at
/// tap time rather than through separate getter calls scattered in the mixin.
class DrivePickerSessionSnapshot {
  final bool uploadFromUrlSupported;
  final num? maxAttachmentSizeBytes;
  final num? remainingAttachmentCapacityBytes;

  const DrivePickerSessionSnapshot({
    required this.uploadFromUrlSupported,
    required this.maxAttachmentSizeBytes,
    required this.remainingAttachmentCapacityBytes,
  });
}

/// Resolves a [DrivePickerSession]'s getters on demand, at the point the
/// picker actually needs them.
class DrivePickerSessionResolver {
  final DrivePickerSession session;

  const DrivePickerSessionResolver(this.session);

  DrivePickerSessionSnapshot resolve() => DrivePickerSessionSnapshot(
        uploadFromUrlSupported: session.uploadFromUrlSupported(),
        maxAttachmentSizeBytes: session.maxAttachmentSizeBytesGetter(),
        remainingAttachmentCapacityBytes:
            session.remainingAttachmentCapacityBytesGetter(),
      );
}
