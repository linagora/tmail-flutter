
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentitiesController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final CreateNewIdentityInteractor _createNewIdentityInteractor;
  final Uuid _uuid;
  final DeleteIdentityInteractor _deleteIdentityInteractor;

  final identitySelected = Rxn<Identity>();
  final listIdentities = <Identity>[].obs;

  IdentitiesController(
    this._getAllIdentitiesInteractor,
    this._deleteIdentityInteractor,
  );
  IdentitiesController(
    this._getAllIdentitiesInteractor,
    this._createNewIdentityInteractor,
    this._uuid,
  );

  @override
  void onInit() {
    _onAccountDashBoardListener();
    super.onInit();
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
              listIdentities.value = success.identities ?? [];
              setIdentityDefault();
            }
          } else if (success is CreateNewIdentitySuccess) {
            _createNewIdentitySuccess(success);
          } else if (success is DeleteIdentitySuccess) {
            _deleteIdentitySuccess(success);
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

  void setIdentityDefault() {
    try {
      final identityDefault = listIdentities.firstWhere((identity) => identity.mayDelete == false);
      selectIdentity(identityDefault);
    } catch (exception) {
      selectIdentity(listIdentities.first);
    }
  }

  void selectIdentity(Identity? newIdentity) {
    identitySelected.value = newIdentity;
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

    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      _getAllIdentities(accountId);
    }
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

    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      _getAllIdentities(accountId);
    }
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
}