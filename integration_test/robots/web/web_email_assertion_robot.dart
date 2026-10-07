import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';

import '../email_assertion_robot.dart';
import '../../utils/wait_for_condition.dart';

class WebEmailAssertionRobot extends EmailAssertionRobot {
  WebEmailAssertionRobot(super.$);

  @override
  Future<void> expectLabelPickerVisible() async {
    // Web desktop: labels are listed in the hover submenu overlay, which is
    // wrapped in PointerInterceptor and not hit-testable.
    await waitForCondition(
      () => $(LabelListContextMenu).evaluate().isNotEmpty,
    );
  }
}
