import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/bridge_policy.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/usecase/drive_oversize_upload_call.dart';

void main() {
  group('DriveOversizeUploadCall::', () {
    test('never rides the bridge', () {
      expect(DriveOversizeUploadCall((_) async => const []).bridgePolicy, BridgePolicy.never);
    });

    test('returns the transfer links and forwards the access mode', () async {
      final link = Uri.parse('https://drive.example.com/public?sharecode=x');
      WorkplaceAccessMode? receivedMode;
      final call = DriveOversizeUploadCall((accessMode) async {
        receivedMode = accessMode;
        return [link];
      });
      const accessMode = BearerTokenAccessMode('drive-token');

      final links = await call(accessMode);

      expect(links, equals([link]));
      expect(receivedMode, same(accessMode));
    });

    test('rethrows the transfer failure unchanged', () async {
      final error = StateError('boom');

      await expectLater(
        DriveOversizeUploadCall((_) async => throw error).call(const BearerTokenAccessMode('drive-token')),
        throwsA(same(error)),
      );
    });
  });
}
