@TestOn('chrome')
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy_factory_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';

class _FakeOpfsJsBindings extends OpfsJsBindings {
  final bool supported;
  int probeCount = 0;

  _FakeOpfsJsBindings(this.supported);

  @override
  bool isOpfsSupported() {
    probeCount++;
    return supported;
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
  setUp(DriveTransferStrategyFactory.resetCache);

  group('DriveTransferStrategyFactory (web)', () {
    test('returns the OPFS strategy when OPFS is detected', () {
      OpfsJsBindings.setInstance(_FakeOpfsJsBindings(true));

      final strategy = DriveTransferStrategyFactory.create(uploader: _unusedUploader);

      expect(strategy, isA<OpfsDriveTransferStrategy>());
    });

    test('returns the buffered strategy when OPFS is unavailable', () {
      OpfsJsBindings.setInstance(_FakeOpfsJsBindings(false));

      final strategy = DriveTransferStrategyFactory.create(uploader: _unusedUploader);

      expect(strategy, isA<BufferedWebDriveTransferStrategy>());
    });

    test('caches detection across multiple create() calls', () {
      final fake = _FakeOpfsJsBindings(true);
      OpfsJsBindings.setInstance(fake);

      DriveTransferStrategyFactory.create(uploader: _unusedUploader);
      DriveTransferStrategyFactory.create(uploader: _unusedUploader);
      DriveTransferStrategyFactory.create(uploader: _unusedUploader);

      expect(fake.probeCount, 1);
    });
  });
}
