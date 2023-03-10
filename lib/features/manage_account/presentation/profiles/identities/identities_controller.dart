
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_default_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/delete_identity_dialog_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentitiesController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final CreateNewIdentityInteractor _createNewIdentityInteractor;
  final CreateNewDefaultIdentityInteractor _createNewDefaultIdentityInteractor;
  final DeleteIdentityInteractor _deleteIdentityInteractor;
  final EditIdentityInteractor _editIdentityInteractor;
  final EditDefaultIdentityInteractor _editDefaultIdentityInteractor;

  final identitySelected = Rxn<Identity>();
  final listAllIdentities = <Identity>[].obs;

  late Worker accountIdWorker;

  IdentitiesController(
    this._getAllIdentitiesInteractor,
    this._deleteIdentityInteractor,
    this._createNewIdentityInteractor,
    this._editIdentityInteractor,
    this._createNewDefaultIdentityInteractor,
    this._editDefaultIdentityInteractor
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
          _handleGetAllIdentitiesSuccess(success);
        } else if (success is CreateNewIdentitySuccess) {
          _createNewIdentitySuccess(success);
        } else if (success is CreateNewDefaultIdentitySuccess) {
          _createNewDefaultIdentitySuccess(success);
        } else if (success is DeleteIdentitySuccess) {
          _deleteIdentitySuccess(success);
        } else if (success is EditIdentitySuccess) {
          _editIdentitySuccess(success);
        }
      }
    );
  }

  void _initWorker() {
    accountIdWorker = ever(_accountDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        _getAllIdentities(accountId);
      }
    });

    if (_accountDashBoardController.settingsPageLevel.value == SettingsPageLevel.level1) {
      _accountDashBoardController.accountId.refresh();
    }
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

    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      _getAllIdentities(accountId);
    }
  }

  void _handleGetAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    if (success.identities?.isNotEmpty == true) {
      final newListIdentities = success.identities!
        .where((identity) => identity.mayDelete == true)
        .toList();
      listAllIdentities.addAll(newListIdentities);
    }

    if (listAllIdentities.isNotEmpty) {
      selectIdentity(listAllIdentities.first);
    }
  }

  void selectIdentity(Identity? newIdentity) {
    identitySelected.value = newIdentity;
  }

  void goToCreateNewIdentity(BuildContext context) async {
    final accountId = _accountDashBoardController.accountId.value;
    final userProfile = _accountDashBoardController.userProfile.value;
    final session = _accountDashBoardController.sessionCurrent.value;
    if (accountId != null && session != null && userProfile != null) {
      final arguments = IdentityCreatorArguments(accountId, session, userProfile);

      if (BuildUtils.isWeb) {
        showDialogIdentityCreator(
            context: context,
            arguments: arguments,
            onCreatedIdentity: (arguments) {
              if (arguments is CreateNewIdentityRequest) {
                _createNewIdentityAction(accountId, arguments);
              } else if (arguments is EditIdentityRequest) {
                _editIdentityAction(accountId, arguments);
              }
            });
      } else {
        final newIdentityArguments = await push(
          AppRoutes.identityCreator,
          arguments: arguments);

        if (newIdentityArguments is CreateNewIdentityRequest) {
          _createNewIdentityAction(accountId, newIdentityArguments);
        } else if (newIdentityArguments is EditIdentityRequest) {
          _editIdentityAction(accountId, newIdentityArguments);
        }
      }
    }
  }

  void _createNewIdentityAction(
    AccountId accountId, 
    CreateNewIdentityRequest identityRequest
  ) async {
    if (identityRequest.isDefaultIdentity) {
       consumeState(_createNewDefaultIdentityInteractor.execute(accountId, identityRequest));
    } else {
      consumeState(_createNewIdentityInteractor.execute(accountId, identityRequest));
    }
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

  void _createNewDefaultIdentitySuccess(CreateNewDefaultIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: AppLocalizations.of(currentContext!).you_have_created_a_new_default_identity,
        icon: _imagePaths.icSelected);
    }

    _refreshAllIdentities();
  }

  void openConfirmationDialogDeleteIdentityAction(BuildContext context, Identity identity) {
    showDialog(
      context: context,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      builder: (BuildContext context) => DeleteIdentityDialogBuilder(
        responsiveUtils: _responsiveUtils,
        imagePaths: _imagePaths,
        onDeleteIdentityAction: () => _deleteIdentityAction(identity),
      ));
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

  void goToEditIdentity(BuildContext context, Identity identity) async {
    final accountId = _accountDashBoardController.accountId.value;
    final userProfile = _accountDashBoardController.userProfile.value;
    final session = _accountDashBoardController.sessionCurrent.value;
    if (accountId != null && session != null && userProfile != null) {
      final arguments = IdentityCreatorArguments(
          accountId,
          session,
          userProfile,
          identity: identity,
          actionType: IdentityActionType.edit);

      if (BuildUtils.isWeb) {
        showDialogIdentityCreator(
            context: context,
            arguments: arguments,
            onCreatedIdentity: (arguments) {
              if (arguments is CreateNewIdentityRequest) {
                _createNewIdentityAction(accountId, arguments);
              } else if (arguments is EditIdentityRequest) {
                _editIdentityAction(accountId, arguments);
              }
            });
      } else {
        final newIdentityArguments = await push(
          AppRoutes.identityCreator,
          arguments: arguments);

        if (newIdentityArguments is CreateNewIdentityRequest) {
          _createNewIdentityAction(accountId, newIdentityArguments);
        } else if (newIdentityArguments is EditIdentityRequest) {
          _editIdentityAction(accountId, newIdentityArguments);
        }
      }
    }
  }

  void _editIdentityAction(
    AccountId accountId, 
    EditIdentityRequest editIdentityRequest
  ) async {
    if (editIdentityRequest.isDefaultIdentity) {
      consumeState(_editDefaultIdentityInteractor.execute(accountId, editIdentityRequest));
    } else {
      consumeState(_editIdentityInteractor.execute(accountId, editIdentityRequest));
    }
  }

  void _editIdentitySuccess(EditIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).you_are_changed_your_identity_successfully,
          icon: _imagePaths.icSelected);
    }

    _refreshAllIdentities();
  }

  ImagePaths get imagePaths => _imagePaths;

  bool get isSignatureShow => identitySelected.value != null;
}