import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/dismiss_twp_warning_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/dismiss_twp_warning_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'dismiss_twp_warning_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EmailRepository>()])
void main() {
  late MockEmailRepository repository;
  late DismissTwpWarningInteractor interactor;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  final emailId = EmailId(Id('email-1'));
  const index = 1;

  setUp(() {
    repository = MockEmailRepository();
    interactor = DismissTwpWarningInteractor(repository);
  });

  group('DismissTwpWarningInteractor', () {
    test(
      'emits DismissTwpWarningSuccess with the email id and index',
      () async {
        when(
          repository.dismissTwpWarning(session, accountId, emailId, index),
        ).thenAnswer((_) async {});

        final state = await interactor
            .execute(session, accountId, emailId, index)
            .last;

        expect(
          state.fold((failure) => failure, (success) => success),
          DismissTwpWarningSuccess(emailId, index),
        );
        verify(
          repository.dismissTwpWarning(session, accountId, emailId, index),
        ).called(1);
      },
    );

    test(
      'emits DismissTwpWarningFailure carrying index and exception on error',
      () async {
        final exception = Exception('set failed');
        when(
          repository.dismissTwpWarning(session, accountId, emailId, index),
        ).thenThrow(exception);

        final state = await interactor
            .execute(session, accountId, emailId, index)
            .last;

        final failure = state.fold((f) => f, (_) => null);
        expect(failure, isA<DismissTwpWarningFailure>());
        expect((failure as DismissTwpWarningFailure).index, index);
        expect(failure.exception, exception);
      },
    );
  });
}
