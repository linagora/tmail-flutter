import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';

class CreateLabelModalRobot extends CoreRobot {
  CreateLabelModalRobot(super.$);

  Future<void> enterNewLabelName(String name) async {
    await $(CreateNewLabelModal)
        .$(LabelInputFieldBuilder)
        .$(TextFieldBuilder)
        .enterText(name);
  }

  Future<void> tapSaveButton() async {
    await $(CreateNewLabelModal).$(AppLocalizations().save).tap();
  }
}
