import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/email_changes_properties.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_push_notification_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_changes_to_push_notification_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../../fixtures/state_fixtures.dart';

/// Minimal fake that only answers [getEmailChangesToPushNotification]; every
/// other [FCMRepository] member forwards to [noSuchMethod] (unused by tests).
class _FakeFCMRepository implements FCMRepository {
  final EmailsResponse emailsResponse;

  _FakeFCMRepository(this.emailsResponse);

  @override
  Future<EmailsResponse> getEmailChangesToPushNotification(
    Session session,
    AccountId accountId,
    jmap.State currentState, {
    EmailChangesProperties? properties,
  }) async =>
      emailsResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final userName = UserName('alice@domain.tld');

  test(
    'should emit a growable email list when the JMAP response has no emails '
    'so that a downstream clear() does not throw on a fixed-length list',
    () async {
      final interactor = GetEmailChangesToPushNotificationInteractor(
        _FakeFCMRepository(const EmailsResponse(emailList: null)),
      );

      final states = await interactor
          .execute(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            userName,
            StateFixtures.currentEmailState,
          )
          .toList();

      final success = states
              .lastWhere((either) => either.isRight())
              .fold((_) => null, (success) => success)
          as GetEmailChangesToPushNotificationSuccess;

      expect(success.emailList, isEmpty);
      expect(() => success.emailList.clear(), returnsNormally);
    },
  );
}
