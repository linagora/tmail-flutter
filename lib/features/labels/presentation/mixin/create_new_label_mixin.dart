
import 'package:core/presentation/resources/image_paths.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/state/create_new_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/mixin/label_modal_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';

mixin CreateNewLabelMixin on LabelModalMixin {
  Future<Label?> createNewLabelWithResultAction({
    required List<Label> allLabels,
    required ImagePaths imagePaths,
    required AccountId? accountId,
    required VerifyNameInteractor verifyNameInteractor,
    required CreateNewLabelInteractor? createNewLabelInteractor,
    required EditLabelInteractor? editLabelInteractor,
  }) async {
    if (createNewLabelInteractor == null ||
        editLabelInteractor == null ||
        accountId == null) {
      return null;
    }

    final resultState = await openCreateNewLabelModal(
      labels: allLabels,
      accountId: accountId,
      imagePaths: imagePaths,
      verifyNameInteractor: verifyNameInteractor,
      createNewLabelInteractor: createNewLabelInteractor,
      editLabelInteractor: editLabelInteractor,
    );

    if (resultState is CreateNewLabelSuccess) {
      return resultState.newLabel;
    }

    return null;
  }
}