import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/sending_message_dialog_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../../fixtures/widget_fixtures.dart';
import 'sending_message_dialog_view_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CreateNewAndSendEmailInteractor>(),
])
void main() {
  final interactor = MockCreateNewAndSendEmailInteractor();

  final createEmailRequest = CreateEmailRequest(
    session: SessionFixtures.aliceSession,
    accountId: AccountFixtures.aliceAccountId,
    emailActionType: EmailActionType.editDraft,
    ownEmailAddress: SessionFixtures.aliceSession.getOwnEmailAddressOrEmpty(),
    subject: 'subject',
    emailContent: 'emailContent',
  );

  Widget buildDialog() {
    return WidgetFixtures.makeTestableWidget(
      child: SendingMessageDialogView(
        createEmailRequest: createEmailRequest,
        createNewAndSendEmailInteractor: interactor,
      ),
    );
  }

  setUp(() {
    reset(interactor);
  });

  group('SendingMessageDialogView', () {
    testWidgets(
      'should show the sending progress without a Cancel button '
      'while the email is being sent',
      (tester) async {
        // arrange: keep the stream on the loading states so the dialog
        // stays open (terminal states pop the dialog back).
        when(interactor.execute(
          createEmailRequest: anyNamed('createEmailRequest'),
        )).thenAnswer((_) => Stream.fromIterable([
          Right<Failure, Success>(GenerateEmailLoading()),
          Right<Failure, Success>(SendEmailLoading()),
        ]));

        // act
        await tester.pumpWidget(buildDialog());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // assert: the dialog renders its progress UI ...
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        // ... but never offers a Cancel button (the removed behaviour).
        expect(find.text(AppLocalizations().cancel), findsNothing);
        expect(find.text(AppLocalizations().canceling), findsNothing);
      },
    );
  });
}
