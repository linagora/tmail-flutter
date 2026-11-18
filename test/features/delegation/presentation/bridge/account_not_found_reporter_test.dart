import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/account_not_found_reporter.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote/method_level_exception.dart';

import '../../../../fixtures/account_switch_fakes.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  group('isAccountNotFound', () {
    test('matches an accountNotFound method error', () {
      expect(isAccountNotFound(MethodLevelErrors(ErrorMethodResponse.accountNotFound)), isTrue);
    });

    test('matches an accountNotFound method response', () {
      expect(isAccountNotFound(ErrorMethodResponseException(AccountNotFoundMethodResponse())), isTrue);
    });

    test('SHOULD NOT match another method error', () {
      expect(isAccountNotFound(MethodLevelErrors(ErrorMethodResponse.accountNotSupportedByMethod)), isFalse);
    });

    test('SHOULD NOT match another method response', () {
      expect(isAccountNotFound(ErrorMethodResponseException(AccountNotSupportedByMethod())), isFalse);
    });

    test('SHOULD NOT match another exception or none', () {
      expect(isAccountNotFound(Exception('offline')), isFalse);
      expect(isAccountNotFound(null), isFalse);
    });
  });

  group('RiverpodAccountNotFoundReporter', () {
    late ProviderContainer container;
    late FakeGetSessionInteractor getSessionInteractor;

    setUp(() {
      getSessionInteractor = FakeGetSessionInteractor()
        ..result = Right(GetSessionSuccess(DelegationFixtures.session(state: 'state-2')));
      Get.put<GetSessionInteractor>(getSessionInteractor);
      container = ProviderContainer();
      DelegationFixtures.turnDelegationOn(container);
      container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    });

    tearDown(() {
      container.dispose();
      Get.reset();
    });

    test('re-reads the session while a delegated mailbox is shown', () async {
      await container
          .read(accountSwitchProvider.notifier)
          .switchTo(DelegationFixtures.bobAccountId, FakeAccountSwitchView());

      RiverpodAccountNotFoundReporter(container).reportAccountNotFound();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 1);
    });
  });
}
