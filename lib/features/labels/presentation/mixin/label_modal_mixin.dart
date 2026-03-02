import 'package:core/presentation/resources/image_paths.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/choose_label_modal.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

mixin LabelModalMixin {
  Future<void> openChooseLabelModal({
    required List<Label> labels,
    required ImagePaths imagePaths,
    required OnSelectLabelsAction onSelectLabelsAction,
    required OnCreateALabelAction onCreateALabelAction,
  }) async {
    return DialogRouter().openDialogModal(
      child: ChooseLabelModal(
        labels: labels,
        onSelectLabelsAction: onSelectLabelsAction,
        imagePaths: imagePaths,
        onCreateALabelAction: onCreateALabelAction,
      ),
      dialogLabel: 'choose-label-modal',
    );
  }
}
