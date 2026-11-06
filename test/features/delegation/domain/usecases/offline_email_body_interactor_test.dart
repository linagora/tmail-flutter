import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_new_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_opened_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_list_new_email_interator.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_new_receive_email_from_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_new_receive_email_from_notification_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final session = DelegationFixtures.session();
  final mine = DelegationFixtures.aliceAccountId;
  final delegated = DelegationFixtures.bobAccountId;
  final email = DetailedEmail(
    emailId: EmailId(Id('email-1')),
    createdTime: DateTime.utc(2026),
  );

  group('offline email bodies', () {
    test('StoreOpenedEmailInteractor stores mine and skips a delegated account', () async {
      final repository = _Emails();
      final interactor = StoreOpenedEmailInteractor(repository);

      final delegatedEvents = await interactor.execute(session, delegated, email).toList();
      final mineEvents = await interactor.execute(session, mine, email).toList();

      expect(delegatedEvents, isEmpty);
      expect(mineEvents.map((event) => event.fold((_) => null, (success) => success)),
          contains(isA<StoreOpenedEmailSuccess>()));
      expect(repository.stores, 1);
    });

    test('StoreListNewEmailInteractor stores mine and skips a delegated account', () async {
      final repository = _Emails();
      final interactor = StoreListNewEmailInteractor(repository);

      final delegatedEvents = await interactor.execute(session, delegated, {}).toList();
      final mineEvents = await interactor.execute(session, mine, {}).toList();

      expect(delegatedEvents, isEmpty);
      expect(
        mineEvents.map((event) => event.fold((_) => null, (success) => success)),
        contains(isA<StoreNewEmailSuccess>()),
      );
    });

    test('new-email download runs for mine and skips a delegated account', () async {
      final emails = _Emails();
      final pushes = _Pushes();
      final interactor = GetNewReceiveEmailFromNotificationInteractor(pushes, emails);

      final delegatedEvents = await interactor.execute(
        session: session,
        accountId: delegated,
        userName: session.username,
        newState: jmap.State('state-2'),
      ).toList();
      final mineEvents = await interactor.execute(
        session: session,
        accountId: mine,
        userName: session.username,
        newState: jmap.State('state-2'),
      ).toList();

      expect(delegatedEvents, isEmpty);
      expect(emails.stateReads, 1);
      expect(pushes.downloads, 0);
      expect(
        mineEvents.map((event) => event.fold((failure) => failure, (success) => success)),
        contains(isA<GetNewReceiveEmailFromNotificationFailure>()),
      );
    });
  });
}

class _Emails extends Fake implements EmailRepository {
  int stores = 0;
  int stateReads = 0;

  @override
  Future<void> storeOpenedEmail(
    Session session,
    AccountId accountId,
    DetailedEmail detailedEmail,
  ) async {
    stores++;
  }

  @override
  Future<DetailedEmail> getStoredOpenedEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
  ) async {
    throw StateError('missing');
  }

  @override
  Future<jmap.State?> getEmailState(Session session, AccountId accountId) async {
    stateReads++;
    return null;
  }
}

class _Pushes extends Fake implements FCMRepository {
  int downloads = 0;

  @override
  Future<List<EmailId>> getNewReceiveEmailFromNotification(
    Session session,
    AccountId accountId,
    jmap.State currentState,
  ) async {
    downloads++;
    return const [];
  }
}
