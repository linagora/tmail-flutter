import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:flutter/material.dart' hide State;
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/labels.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/labels/domain/state/create_new_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/delete_a_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_all_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/delete_a_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_label_changes_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_websocket_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_interactor_bindings.dart';
import 'package:tmail_ui_user/features/labels/presentation/mixin/label_context_menu_mixin.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_label_setting_state_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LabelController extends BaseController
    with LabelContextMenuMixin {
  final RxList<Label> labels = <Label>[].obs;
  final labelListExpandMode = Rx(ExpandMode.EXPAND);
  final isLabelSettingEnabled = RxBool(false);
  final isLabelsLoaded = RxBool(false);
  final GlobalKey labelAppBarKey = GlobalKey();

  GetAllLabelInteractor? _getAllLabelInteractor;
  CreateNewLabelInteractor? _createNewLabelInteractor;
  GetLabelSettingStateInteractor? _getLabelSettingStateInteractor;
  EditLabelInteractor? _editLabelInteractor;
  DeleteALabelInteractor? _deleteALabelInteractor;
  GetLabelChangesInteractor? _getLabelChangesInteractor;

  WebSocketQueueHandler? _webSocketQueueHandler;
  State? _currentLabelState;
  AccountId? _accountId;
  Session? _session;
  LabelsCapability? _labelsCapability;

  @override
  void onInit() {
    _initWebSocketQueueHandler();
    super.onInit();
  }

  bool isLabelCapabilitySupported(Session session, AccountId accountId) {
    return LabelsConstants.labelsCapability.isSupported(session, accountId);
  }

  LabelsCapability? get labelsCapability => _labelsCapability;

  bool get shouldAskReadOnly {
    final labelVersion = labelsCapability?.version;
    return labelVersion != null && labelVersion >= 1;
  }

  void checkLabelSettingState(Session session, AccountId accountId) {
    _session = session;
    _accountId = accountId;
    _labelsCapability = _session?.getLabelsCapability(accountId);
    _getLabelSettingStateInteractor =
        getBinding<GetLabelSettingStateInteractor>();
    if (_getLabelSettingStateInteractor != null) {
      consumeState(_getLabelSettingStateInteractor!.execute(accountId));
    } else {
      _clearLabelData();
      setLabelLoaded();
    }
  }

  void setLabelLoaded() {
    isLabelsLoaded.value = true;
  }

  void _clearLabelData() {
    isLabelSettingEnabled.value = false;
    isLabelSettingEnabled.refresh();
    labels.clear();
    isLabelsLoaded.value = false;
  }

  void injectLabelsBindings() {
    LabelInteractorBindings().dependencies();
    _getAllLabelInteractor = getBinding<GetAllLabelInteractor>();
    _createNewLabelInteractor = getBinding<CreateNewLabelInteractor>();
    _editLabelInteractor = getBinding<EditLabelInteractor>();
    _deleteALabelInteractor = getBinding<DeleteALabelInteractor>();
    _getLabelChangesInteractor = getBinding<GetLabelChangesInteractor>();
  }

  DeleteALabelInteractor? get deleteALabelInteractor => _deleteALabelInteractor;

  GetLabelChangesInteractor? get getLabelChangesInteractor =>
      _getLabelChangesInteractor;

  WebSocketQueueHandler? get webSocketQueueHandler =>
      _webSocketQueueHandler;

  AccountId? get accountId => _accountId;

  Session? get session => _session;

  State? get currentLabelState => _currentLabelState;

  void setCurrentLabelState(State? newState) => _currentLabelState = newState;

  void _initWebSocketQueueHandler() {
    _webSocketQueueHandler = WebSocketQueueHandler(
      processMessageCallback: handleWebSocketMessage,
      onErrorCallback: onError,
    );
  }

  void getAllLabels(AccountId accountId) {
    if (_getAllLabelInteractor == null) {
      labels.value = [];
      setLabelLoaded();
      return;
    }

    consumeState(_getAllLabelInteractor!.execute(accountId));
  }

  void toggleLabelListState() {
    labelListExpandMode.value = labelListExpandMode.value == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;
  }

  Future<dynamic> openCreateNewLabelModal({
    required AccountId accountId,
    required VerifyNameInteractor verifyNameInteractor,
  }) async {
    return DialogRouter().openDialogModal(
      child: CreateNewLabelModal(
        key: const Key('create_new_label_modal'),
        labels: labels,
        accountId: accountId,
        imagePaths: imagePaths,
        verifyNameInteractor: verifyNameInteractor,
        createNewLabelInteractor: _createNewLabelInteractor!,
        editLabelInteractor: _editLabelInteractor!,
      ),
      dialogLabel: 'create-new-label-modal',
    );
  }

  Future<dynamic> openEditLabelModal({
    required Label selectedLabel,
    required AccountId accountId,
    required VerifyNameInteractor verifyNameInteractor,
  }) async {
    return DialogRouter().openDialogModal(
      child: CreateNewLabelModal(
        key: const Key('edit_label_modal'),
        labels: labels,
        accountId: accountId,
        imagePaths: imagePaths,
        selectedLabel: selectedLabel,
        actionType: LabelActionType.edit,
        verifyNameInteractor: verifyNameInteractor,
        createNewLabelInteractor: _createNewLabelInteractor!,
        editLabelInteractor: _editLabelInteractor!,
      ),
      dialogLabel: 'edit-label-modal',
    );
  }

  Future<void> onCreateALabelAction({
    required AccountId? accountId,
    OnLabelActionCallback? onLabelActionCallback,
    bool shouldPop = false,
  }) async {
    if (_createNewLabelInteractor == null || _editLabelInteractor == null) {
      _handleCreateNewLabelFailure(
        failure: CreateNewLabelFailure(const InteractorNotInitialized()),
        shouldPop: shouldPop,
      );
      return;
    }
    final verifyNameInteractor = getBinding<VerifyNameInteractor>();
    if (verifyNameInteractor == null) {
      _handleCreateNewLabelFailure(
        failure: CreateNewLabelFailure(const InteractorNotInitialized()),
        shouldPop: shouldPop,
      );
      return;
    }

    if (accountId == null) {
      _handleCreateNewLabelFailure(
        failure: CreateNewLabelFailure(NotFoundAccountIdException()),
        shouldPop: shouldPop,
      );
      return;
    }

    final resultState = await openCreateNewLabelModal(
      accountId: accountId,
      verifyNameInteractor: verifyNameInteractor,
    );

    if (resultState is CreateNewLabelSuccess) {
      _handleCreateNewLabelSuccess(
        success: resultState,
        onLabelActionCallback: onLabelActionCallback,
        shouldPop: shouldPop,
      );
    } else if (resultState is CreateNewLabelFailure) {
      _handleCreateNewLabelFailure(
        failure: resultState,
        shouldPop: shouldPop,
      );
    }
  }

  void _handleCreateNewLabelSuccess({
    required CreateNewLabelSuccess success,
    OnLabelActionCallback? onLabelActionCallback,
    bool shouldPop = false,
  }) {
    if (onLabelActionCallback == null && !shouldPop) {
      toastManager.showMessageSuccess(success);
    }
    _addLabelToList(success.newLabel);
    if (onLabelActionCallback != null) {
      onLabelActionCallback(success.newLabel);
    }
    if (shouldPop) {
      popBack(result: success.newLabel);
    }
  }

  void _handleCreateNewLabelFailure({
    required CreateNewLabelFailure failure,
    bool shouldPop = false,
  }) {
    toastManager.showMessageFailure(failure);
  }

  void _addLabelToList(Label newLabel) {
    labels.add(newLabel);
    labels.sortByAlphabetically();
  }

  void _handleGetLabelSettingStateSuccess(bool isEnabled, AccountId accountId) {
    updateLabelSettingEnabled(isEnabled, accountId);
  }

  void updateLabelSettingEnabled(bool isEnabled, AccountId accountId) {
    isLabelSettingEnabled.value = isEnabled;
    isLabelSettingEnabled.refresh();
    if (isEnabled) {
      injectLabelsBindings();
      getAllLabels(accountId);
    } else {
      _clearLabelData();
      setLabelLoaded();
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAllLabelSuccess) {
      labels.value = success.labels..sortByAlphabetically();
      setCurrentLabelState(success.newState);
      setLabelLoaded();
    } else if (success is GetLabelSettingStateSuccess) {
      _handleGetLabelSettingStateSuccess(success.isEnabled, success.accountId);
    } else if (success is DeleteALabelSuccess) {
      handleDeleteLabelSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetAllLabelFailure) {
      labels.value = [];
      setLabelLoaded();
    } else if (failure is GetLabelSettingStateFailure) {
      _clearLabelData();
      setLabelLoaded();
    } else if (failure is DeleteALabelFailure) {
      handleDeleteLabelFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onClose() {
    _getAllLabelInteractor = null;
    _createNewLabelInteractor = null;
    _editLabelInteractor = null;
    _deleteALabelInteractor = null;
    _getLabelSettingStateInteractor = null;
    _webSocketQueueHandler?.dispose();
    _webSocketQueueHandler = null;
    _currentLabelState = null;
    _accountId = null;
    _session = null;
    _labelsCapability = null;
    super.onClose();
  }
}
