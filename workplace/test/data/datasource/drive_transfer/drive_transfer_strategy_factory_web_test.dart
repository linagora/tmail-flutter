@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy_factory_web.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';

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

void main() {
  setUp(DriveTransferStrategyFactory.resetCache);

  group('DriveTransferStrategyFactory (web)', () {
    test('returns the OPFS strategy when OPFS is detected', () {
      OpfsJsBindings.setInstance(_FakeOpfsJsBindings(true));

      final strategy = DriveTransferStrategyFactory.create();

      expect(strategy, isA<OpfsDriveTransferStrategy>());
    });

    test('returns the buffered strategy when OPFS is unavailable', () {
      OpfsJsBindings.setInstance(_FakeOpfsJsBindings(false));

      final strategy = DriveTransferStrategyFactory.create();

      expect(strategy, isA<BufferedWebDriveTransferStrategy>());
    });

    test('caches detection across multiple create() calls', () {
      final fake = _FakeOpfsJsBindings(true);
      OpfsJsBindings.setInstance(fake);

      DriveTransferStrategyFactory.create();
      DriveTransferStrategyFactory.create();
      DriveTransferStrategyFactory.create();

      expect(fake.probeCount, 1);
    });
  });
}
