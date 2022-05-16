
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/identity_extension.dart';
import 'package:model/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class IdentitiesController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final CreateNewIdentityInteractor _createNewIdentityInteractor;
  final Uuid _uuid;
  final DeleteIdentityInteractor _deleteIdentityInteractor;
  final EditIdentityInteractor _editIdentityInteractor;

  final identitySelected = Rxn<Identity>();
  final listAllIdentities = <Identity>[].obs;
  final listSelectedIdentities = <Identity>[].obs;

  final idIdentityAll = IdentityId(Id('all'));

  late Worker accountIdWorker;

  IdentitiesController(
    this._getAllIdentitiesInteractor,
    this._deleteIdentityInteractor,
    this._createNewIdentityInteractor,
    this._uuid,
    this._editIdentityInteractor,
  );

  @override
  void onInit() {
    _initWorker();
    super.onInit();
  }

  @override
  void onClose() {
    _clearWorker();
    super.onClose();
  }

  @override
  void onDone() {
    viewState.value.fold(
        (failure) {
          if (failure is DeleteIdentityFailure) {
            _deleteIdentityFailure(failure);
          }
        },
        (success) {
          if (success is GetAllIdentitiesSuccess) {
            if (success.identities?.isNotEmpty == true) {
              _addNewIdentityAsAll();
              final newListIdentities = success.identities!;
              newListIdentities.sortByMayDelete();
              listAllIdentities.addAll(newListIdentities);
              setIdentityDefault();
            }
          } else if (success is CreateNewIdentitySuccess) {
            _createNewIdentitySuccess(success);
          } else if (success is DeleteIdentitySuccess) {
            _deleteIdentitySuccess(success);
          } else if (success is EditIdentitySuccess) {
            _editIdentitySuccess(success);
          }
        }
    );
  }

  @override
  void onError(error) {
  }

  void _initWorker() {
    accountIdWorker = ever(_accountDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        _getAllIdentities(accountId);
      }
    });
  }

  void _clearWorker() {
    accountIdWorker.call();
  }

  void _getAllIdentities(AccountId accountId) {
    consumeState(_getAllIdentitiesInteractor.execute(accountId));
  }

  void _refreshAllIdentities() {
    identitySelected.value = null;
    listAllIdentities.clear();
    listSelectedIdentities.clear();

    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      _getAllIdentities(accountId);
    }
  }

  void _addNewIdentityAsAll() {
    if (currentContext != null) {
      listAllIdentities.add(Identity(
          id: idIdentityAll,
          name: AppLocalizations.of(currentContext!).all_identities));
    }
  }

  void setIdentityDefault() {
    try {
      final identityDefault = listAllIdentities.firstWhere((identity) => identity.mayDelete == false);
      selectIdentity(identityDefault);
    } catch (exception) {
      selectIdentity(listAllIdentities.first);
    }
  }

  void selectIdentity(Identity? newIdentity) {
    identitySelected.value = newIdentity;
    if (newIdentity != null) {
      _updateListSelectedIdentities(newIdentity);
    }
  }

  void _updateListSelectedIdentities(Identity newIdentity) {
    if (newIdentity.id == idIdentityAll) {
      listSelectedIdentities.value = listAllIdentities.sublist(1);
    } else  {
      listSelectedIdentities.value = [newIdentity];
    }
  }

  void goToCreateNewIdentity() async {
    final accountId = _accountDashBoardController.accountId.value;
    final userProfile = _accountDashBoardController.userProfile.value;
    if (accountId != null && userProfile != null) {
      final newIdentity = await push(
          AppRoutes.IDENTITY_CREATOR,
          arguments: IdentityCreatorArguments(accountId, userProfile));

      if (newIdentity != null && newIdentity is Identity) {
        final generateCreateId = Id(_uuid.v1());
        _createNewIdentityAction(
            accountId,
            CreateNewIdentityRequest(generateCreateId, newIdentity));
      }
    }
  }

  void _createNewIdentityAction(AccountId accountId, CreateNewIdentityRequest identityRequest) async {
    consumeState(_createNewIdentityInteractor.execute(accountId, identityRequest));
  }

  void _createNewIdentitySuccess(CreateNewIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).you_have_created_a_new_identity,
          icon: _imagePaths.icSelected);
    }

    _refreshAllIdentities();
  }

  void openConfirmationDialogDeleteIdentityAction(BuildContext context, Identity identity) {
    popBack();

    if (_responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(AppLocalizations.of(context).message_confirmation_dialog_delete_identity)
          ..onCancelAction(AppLocalizations.of(context).cancel, () =>
              popBack())
          ..onConfirmAction(AppLocalizations.of(context).delete, () =>
              _deleteIdentityAction(identity)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_delete_identity'))
              ..title(AppLocalizations.of(context).delete_identity.capitalizeFirstEach)
              ..content(AppLocalizations.of(context).message_confirmation_dialog_delete_identity)
              ..addIcon(SvgPicture.asset(_imagePaths.icDeleteDialogIdentity, fit: BoxFit.fill))
              ..marginIcon(EdgeInsets.zero)
              ..styleTitle(const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.colorActionDeleteConfirmDialog))
              ..styleContent(const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColor.colorContentEmail))
              ..colorCancelButton(AppColor.colorButtonCancelDialog)
              ..colorConfirmButton(AppColor.colorActionDeleteConfirmDialog)
              ..styleTextConfirmButton(const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white))
              ..styleTextCancelButton(const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColor.colorTextButton))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
                  _deleteIdentityAction(identity))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
                  popBack()))
            .build());
    }
  }

  void _deleteIdentityAction(Identity identity) {
    popBack();

    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null && identity.id != null) {
      consumeState(_deleteIdentityInteractor.execute(accountId, identity.id!));
    }
  }

  void _deleteIdentitySuccess(DeleteIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).identity_has_been_deleted,
          icon: _imagePaths.icDeleteToast);
    }

    _refreshAllIdentities();
  }

  void _deleteIdentityFailure(DeleteIdentityFailure failure) {
    if (currentContext != null) {
      showDialog(
          context: currentContext!,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('dialog_message_delete_identity_failed'))
              ..title(AppLocalizations.of(context).delete_failed)
              ..addIcon(SvgPicture.asset(_imagePaths.icDeleteDialogFailed, fit: BoxFit.fill))
              ..marginIcon(EdgeInsets.zero)
              ..styleTitle(const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black))
              ..colorConfirmButton(AppColor.colorTextButton)
              ..paddingTitle(const EdgeInsets.symmetric(vertical: 12))
              ..styleTextConfirmButton(const TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction('${AppLocalizations.of(context).got_it}!', () => popBack()))
            .build());
    }
  }

  void goToEditIdentity(Identity identity) async {
    popBack();

    final accountId = _accountDashBoardController.accountId.value;
    final userProfile = _accountDashBoardController.userProfile.value;
    if (accountId != null && userProfile != null) {
      final newIdentity = await push(
          AppRoutes.IDENTITY_CREATOR,
          arguments: IdentityCreatorArguments(
              accountId,
              userProfile,
              identity: identity,
              actionType: IdentityActionType.edit));

      if (newIdentity is Identity) {
        log('IdentitiesController::goToEditIdentity(): $newIdentity');
        _editIdentityAction(accountId, EditIdentityRequest(
            identityId: identity.id!,
            identityRequest: newIdentity.toIdentityRequest()
        ));
      }
    }
  }

  void _editIdentityAction(AccountId accountId, EditIdentityRequest editIdentityRequest) async {
    log('IdentitiesController::_editIdentityAction(): $editIdentityRequest');
    consumeState(_editIdentityInteractor.execute(accountId, editIdentityRequest));
  }

  void _editIdentitySuccess(EditIdentitySuccess success) {
    log('IdentitiesController::_editIdentitySuccess(): $success');
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).you_are_changed_your_identity_successfully,
          icon: _imagePaths.icSelected);
    }

    _refreshAllIdentities();
  }
}