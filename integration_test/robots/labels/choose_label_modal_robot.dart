import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/choose_label_modal.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/no_label_yet_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';

class ChooseLabelModalRobot extends CoreRobot {
  ChooseLabelModalRobot(super.$);

  Future<void> tapCreateALabelButton() async {
    await $(ChooseLabelModal)
        .$(find.text(AppLocalizations().createALabel))
        .tap();
  }

  Future<void> tapLabelByName(String name) async {
    final item = $(ChooseLabelModal).$(LabelListItem).$(name);
    await $.scrollUntilVisible(finder: item);
    await item.tap();
  }

  Future<void> tapAddLabelButton() async {
    await $(ChooseLabelModal)
        .$(find.text(AppLocalizations().addLabel))
        .tap();
  }

  bool get isNoLabelYetWidgetVisible =>
      $(ChooseLabelModal).$(NoLabelYetWidget).visible;

  bool get isLabelListVisible =>
      $(ChooseLabelModal).$(LabelListItem).visible;
}
