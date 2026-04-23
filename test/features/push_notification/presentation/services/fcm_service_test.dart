import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';

void main() {
  group('FcmService stream lifecycle', () {
    setUp(() {
      FcmService.instance.closeStream();
    });

    tearDown(() {
      FcmService.instance.closeStream();
    });

    test(
      'initialStreamController preserves active controllers and listeners',
      () async {
        final service = FcmService.instance;

        service.initialStreamController();
        final backgroundController = service.backgroundMessageStreamController;
        final tokenController = service.fcmTokenStreamController;
        final receivedTokens = <String?>[];
        final subscription = tokenController!.stream.listen(receivedTokens.add);

        service.initialStreamController();
        service.handleToken('token-1');
        await Future<void>.delayed(Duration.zero);

        expect(
          identical(
            service.backgroundMessageStreamController,
            backgroundController,
          ),
          isTrue,
          reason: 'Background message controller was recreated while active',
        );
        expect(
          identical(service.fcmTokenStreamController, tokenController),
          isTrue,
          reason: 'FCM token controller was recreated while active',
        );
        expect(receivedTokens, ['token-1']);

        await subscription.cancel();
      },
    );

    test('closeStream is idempotent and clears stream controllers', () {
      final service = FcmService.instance;

      service.initialStreamController();

      expect(service.backgroundMessageStreamController, isNotNull);
      expect(service.fcmTokenStreamController, isNotNull);

      service.closeStream();
      service.closeStream();

      expect(service.backgroundMessageStreamController, isNull);
      expect(service.fcmTokenStreamController, isNull);
    });
  });
}
