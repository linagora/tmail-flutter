import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/email/domain/state/dismiss_twp_warning_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/dismiss_twp_warning_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/providers/twp_warning_dismiss_notifier.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'twp_warning_dismiss_notifier_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DismissTwpWarningInteractor>(),
  MockSpec<UrgentExceptionHandler>(),
])
void main() {
  late MockDismissTwpWarningInteractor mockInteractor;
  late ProviderContainer container;
  late TwpWarningDismiss notifier;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  final emailId = EmailId(Id('email-1'));
  const emailIdKey = 'email-1';
  const index = 0;

  Set<int> readState() => container.read(twpWarningDismissProvider(emailIdKey));

  void stubSuccess() {
    when(mockInteractor.execute(any, any, any, any)).thenAnswer(
      (_) => Stream.value(
        Right<Failure, Success>(DismissTwpWarningSuccess(emailId, index)),
      ),
    );
  }

  void stubFailure() {
    when(mockInteractor.execute(any, any, any, any)).thenAnswer(
      (_) => Stream.value(
        Left<Failure, Success>(DismissTwpWarningFailure(index: index)),
      ),
    );
  }

  setUp(() {
    mockInteractor = MockDismissTwpWarningInteractor();
    Get.put<DismissTwpWarningInteractor>(mockInteractor);

    container = ProviderContainer();
    // Keep the autoDispose provider alive for the duration of each test so
    // reads observe the same instance the notifier mutates.
    container.listen(
      twpWarningDismissProvider(emailIdKey),
      (_, __) {},
      fireImmediately: true,
    );
    notifier = container.read(twpWarningDismissProvider(emailIdKey).notifier);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group('TwpWarningDismiss', () {
    test('initial state is empty', () {
      expect(readState(), isEmpty);
    });

    test('dismiss adds the index optimistically before completion', () async {
      when(mockInteractor.execute(any, any, any, any)).thenAnswer((_) async* {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        yield Right<Failure, Success>(DismissTwpWarningSuccess(emailId, index));
      });

      final future = notifier.dismiss(session, accountId, emailId, index);

      // Optimistic update is applied synchronously before awaiting the backend.
      expect(readState(), contains(index));

      expect(await future, TwpWarningDismissResult.dismissed);
      expect(readState(), contains(index));
    });

    test('dismiss keeps the index and returns dismissed on success', () async {
      stubSuccess();

      final result = await notifier.dismiss(session, accountId, emailId, index);

      expect(result, TwpWarningDismissResult.dismissed);
      expect(readState(), contains(index));
      verify(
        mockInteractor.execute(session, accountId, emailId, index),
      ).called(1);
    });

    test(
      'dismiss rolls back and returns failed on a non-urgent failure',
      () async {
        stubFailure();

        final result = await notifier.dismiss(
          session,
          accountId,
          emailId,
          index,
        );

        expect(result, TwpWarningDismissResult.failed);
        expect(readState(), isEmpty);
      },
    );

    test(
      'dismiss rolls back and returns failed when the stream errors',
      () async {
        when(
          mockInteractor.execute(any, any, any, any),
        ).thenAnswer((_) => Stream.error(Exception('boom')));

        final result = await notifier.dismiss(
          session,
          accountId,
          emailId,
          index,
        );

        expect(result, TwpWarningDismissResult.failed);
        expect(readState(), isEmpty);
      },
    );

    test(
      'dismiss rolls back and returns failed when interactor is missing',
      () async {
        Get.reset();

        final result = await notifier.dismiss(
          session,
          accountId,
          emailId,
          index,
        );

        expect(result, TwpWarningDismissResult.failed);
        expect(readState(), isEmpty);
      },
    );

    test(
      'dismiss routes urgent exceptions centrally and returns urgentHandled',
      () async {
        final handler = MockUrgentExceptionHandler();
        when(handler.validateUrgentException(any)).thenReturn(true);
        Get.put<UrgentExceptionHandler>(handler);
        when(mockInteractor.execute(any, any, any, any)).thenAnswer(
          (_) => Stream.value(
            Left<Failure, Success>(
              DismissTwpWarningFailure(
                index: index,
                exception: Exception('401'),
              ),
            ),
          ),
        );

        final result = await notifier.dismiss(
          session,
          accountId,
          emailId,
          index,
        );

        expect(result, TwpWarningDismissResult.urgentHandled);
        expect(readState(), isEmpty);
        verify(
          handler.handleUrgentException(
            failure: anyNamed('failure'),
            exception: anyNamed('exception'),
          ),
        ).called(1);
      },
    );

    test(
      'dismissing an already dismissed index is a no-op returning dismissed',
      () async {
        stubSuccess();
        await notifier.dismiss(session, accountId, emailId, index);
        clearInteractions(mockInteractor);

        final result = await notifier.dismiss(
          session,
          accountId,
          emailId,
          index,
        );

        expect(result, TwpWarningDismissResult.dismissed);
        expect(readState(), contains(index));
        verifyNever(mockInteractor.execute(any, any, any, any));
      },
    );

    test('multiple distinct indexes accumulate in state', () async {
      stubSuccess();

      await notifier.dismiss(session, accountId, emailId, 0);
      await notifier.dismiss(session, accountId, emailId, 1);

      expect(readState(), containsAll(<int>[0, 1]));
    });
  });
}
