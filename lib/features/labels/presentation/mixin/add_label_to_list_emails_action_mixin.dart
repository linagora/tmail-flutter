import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/choose_label_modal.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

mixin AddLabelToListEmailsActionMixin {
  Future<void> openChooseLabelModal({
    required List<Label> labels,
    required ImagePaths imagePaths,
  }) async {
    await DialogRouter().openDialogModal(
      child: ChooseLabelModal(
        labels: labels,
        onLabelAsToEmailsAction: (labels) {
          log(
            'AddLabelToListEmailsActionMixin::ChooseLabelModal::onLabelAsToEmailsAction: '
            'Selected labels is $labels',
          );
        },
        imagePaths: imagePaths,
      ),
      dialogLabel: 'choose-label-modal',
    );
  }
}
