import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

import 'composer_attachment_extension_registry_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<ToastManager>(),
])
void main() {
  late MockAuthorizationInterceptors interceptor;
  late MockMailboxDashBoardController dashboard;
  late MockToastManager toastManager;
  late ProviderContainer container;

  final transientError = DioException(
    requestOptions: RequestOptions(path: '/token'),
    type: DioExceptionType.connectionTimeout,
  );

  WorkplaceComposerAttachmentExtension readExtension() =>
      container.read(composerAttachmentExtensionRegistryProvider).extensions.single
          as WorkplaceComposerAttachmentExtension;

  setUp(() {
    interceptor = MockAuthorizationInterceptors();
    dashboard = MockMailboxDashBoardController();
    toastManager = MockToastManager();
    // Get.put/Get.reset run the GetX lifecycle; the mock's fakes would throw.
    when(dashboard.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboard.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    Get.put<AuthorizationInterceptors>(interceptor);
    Get.put<MailboxDashBoardController>(dashboard);
    Get.put<ToastManager>(toastManager);
    container = ProviderContainer(overrides: [
      driveAttachmentUriValueProvider.overrideWithValue(ValueNotifier<Uri?>(null)),
    ]);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group('oidcRefreshTrigger::', () {
    test('returns the refreshed id token on success', () async {
      when(interceptor.requestTokenRefresh()).thenAnswer(
        (_) async => TokenOIDC('access', TokenId('id-token-2'), 'refresh'),
      );

      final token = await readExtension().oidcRefreshTrigger!();

      expect(token, equals('id-token-2'));
      verifyNever(interceptor.clear());
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });

    test('fatal rejection triggers the logout handler exactly once and throws RefreshTokenFailedException', () async {
      final rejection = Exception('invalid_grant');
      when(interceptor.requestTokenRefresh()).thenThrow(rejection);
      when(interceptor.isRefreshFailureFatal(rejection)).thenReturn(true);

      await expectLater(
        readExtension().oidcRefreshTrigger!(),
        throwsA(isA<RefreshTokenFailedException>()),
      );

      verify(interceptor.clear()).called(1);
      verify(dashboard.handleRefreshTokenFailedException()).called(1);
    });

    test('transient failure keeps the session and rethrows the original error', () async {
      when(interceptor.requestTokenRefresh()).thenThrow(transientError);
      when(interceptor.isRefreshFailureFatal(transientError)).thenReturn(false);

      await expectLater(
        readExtension().oidcRefreshTrigger!(),
        throwsA(same(transientError)),
      );

      verifyNever(interceptor.clear());
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });

    test('returns null without logout when no interceptor is registered', () async {
      Get.delete<AuthorizationInterceptors>();

      final token = await readExtension().oidcRefreshTrigger!();

      expect(token, isNull);
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });
  });

  group('onPickState::', () {
    test('transient Drive failure is reported once by the picker layer', () async {
      final failure = DrivePickFailure(transientError);

      await readExtension().onPickState!(null, failure);

      verify(toastManager.showMessageFailure(failure)).called(1);
    });

    test('refresh rejection already handled by the refresh layer is not reported again', () async {
      await readExtension().onPickState!(
        null,
        DrivePickFailure(RefreshTokenFailedException()),
      );

      verifyNever(toastManager.showMessageFailure(any));
    });
  });
}
