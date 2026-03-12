import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';

import '../../base/core_robot.dart';

class CreateLabelModalRobot extends CoreRobot {
  CreateLabelModalRobot(super.$);

  Future<void> enterNewLabelName(String name) async {
    await $(#label_name_input_field)
        .$(TextFieldBuilder)
        .enterText(name);
  }

  Future<void> enterNewLabelDescription(String description) async {
    await $(#label_description_input_field)
        .$(TextFieldBuilder)
        .enterText(description);
  }

  Future<void> tapPositiveActionButton(LabelActionType actionType) async {
    if (actionType == LabelActionType.create) {
      await $(CreateNewLabelModal).$(#create_label_button_action).tap();
    } else {
      await $(CreateNewLabelModal).$(#save_label_button_action).tap();
    }
  }
}
