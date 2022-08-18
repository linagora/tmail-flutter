import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_forward_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';

class ForwardController extends BaseController {

  final GetForwardInteractor _getForwardInteractor;

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final listForwards = <String>[].obs;

  ForwardController(
    this._getForwardInteractor,
  );

  @override
  void onDone() {
    viewState.value.fold((failure) {}, (success) {
      if (success is GetForwardSuccess) {
        if (success.forward.forwards.isNotEmpty) {
          listForwards.addAll(success.forward.forwards);
        }
      }
    });
  }

  @override
  void onError(error) {}

  @override
  void onInit() {
    _getForward();
    super.onInit();
  }

  void _getForward() {
    consumeState(_getForwardInteractor.execute(_accountDashBoardController.accountId.value!));
  }

  void deleteEmailForward(String emailForward) {
    //TODO: deleteEmailForward
  }
}