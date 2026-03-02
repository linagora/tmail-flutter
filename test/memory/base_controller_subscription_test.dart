import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Inline mocks (no build_runner required)
// ---------------------------------------------------------------------------
class _MockCachingManager extends Mock implements CachingManager {}
class _MockLanguageCacheManager extends Mock implements LanguageCacheManager {}
class _MockAuthorizationInterceptors extends Mock implements AuthorizationInterceptors {}
class _MockDynamicUrlInterceptors extends Mock implements DynamicUrlInterceptors {}
class _MockDeleteCredentialInteractor extends Mock implements DeleteCredentialInteractor {}
class _MockLogoutOidcInteractor extends Mock implements LogoutOidcInteractor {}
class _MockDeleteAuthorityOidcInteractor extends Mock implements DeleteAuthorityOidcInteractor {}
class _MockAppToast extends Mock implements AppToast {}
class _MockImagePaths extends Mock implements ImagePaths {}
class _MockResponsiveUtils extends Mock implements ResponsiveUtils {}
class _MockUuid extends Mock implements Uuid {}
class _MockToastManager extends Mock implements ToastManager {}
class _MockTwakeAppManager extends Mock implements TwakeAppManager {}

class _FakeFailure extends FeatureFailure {
  _FakeFailure() : super();
}

// A concrete BaseController subclass that counts onData() calls.
// We intentionally skip super.onData() to isolate the subscription lifecycle
// from platform-specific success/failure side effects.
class _SubscriptionAwareController extends BaseController {
  int onDataCallCount = 0;

  @override
  void onData(Either<Failure, Success> newState) {
    onDataCallCount++;
  }

  @override
  void handleSuccessViewState(Success success) {}
}

// ---------------------------------------------------------------------------
// Helper: register all BaseController dependencies in GetX DI
// ---------------------------------------------------------------------------
void _registerBaseControllerDependencies() {
  Get.testMode = true;
  Get.reset();

  final auth = _MockAuthorizationInterceptors();
  Get.put<CachingManager>(_MockCachingManager());
  Get.put<LanguageCacheManager>(_MockLanguageCacheManager());
  Get.put<AuthorizationInterceptors>(auth);
  Get.put<AuthorizationInterceptors>(auth, tag: BindingTag.isolateTag);
  Get.put<DynamicUrlInterceptors>(_MockDynamicUrlInterceptors());
  Get.put<DeleteCredentialInteractor>(_MockDeleteCredentialInteractor());
  Get.put<LogoutOidcInteractor>(_MockLogoutOidcInteractor());
  Get.put<DeleteAuthorityOidcInteractor>(_MockDeleteAuthorityOidcInteractor());
  Get.put<AppToast>(_MockAppToast());
  Get.put<ImagePaths>(_MockImagePaths());
  Get.put<ResponsiveUtils>(_MockResponsiveUtils());
  Get.put<Uuid>(_MockUuid());
  Get.put<ToastManager>(_MockToastManager());
  Get.put<TwakeAppManager>(_MockTwakeAppManager());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  setUp(_registerBaseControllerDependencies);
  tearDown(Get.reset);

  group('BaseController::consumeState::subscription lifecycle', () {
    test(
      'SHOULD untrack completed subscriptions\n'
      'WHEN a short-lived stream finishes\n'
      'SO THAT active-subscription tracking does not grow indefinitely',
    () async {
      // Arrange
      final controller = _SubscriptionAwareController();
      final streamCtrl = StreamController<Either<Failure, Success>>();

      // Act
      controller.consumeState(streamCtrl.stream);
      expect(controller.trackedStateSubscriptionCount, 1);

      streamCtrl.add(Left<Failure, Success>(_FakeFailure()));
      await Future.microtask(() {});
      await streamCtrl.close();
      await Future.microtask(() {});

      // Assert
      expect(
        controller.trackedStateSubscriptionCount,
        0,
        reason: 'Completed one-shot stream is still tracked as active',
      );
    });

    test(
      'SHOULD cancel the stream subscription\n'
      'WHEN onClose is called\n'
      'SO THAT events from long-lived streams are no longer delivered to onData',
    () async {
      // Arrange
      final controller = _SubscriptionAwareController();
      final streamCtrl = StreamController<Either<Failure, Success>>();

      controller.consumeState(streamCtrl.stream);
      expect(controller.trackedStateSubscriptionCount, 1);

      // Verify subscription is live before close
      streamCtrl.add(Left<Failure, Success>(_FakeFailure()));
      await Future.microtask(() {});

      expect(
        controller.onDataCallCount,
        1,
        reason: 'Baseline: event must reach onData while subscription is active',
      );

      // Act – close the controller
      controller.onClose();

      // Attempt to push another event; a leaked subscription would forward it
      streamCtrl.add(Left<Failure, Success>(_FakeFailure()));
      await Future.microtask(() {});
      await Future.microtask(() {}); // extra tick for any async propagation

      // Assert – count must remain 1
      expect(
        controller.onDataCallCount,
        1,
        reason: 'Stream subscription was not cancelled on onClose — memory leak detected',
      );

      await streamCtrl.close();
    });
  });
}
