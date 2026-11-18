import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/session_reload.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/session_reload_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_session_cleanup.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';

import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late FakeGetSessionInteractor getSessionInteractor;
  late ProviderContainer container;

  setUp(() {
    getSessionInteractor = FakeGetSessionInteractor()
      ..result = Right(GetSessionSuccess(DelegationFixtures.session(state: 'state-2')));
    Get.put<GetSessionInteractor>(getSessionInteractor);
    final now = DateTime(2026, 1, 1, 9);
    container = ProviderContainer(overrides: [sessionReloadClockProvider.overrideWithValue(() => now)]);
    DelegationFixtures.turnDelegationOn(container);
    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: Builder(builder: (builderContext) {
        context = builderContext;
        return const SizedBox();
      }),
    ));
    return context;
  }

  testWidgets('drops the last re-read and its resume throttle of the ended session', (tester) async {
    final context = await pumpContext(tester);
    container.read(sessionReloadProvider.notifier).reloadOnResume();
    await tester.pump();
    expect(container.read(sessionReloadProvider), isA<SessionReload>());

    endDelegationSession(context);
    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    container.read(sessionReloadProvider.notifier).reloadOnResume();
    await tester.pump();

    expect(getSessionInteractor.calls, 2);
  });

  testWidgets('clears the shown account', (tester) async {
    endDelegationSession(await pumpContext(tester));

    expect(container.read(activeAccountProvider), isNull);
    expect(container.read(sessionReloadProvider), isNull);
  });
}
