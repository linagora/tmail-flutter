@TestOn('chrome')
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy_factory_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_feature_detection.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';

class _FakeOpfsCapability implements OpfsCapability {
  final bool supported;
  int probeCount = 0;

  _FakeOpfsCapability(this.supported);

  @override
  bool isOpfsSupported() {
    probeCount++;
    return supported;
  }
}

/// An unexpected browser environment can make the probe throw rather than
/// answer; the transfer must still run, on the fallback.
class _ThrowingOpfsCapability implements OpfsCapability {
  @override
  bool isOpfsSupported() => throw StateError('probe blew up');
}

/// Counts the sweep calls. Fire-and-forget in the factory, so what matters is
/// that it was called, not that it finished.
class _SweepCountingStore extends OpfsFileOps {
  int sweepCount = 0;

  @override
  Future<void> sweepStaleTempFiles({
    Duration olderThan = const Duration(hours: 4),
  }) async {
    sweepCount++;
  }
}

/// The factory only forwards this to the buffered strategy; no test here
/// reaches the upload leg.
Future<Attachment> _unusedUploader({
  required StagedDriveFile staged,
  required Uri uploadUri,
  required OnFileProcessedProgress onUploadProgress,
  required CancelToken cancelToken,
}) =>
    throw UnimplementedError();

void main() {
  group('DriveTransferStrategyFactory (web)', () {
    test('returns the OPFS strategy when OPFS is detected', () {
      final factory =
          DriveTransferStrategyFactory(capability: _FakeOpfsCapability(true));

      final strategy = factory.create(uploader: _unusedUploader);

      expect(strategy, isA<OpfsDriveTransferStrategy>());
    });

    test('returns the buffered strategy when OPFS is unavailable', () {
      final factory =
          DriveTransferStrategyFactory(capability: _FakeOpfsCapability(false));

      final strategy = factory.create(uploader: _unusedUploader);

      expect(strategy, isA<BufferedWebDriveTransferStrategy>());
    });

    test('falls back to the buffered strategy when the probe throws', () {
      final factory =
          DriveTransferStrategyFactory(capability: _ThrowingOpfsCapability());

      final strategy = factory.create(uploader: _unusedUploader);

      expect(strategy, isA<BufferedWebDriveTransferStrategy>());
    });

    test('sweeps stale temp files once across repeated create() calls', () {
      final store = _SweepCountingStore();
      final factory = DriveTransferStrategyFactory(
        capability: _FakeOpfsCapability(true),
        store: store,
      );

      factory.create(uploader: _unusedUploader);
      factory.create(uploader: _unusedUploader);
      factory.create(uploader: _unusedUploader);

      // Orphans left by a dead tab are reclaimed once a session, not on every
      // transfer.
      expect(store.sweepCount, 1);
    });

    test('does not sweep when OPFS is unavailable', () {
      final store = _SweepCountingStore();
      final factory = DriveTransferStrategyFactory(
        capability: _FakeOpfsCapability(false),
        store: store,
      );

      factory.create(uploader: _unusedUploader);

      // Nothing staged into OPFS on the buffered path, so there is nothing to
      // reclaim — and the sweep would touch storage the browser may not have.
      expect(store.sweepCount, 0);
    });

    test('caches detection across multiple create() calls', () {
      final fake = _FakeOpfsCapability(true);
      final factory = DriveTransferStrategyFactory(capability: fake);

      factory.create(uploader: _unusedUploader);
      factory.create(uploader: _unusedUploader);
      factory.create(uploader: _unusedUploader);

      expect(fake.probeCount, 1);
    });
  });
}
