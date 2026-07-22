import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';

class _FakeMailboxDashboardController extends Fake
    implements MailboxDashBoardController {
  _FakeMailboxDashboardController(this.emailUIAction);

  @override
  final Rxn<EmailUIAction> emailUIAction;
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
}
