
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_finders/patrol_finders.dart';

extension PatrolFinderExtension on PatrolTester {

  Future<void> enterTextWithoutTapAction(
    Finder finder,
    String text,
    {
      bool enablePatrolLog = true,
    }
  ) {
    return TestAsyncUtils.guard(
      () => wrapWithPatrolLog(
        action: 'enterText',
        value: text,
        finder: finder,
        color: AnsiCodes.magenta,
        enablePatrolLog: enablePatrolLog,
        function: () async {
          final resolvedFinder = await waitUntilVisible(
            finder,
            enablePatrolLog: false,
          );
          await tester.enterText(resolvedFinder.first, text);
          await _performPump();
        },
      ),
    );
  }

  Future<void> _performPump() async {
    final settle = config.settlePolicy;
    final timeout = config.settleTimeout;
    if (settle == SettlePolicy.trySettle) {
      await pumpAndTrySettle(
        timeout: timeout,
      );
    } else if (settle == SettlePolicy.settle) {
      await pumpAndSettle(
        timeout: timeout,
      );
    } else {
      await tester.pump();
    }
  }
}