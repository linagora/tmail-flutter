import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_oversize_uploader_provider.dart';
import 'package:workplace/domain/usecase/drive_oversize_upload_call.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    Get.testMode = true;
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  test(
    'WHEN the app holds no OIDC token\n'
    'THEN the uploader runner fails before running the Drive call',
    () async {
      final uploader = container.read(driveOversizeUploaderProvider);
      var callRan = false;

      await expectLater(
        uploader.runner.run(
          Uri.parse('https://platform.example.com'),
          DriveOversizeUploadCall((_) async {
            callRan = true;
            return const [];
          }),
        ),
        throwsA(isA<StateError>().having(
          (error) => error.message,
          'message',
          'OIDC token is unavailable',
        )),
      );
      expect(callRan, isFalse);
    },
  );
}
