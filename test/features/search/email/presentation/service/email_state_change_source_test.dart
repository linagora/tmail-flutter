import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';

class _FakeMailboxDashboardController extends Fake
    implements MailboxDashBoardController {
  _FakeMailboxDashboardController(this.emailUIAction, {this.currentEmailState});

  @override
  final Rxn<EmailUIAction> emailUIAction;

  @override
  jmap.State? currentEmailState;
}

void main() {
  test('emits only refresh email state changes from the dashboard stream',
      () async {
    final actions = Rxn<EmailUIAction>();
    final dashboard = _FakeMailboxDashboardController(actions);

    final source = DashboardEmailStateChangeSource(dashboard);
    final states = <jmap.State>[];
    final subscription = source.onEmailStateChanged.listen(states.add);
    addTearDown(subscription.cancel);
    final state = jmap.State('state-1');

    actions.value = EmailUIAction.idle;
    actions.value = RefreshChangeEmailAction(newState: state);
    actions.value = RefreshAllEmailAction();
    await pumpEventQueue();

    expect(states, [state]);
  });

  test('currentAppliedState reflects the dashboard current email state', () {
    final dashboard = _FakeMailboxDashboardController(
      Rxn<EmailUIAction>(),
      currentEmailState: jmap.State('state-1'),
    );

    final source = DashboardEmailStateChangeSource(dashboard);

    expect(source.currentAppliedState, jmap.State('state-1'));

    dashboard.currentEmailState = null;
    expect(source.currentAppliedState, isNull);
  });

  test('sources wrapping the same dashboard are equal', () {
    final dashboard = _FakeMailboxDashboardController(Rxn<EmailUIAction>());

    final first = DashboardEmailStateChangeSource(dashboard);
    final second = DashboardEmailStateChangeSource(dashboard);

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('sources wrapping different dashboards are not equal', () {
    final first = DashboardEmailStateChangeSource(
      _FakeMailboxDashboardController(Rxn<EmailUIAction>()),
    );
    final second = DashboardEmailStateChangeSource(
      _FakeMailboxDashboardController(Rxn<EmailUIAction>()),
    );

    expect(first, isNot(second));
  });
}
