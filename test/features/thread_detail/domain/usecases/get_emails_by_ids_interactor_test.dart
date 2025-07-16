import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:model/email/email_property.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/exceptions/thread_detail_overload_exception.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'get_emails_by_ids_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadDetailRepository>()])
void main() {
  final repository = MockThreadDetailRepository();
  final getEmailsByIdsInteractor = GetEmailsByIdsInteractor(repository);

  group('get emails by ids interactor test:', () {
    test(
      'should throw ThreadDetailOverloadException '
      'when there are more than 1 emailIds '
      'and properties contains any of htmlBody, bodyValues or attachments',
    () async {
      // arrange
      final emailIds = [EmailId(Id('1')), EmailId(Id('2'))];
      final properties = Properties({
        EmailProperty.htmlBody,
        EmailProperty.bodyValues,
        EmailProperty.attachments,
      });
      final result = await getEmailsByIdsInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        emailIds,
        properties: properties,
      ).last;
      
      // assert
      expect(
        result.fold(
          (failure) => failure is GetEmailsByIdsFailure &&
            failure.exception is ThreadDetailOverloadException,
          (success) => false,
        ),
        true,
      );
    });
  });
}