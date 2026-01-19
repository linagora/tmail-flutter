import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';

extension UpdateLabelInAdvancedSearchExtension on AdvancedFilterController {
  void setSelectedLabel(Label? newLabel) {
    if (selectedLabel.value?.id == newLabel?.id) {
      selectedLabel.value = null;
    } else {
      selectedLabel.value = newLabel;
    }
  }
}
