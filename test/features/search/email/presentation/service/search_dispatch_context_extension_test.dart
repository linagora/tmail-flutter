import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context_extension.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';

class _FakeDashboard extends Fake implements MailboxDashBoardController {
  _FakeDashboard({
    required Session? session,
    required AccountId? accountId,
    required this.trashSpamMailboxIds,
  })  : _session = session,
        _accountId = Rxn<AccountId>(accountId);

  final Session? _session;
  final Rxn<AccountId> _accountId;

  @override
  final Set<MailboxId>? trashSpamMailboxIds;

  @override
  Session? get sessionCurrent => _session;

  @override
  Rxn<AccountId> get accountId => _accountId;
}

void main() {
  test('buildSearchDispatchContext copies the dashboard session fields', () {
    final trashSpam = <MailboxId>{MailboxId(Id('trash-1'))};
    final dashboard = _FakeDashboard(
      session: SessionFixtures.aliceSession,
      accountId: AccountFixtures.aliceAccountId,
      trashSpamMailboxIds: trashSpam,
    );

    final context = dashboard.buildSearchDispatchContext(collapseThreads: true);

    expect(context, isNotNull);
    expect(context!.session, SessionFixtures.aliceSession);
    expect(context.accountId, AccountFixtures.aliceAccountId);
    expect(context.collapseThreads, isTrue);
    expect(context.trashSpamMailboxIds, trashSpam);
    expect(context.properties, isNotNull);
  });

  test('buildSearchDispatchContext returns null when session is missing', () {
    final dashboard = _FakeDashboard(
      session: null,
      accountId: AccountFixtures.aliceAccountId,
      trashSpamMailboxIds: null,
    );

    expect(
      dashboard.buildSearchDispatchContext(collapseThreads: false),
      isNull,
    );
  });

  test('buildSearchDispatchContext returns null when account is missing', () {
    final dashboard = _FakeDashboard(
      session: SessionFixtures.aliceSession,
      accountId: null,
      trashSpamMailboxIds: null,
    );

    expect(
      dashboard.buildSearchDispatchContext(collapseThreads: false),
      isNull,
    );
  });
}
