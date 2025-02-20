
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_finders/patrol_finders.dart';

import 'patrol_tester_extension.dart';

extension PatrolFinderExtension on PatrolFinder {

  Future<void> enterTextWithoutTapAction(String text) async =>
    wrapWithPatrolLog(
      action: 'enterText',
      color: AnsiCodes.magenta,
      function: () => tester.enterTextWithoutTapAction(
        this,
        text,
        enablePatrolLog: false,
      ),
    );
}