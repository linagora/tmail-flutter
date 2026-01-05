import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';

extension HandleLabelActionTypeExtension on LabelController {
  void handleLabelActionType({
    required LabelActionType actionType,
    required AccountId? accountId,
    Label? label,
  }) {
    switch (actionType) {
      case LabelActionType.create:
        openCreateNewLabelModal(accountId);
        break;
      case LabelActionType.edit:
        break;
    }
  }
}
