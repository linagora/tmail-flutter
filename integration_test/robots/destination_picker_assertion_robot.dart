import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_destination_picker_assertion_robot.dart';

class DestinationPickerAssertionRobot extends CoreRobot
    implements AbstractDestinationPickerAssertionRobot {
  DestinationPickerAssertionRobot(super.$);

  @override
  Future<void> expectFolderVisible(PatrolFinder finder) async {
    await waitForCondition(() async {
      await $.pump();
      return finder.exists;
    });
  }

  @override
  void expectFolderAbsent(PatrolFinder finder) {
    expect(finder, findsNothing);
  }

  @override
  Future<void> expectPickerClosed() async {
    await waitForCondition(() async {
      await $.pump();
      return !$(DestinationPickerView).exists;
    });
  }
}
