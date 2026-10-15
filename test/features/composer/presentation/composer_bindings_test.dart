import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/mobile_composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/web_composer_bindings.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_session_cache_datasource_impl.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

import '../../../fixtures/account_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';

class _MockComposerController extends Mock implements ComposerController {
  ComposerReloadCacheAction? registeredReloadCacheAction;

  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});

  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});

  @override
  void registerReloadCacheAction(ComposerReloadCacheAction action) {
    registeredReloadCacheAction = action;
  }
}

class _MockEmailRepository extends Mock implements EmailRepository {}

class _MockComposerRepository extends Mock implements ComposerRepository {}

class _RefusingCheckSendingAllowedInteractor
    implements CheckSendingAllowedInteractor {
  @override
  Future<void> execute(Session session, AccountId accountId) async =>
      throw ForbiddenToSendException();
}

class _TestComposerView extends ComposerView {
  const _TestComposerView();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test(
    'registers native composer dependencies with the default GetX tag',
    () {
      ComposerBindings().dependencies();

      expect(Get.isPrepared<ComposerController>(), isTrue);
      expect(Get.isPrepared<ComposerController>(tag: 'tablet-composer'), isFalse);
    },
  );

  testWidgets(
    'ComposerView resolves the native composer controller without a tag',
    (tester) async {
      final controller = _MockComposerController();
      const view = _TestComposerView();
      Get.lazyPut<ComposerController>(() => controller);

      await tester.pumpWidget(const GetMaterialApp(home: view));

      expect(tester.takeException(), isNull);
      expect(view.controller, same(controller));
    },
  );

  test('registers reload cache handler only from web bindings', () {
    const webComposerId = 'web-composer';
    final webController = _MockComposerController();
    final mobileController = _MockComposerController();
    Get.put<ComposerSessionCacheDatasourceImpl>(
      ComposerSessionCacheDatasourceImpl(CacheExceptionThrower()),
      tag: webComposerId,
    );

    WebComposerBindings(composerId: webComposerId)
        .registerPlatformReloadCacheHandler(webController);
    MobileComposerBindings(composerId: 'mobile-composer')
        .registerPlatformReloadCacheHandler(mobileController);

    expect(webController.registeredReloadCacheAction, isNotNull);
    expect(mobileController.registeredReloadCacheAction, isNull);
  });

  test(
    'builds CreateNewAndSendEmailInteractor with the registered send check',
    () async {
      const composerId = 'composer-1';
      Get.put<EmailRepository>(_MockEmailRepository(), tag: composerId);
      Get.put<ComposerRepository>(_MockComposerRepository(), tag: composerId);
      Get.put<CheckSendingAllowedInteractor>(
        _RefusingCheckSendingAllowedInteractor(),
      );

      ComposerBindings(composerId: composerId).bindingsInteractor();

      final states = await Get.find<CreateNewAndSendEmailInteractor>(
        tag: composerId,
      )
          .execute(
            createEmailRequest: CreateEmailRequest(
              session: SessionFixtures.aliceSession,
              accountId: AccountFixtures.aliceAccountId,
              emailActionType: EmailActionType.compose,
              ownEmailAddress: 'alice@domain.tld',
              subject: 'subject',
              emailContent: 'content',
            ),
          )
          .toList();

      expect(
        states.last.fold((failure) => failure, (success) => success),
        isA<SendEmailFailure>().having(
          (failure) => failure.exception,
          'exception',
          isA<ForbiddenToSendException>(),
        ),
      );
    },
  );
}
