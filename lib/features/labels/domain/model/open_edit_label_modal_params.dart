import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';

class OpenEditLabelModalParams with EquatableMixin {
  final Label selectedLabel;
  final AccountId accountId;
  final VerifyNameInteractor verifyNameInteractor;
  final CreateNewLabelInteractor createNewLabelInteractor;
  final EditLabelInteractor editLabelInteractor;

  const OpenEditLabelModalParams({
    required this.selectedLabel,
    required this.accountId,
    required this.verifyNameInteractor,
    required this.createNewLabelInteractor,
    required this.editLabelInteractor,
  });

  @override
  List<Object?> get props => [
        selectedLabel,
        accountId,
        verifyNameInteractor,
        createNewLabelInteractor,
        editLabelInteractor,
      ];
}
