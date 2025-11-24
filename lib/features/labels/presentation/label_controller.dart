import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:labels/model/label.dart';
import 'package:labels/utils/labels_constants.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_all_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_interactor_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LabelController extends BaseController {
  final labels = <Label>[].obs;

  GetAllLabelInteractor? _getAllLabelInteractor;

  bool isLabelCapabilitySupported(Session session, AccountId accountId) {
    return LabelsConstants.labelsCapability.isSupported(session, accountId);
  }

  void injectLabelsBindings() {
    LabelInteractorBindings().dependencies();
    _getAllLabelInteractor = getBinding<GetAllLabelInteractor>();
  }

  void getAllLabels(AccountId accountId) {
    if (_getAllLabelInteractor == null) return;

    consumeState(_getAllLabelInteractor!.execute(accountId));
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAllLabelSuccess) {
      labels.value = success.labels;
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetAllLabelFailure) {
      labels.value = [];
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onClose() {
    _getAllLabelInteractor = null;
    super.onClose();
  }
}
