import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_result.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_executor_provider.dart';
import 'package:tmail_ui_user/features/search/email/presentation/providers/search_refresh_providers.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/email_state_change_source.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';

import '../../../../../fixtures/account_fixtures.dart';
import '../../../../../fixtures/session_fixtures.dart';

/// Supplies only what the refresh wiring reads: the action stream the state
/// source adapts, plus the session fields the dispatch context is built from.
class _FakeDashboard extends Mock implements MailboxDashBoardController {
  // Get.put drives the GetX lifecycle, which reads these directly rather than
  // through noSuchMethod.
  @override
  final InternalFinalCallback<void> onStart =
      InternalFinalCallback<void>(callback: () {});

  @override
  final InternalFinalCallback<void> onDelete =
      InternalFinalCallback<void>(callback: () {});

  @override
  final Rxn<EmailUIAction> emailUIAction = Rxn<EmailUIAction>();

  @override
  final Rxn<AccountId> accountId = Rxn<AccountId>();

  @override
  Session? sessionCurrent;

  @override
  Set<MailboxId>? get trashSpamMailboxIds => null;
}

class _RecordingExecutor extends SearchExecutorService {
  _RecordingExecutor(this._ownContainer) : super(_ownContainer);

  final ProviderContainer _ownContainer;

  int dispatchCount = 0;

  @override
  Future<SearchExecutionResult> dispatch(
    SearchExecutionIntent intent,
    SearchDispatchContext context,
  ) async {
    dispatchCount++;
    return SearchExecutionResult.success;
  }

  void disposeContainer() {
    dispose();
    _ownContainer.dispose();
  }
}

/// Covers the production refresh wiring end to end — the real gate predicate
/// reading the real [searchViewStateProvider], and the real dispatch-context
/// resolution off the bound dashboard.
///
/// search_refresh_coordinator_test.dart injects the gate as a stub, so it can
/// only prove the coordinator honours whatever predicate it is handed. It
/// cannot catch the wiring handing over the wrong one — which is exactly the
/// defect these tests exist to pin.
void main() {
  late _FakeDashboard dashboard;
  late _RecordingExecutor executor;
  late ProviderContainer container;

  setUp(() {
    dashboard = _FakeDashboard()
      ..sessionCurrent = SessionFixtures.aliceSession
      ..accountId.value = AccountFixtures.aliceAccountId;
    // _resolveDispatchContext looks the dashboard up through getBinding.
    Get.put<MailboxDashBoardController>(dashboard);

    executor = _RecordingExecutor(ProviderContainer());
    container = ProviderContainer(overrides: [
      dashboardEmailStateChangeSourceProvider
          .overrideWithValue(DashboardEmailStateChangeSource(dashboard)),
      searchExecutorServiceProvider.overrideWithValue(executor),
    ]);
    // Reading the provider is what builds the coordinator and subscribes it.
    container.read(searchRefreshCoordinatorProvider);
  });

  tearDown(() {
    container.dispose();
    executor.disposeContainer();
    Get.reset();
  });

  void emitStateChange(String state) {
    dashboard.emailUIAction.value =
        RefreshChangeEmailAction(newState: jmap.State(state));
  }

  test(
    'refreshes on the SearchEmailView entry path — simple search activated '
    'without the dashboard search bar ever being enabled',
    () async {
      // goToSearchView() activates simple search and routes to SearchEmailView.
      container.read(searchViewStateProvider.notifier).activateSimpleSearch();

      emitStateChange('state-1');
      await pumpEventQueue();

      expect(executor.dispatchCount, 1);
    },
  );

  test('refreshes while advanced search is running', () async {
    container.read(searchViewStateProvider.notifier).activateAdvancedSearch();

    emitStateChange('state-1');
    await pumpEventQueue();

    expect(executor.dispatchCount, 1);
  });

  test('does not refresh when no search is running', () async {
    emitStateChange('state-1');
    await pumpEventQueue();

    expect(executor.dispatchCount, 0);
  });

  test('stops refreshing once the search is deactivated', () async {
    container.read(searchViewStateProvider.notifier).activateSimpleSearch();
    emitStateChange('state-1');
    await pumpEventQueue();

    container.read(searchViewStateProvider.notifier).deactivateSimpleSearch();
    emitStateChange('state-2');
    await pumpEventQueue();

    expect(executor.dispatchCount, 1);
  });

  test('does not refresh once the dashboard binding is gone', () async {
    container.read(searchViewStateProvider.notifier).activateSimpleSearch();
    Get.reset();

    emitStateChange('state-1');
    await pumpEventQueue();

    expect(executor.dispatchCount, 0);
  });
}
