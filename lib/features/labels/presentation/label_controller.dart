import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:labels/utils/labels_constants.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/state/create_new_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/edit_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_all_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_interactor_bindings.dart';
import 'package:tmail_ui_user/features/labels/presentation/mixin/label_context_menu_mixin.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_label_setting_state_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LabelController extends BaseController with LabelContextMenuMixin {
  final labels = <Label>[].obs;
  final labelListExpandMode = Rx(ExpandMode.EXPAND);
  final isLabelSettingEnabled = RxBool(false);

  GetAllLabelInteractor? _getAllLabelInteractor;
  CreateNewLabelInteractor? _createNewLabelInteractor;
  GetLabelSettingStateInteractor? _getLabelSettingStateInteractor;
  EditLabelInteractor? _editLabelInteractor;

  bool isLabelCapabilitySupported(Session session, AccountId accountId) {
    return LabelsConstants.labelsCapability.isSupported(session, accountId);
  }

  void checkLabelSettingState(AccountId accountId) {
    _getLabelSettingStateInteractor =
        getBinding<GetLabelSettingStateInteractor>();
    if (_getLabelSettingStateInteractor != null) {
      consumeState(_getLabelSettingStateInteractor!.execute(accountId));
    } else {
      isLabelSettingEnabled.value = false;
      _clearLabelData();
    }
  }

  void _clearLabelData() {
    labels.clear();
  }

  void injectLabelsBindings() {
    LabelInteractorBindings().dependencies();
    _getAllLabelInteractor = getBinding<GetAllLabelInteractor>();
    _createNewLabelInteractor = getBinding<CreateNewLabelInteractor>();
    _editLabelInteractor = getBinding<EditLabelInteractor>();
  }

  EditLabelInteractor? get editLabelInteractor => _editLabelInteractor;

  void getAllLabels(AccountId accountId) {
    if (_getAllLabelInteractor == null) return;

    consumeState(_getAllLabelInteractor!.execute(accountId));
  }

  void toggleLabelListState() {
    labelListExpandMode.value = labelListExpandMode.value == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;
  }

  Future<void> openCreateNewLabelModal(AccountId? accountId) async {
    if (accountId == null) {
      consumeState(
        Stream.value(Left(CreateNewLabelFailure(NotFoundAccountIdException()))),
      );
      return;
    }

    await DialogRouter().openDialogModal(
      child: CreateNewLabelModal(
        labels: labels,
        onCreateNewLabelCallback: (label) => _createNewLabel(accountId, label),
      ),
      dialogLabel: 'create-new-label-modal',
    );
  }

  void _createNewLabel(AccountId accountId, Label label) {
    log('LabelController::_createNewLabel:Label: $label');
    if (_createNewLabelInteractor == null) {
      consumeState(
        Stream.value(Left(CreateNewLabelFailure(InteractorNotInitialized()))),
      );
    } else {
      consumeState(_createNewLabelInteractor!.execute(accountId, label));
    }
  }

  void _handleCreateNewLabelSuccess(CreateNewLabelSuccess success) {
    toastManager.showMessageSuccess(success);
    _addLabelToList(success.newLabel);
  }

  void _handleCreateNewLabelFailure(CreateNewLabelFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void _addLabelToList(Label newLabel) {
    labels.add(newLabel);
    labels.sortByAlphabetically();
  }

  void _handleGetLabelSettingStateSuccess(bool isEnabled, AccountId accountId) {
    isLabelSettingEnabled.value = isEnabled;

    if (isEnabled) {
      injectLabelsBindings();
      getAllLabels(accountId);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAllLabelSuccess) {
      labels.value = success.labels..sortByAlphabetically();
    } else if (success is CreateNewLabelSuccess) {
      _handleCreateNewLabelSuccess(success);
    } else if (success is GetLabelSettingStateSuccess) {
      _handleGetLabelSettingStateSuccess(success.isEnabled, success.accountId);
    } else if (success is EditLabelSuccess) {
      handleEditLabelSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetAllLabelFailure) {
      labels.value = [];
    } else if (failure is CreateNewLabelFailure) {
      _handleCreateNewLabelFailure(failure);
    } else if (failure is GetLabelSettingStateFailure) {
      isLabelSettingEnabled.value = false;
      _clearLabelData();
    } else if (failure is EditLabelFailure) {
      handleEditLabelFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onClose() {
    _getAllLabelInteractor = null;
    _createNewLabelInteractor = null;
    _editLabelInteractor = null;
    _getLabelSettingStateInteractor = null;
    super.onClose();
  }
}
