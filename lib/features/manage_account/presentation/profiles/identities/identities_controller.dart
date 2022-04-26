
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';

class IdentitiesController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;

  final identitySelected = Rxn<Identity>();
  final listIdentities = <Identity>[].obs;

  IdentitiesController(this._getAllIdentitiesInteractor);

  @override
  void onInit() {
    _onAccountDashBoardListener();
    super.onInit();
  }

  @override
  void onDone() {
    viewState.value.fold(
        (failure) {},
        (success) {
          if (success is GetAllIdentitiesSuccess) {
            if (success.identities?.isNotEmpty == true) {
              listIdentities.value = success.identities ?? [];
              selectIdentity(listIdentities.first);
            }
          }
        }
    );
  }

  @override
  void onError(error) {
  }

  void _onAccountDashBoardListener() {
    _accountDashBoardController.accountId.listen((accountId) {
      log('IdentitiesController::_onAccountDashBoardListener(): accountId: $accountId');
      if (accountId != null) {
        _getAllIdentities(accountId);
      }
    });
  }

  void _getAllIdentities(AccountId accountId) {
    consumeState(_getAllIdentitiesInteractor.execute(accountId));
  }

  void selectIdentity(Identity? newIdentity) {
    identitySelected.value = newIdentity;
  }
}