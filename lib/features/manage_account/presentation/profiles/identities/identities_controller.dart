
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
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
import 'package:tmail_ui_user/features/manage_account/domain/state/transform_html_signature_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/transform_html_signature_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/delete_identity_dialog_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentitiesController extends BaseController {

  final accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final CreateNewIdentityInteractor _createNewIdentityInteractor;
  final CreateNewDefaultIdentityInteractor _createNewDefaultIdentityInteractor;
  final DeleteIdentityInteractor _deleteIdentityInteractor;
  final EditIdentityInteractor _editIdentityInteractor;
  final EditDefaultIdentityInteractor _editDefaultIdentityInteractor;
  final TransformHtmlSignatureInteractor _transformHtmlSignatureInteractor;

  final identitySelected = Rxn<Identity>();
  final signatureSelected = Rxn<String>();
  final listAllIdentities = <Identity>[].obs;

  IdentitiesController(
    this._getAllIdentitiesInteractor,
    this._deleteIdentityInteractor,
    this._createNewIdentityInteractor,
    this._editIdentityInteractor,
    this._createNewDefaultIdentityInteractor,
    this._editDefaultIdentityInteractor,
    this._transformHtmlSignatureInteractor
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    super.onInit();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
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
    } else if (success is TransformHtmlSignatureSuccess) {
      signatureSelected.value = success.signature;
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is DeleteIdentityFailure) {
      _deleteIdentityFailure(failure);
    }
  }

  void _registerObxStreamListener() {
    ever(accountDashBoardController.accountId, (accountId) {
      final session = accountDashBoardController.sessionCurrent;
      if (accountId != null && session != null) {
        _getAllIdentities(session, accountId);
      }
    });
  }

  void _getAllIdentities(Session session, AccountId accountId) {
    consumeState(_getAllIdentitiesInteractor.execute(session, accountId));
  }

  void _refreshAllIdentities() {
    identitySelected.value = null;
    listAllIdentities.clear();

    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      _getAllIdentities(session, accountId);
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
    signatureSelected.value = null;
    identitySelected.value = newIdentity;

    if (newIdentity != null) {
      consumeState(_transformHtmlSignatureInteractor.execute(newIdentity.signatureAsString));
    }
  }

  void goToCreateNewIdentity(BuildContext context) async {
    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = IdentityCreatorArguments(accountId, session);

      final newIdentityArguments = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.identityCreator, arguments: arguments)
        : await push(AppRoutes.identityCreator, arguments: arguments);

      if (newIdentityArguments is CreateNewIdentityRequest) {
        _createNewIdentityAction(session, accountId, newIdentityArguments);
      } else if (newIdentityArguments is EditIdentityRequest) {
        _editIdentityAction(session, accountId, newIdentityArguments);
      }
    }
  }

  void _createNewIdentityAction(
    Session session,
    AccountId accountId, 
    CreateNewIdentityRequest identityRequest
  ) async {
    if (identityRequest.isDefaultIdentity) {
      consumeState(_createNewDefaultIdentityInteractor.execute(session, accountId, identityRequest));
    } else {
      consumeState(_createNewIdentityInteractor.execute(session, accountId, identityRequest));
    }
  }

  void _createNewIdentitySuccess(CreateNewIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).you_have_created_a_new_identity);
    }

    _refreshAllIdentities();
  }

  void _createNewDefaultIdentitySuccess(CreateNewDefaultIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).you_have_created_a_new_default_identity);
    }

    _refreshAllIdentities();
  }

  void openConfirmationDialogDeleteIdentityAction(BuildContext context, Identity identity) {
    Get.dialog(
      DeleteIdentityDialogBuilder(
        responsiveUtils: responsiveUtils,
        imagePaths: imagePaths,
        onDeleteIdentityAction: () => _deleteIdentityAction(identity),
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void _deleteIdentityAction(Identity identity) {
    popBack();

    final session = accountDashBoardController.sessionCurrent;
    final accountId = accountDashBoardController.accountId.value;
    if (accountId != null && session != null && identity.id != null) {
      consumeState(_deleteIdentityInteractor.execute(session, accountId, identity.id!));
    }
  }

  void _deleteIdentitySuccess(DeleteIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).identity_has_been_deleted,
        leadingSVGIcon: imagePaths.icDeleteToast);
    }

    _refreshAllIdentities();
  }

  void _deleteIdentityFailure(DeleteIdentityFailure failure) {
    if (currentContext != null) {
      Get.dialog(
        (ConfirmDialogBuilder(imagePaths)
            ..key(const Key('dialog_message_delete_identity_failed'))
            ..title(AppLocalizations.of(currentContext!).delete_failed)
            ..addIcon(SvgPicture.asset(imagePaths.icDeleteDialogFailed, fit: BoxFit.fill))
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
            ..onConfirmButtonAction('${AppLocalizations.of(currentContext!).got_it}!', () => popBack()))
          .build(),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void goToEditIdentity(BuildContext context, Identity identity) async {
    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = IdentityCreatorArguments(
        accountId,
        session,
        identity: identity,
        actionType: IdentityActionType.edit);

      final newIdentityArguments = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.identityCreator, arguments: arguments)
        : await push(AppRoutes.identityCreator, arguments: arguments);

      if (newIdentityArguments is CreateNewIdentityRequest) {
        _createNewIdentityAction(session, accountId, newIdentityArguments);
      } else if (newIdentityArguments is EditIdentityRequest) {
        _editIdentityAction(session, accountId, newIdentityArguments);
      }
    }
  }

  void _editIdentityAction(
    Session session,
    AccountId accountId,
    EditIdentityRequest editIdentityRequest
  ) async {
    if (editIdentityRequest.isDefaultIdentity) {
      consumeState(_editDefaultIdentityInteractor.execute(session, accountId, editIdentityRequest));
    } else {
      consumeState(_editIdentityInteractor.execute(session, accountId, editIdentityRequest));
    }
  }

  void _editIdentitySuccess(EditIdentitySuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).you_are_changed_your_identity_successfully);
    }

    _refreshAllIdentities();
  }

  bool get isSignatureShow => identitySelected.value != null;
}