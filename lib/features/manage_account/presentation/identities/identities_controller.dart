
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/identity_request_dto_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_handler.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/state/get_identity_cache_on_web_state.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/get_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/remove_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/restore_identity_cache_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identity_signature.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_default_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/transform_list_signature_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_default_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_identity_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/transform_list_signature_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/update_own_email_address_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/list_identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/delete_identity_dialog_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/public_asset/domain/extensions/string_to_public_asset_extension.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/remove_identity_from_public_assets_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/clean_up_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/remove_identity_from_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/clean_up_public_assets_interactor_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentitiesController extends ReloadableController implements BeforeReconnectHandler {

  final accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final CreateNewIdentityInteractor _createNewIdentityInteractor;
  final CreateNewDefaultIdentityInteractor _createNewDefaultIdentityInteractor;
  final DeleteIdentityInteractor _deleteIdentityInteractor;
  final EditIdentityInteractor _editIdentityInteractor;
  final EditDefaultIdentityInteractor _editDefaultIdentityInteractor;
  final TransformListSignatureInteractor _transformListSignatureInteractor;
  final SaveIdentityCacheOnWebInteractor _saveIdentityCacheOnWebInteractor;

  final identitySelected = Rxn<Identity>();
  final signatureSelected = Rxn<String>();
  final listAllIdentities = <Identity>[].obs;
  final mapIdentitySignatures = <IdentityId, String>{}.obs;
  final identitiesViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final signatureViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  dynamic newIdentityArguments;
  ScrollController? listIdentityScrollController;

  final _beforeReconnectManager = Get.find<BeforeReconnectManager>();

  IdentitiesController(
    this._getAllIdentitiesInteractor,
    this._deleteIdentityInteractor,
    this._createNewIdentityInteractor,
    this._editIdentityInteractor,
    this._createNewDefaultIdentityInteractor,
    this._editDefaultIdentityInteractor,
    this._transformListSignatureInteractor,
    this._saveIdentityCacheOnWebInteractor
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    RestoreIdentityCacheInteractorBindings().dependencies();
    _beforeReconnectManager.addListener(onBeforeReconnect);
    if (PlatformInfo.isWeb) {
      listIdentityScrollController = ScrollController();
    }
    super.onInit();
  }

  @override
  void onReady() {
    identitiesViewState.value = Right(GetAllIdentitiesLoading());
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAllIdentitiesSuccess) {
      _handleGetAllIdentitiesSuccess(success);
    } if (success is GetAllIdentitiesLoading) {
      identitiesViewState.value = Right(success);
    } else if (success is CreateNewIdentitySuccess) {
      _createNewIdentitySuccess(success);
    } else if (success is CreateNewDefaultIdentitySuccess) {
      _createNewDefaultIdentitySuccess(success);
    } else if (success is DeleteIdentitySuccess) {
      _deleteIdentitySuccess(success);
    } else if (success is EditIdentitySuccess) {
      _editIdentitySuccess(success);
    } else if (success is TransformListSignatureLoading) {
      signatureViewState.value = Right(success);
    } else if (success is TransformListSignatureSuccess) {
      signatureViewState.value = Right(success);
      _syncMapIdentitySignatures(success.identitySignatures);
    } else if (success is RemoveIdentityFromPublicAssetsSuccessState) {
      _deleteIdentityAction(success.identityId);
    } else if (success is GetIdentityCacheOnWebSuccess) {
      _openIdentityEditorFromCache(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetAllIdentitiesFailure) {
      identitiesViewState.value = Left(failure);
    } else if (failure is DeleteIdentityFailure) {
      _deleteIdentityFailure(failure);
    } else if (failure is RemoveIdentityFromPublicAssetsFailureState) {
      _deleteIdentityAction(failure.identityId);
    } else if (failure is NotFoundAnyPublicAssetsFailureState) {
      _deleteIdentityAction(failure.identityId);
    } else if (failure is GetIdentityCacheOnWebFailure) {
      _removeIdentityCache();
    } else if (failure is GetAllIdentitiesFailure) {
      accountDashBoardController.synchronizeOwnEmailAddress(
        accountDashBoardController.sessionCurrent?.getUserDisplayName() ?? '',
      );
    } else if (failure is TransformListSignatureFailure) {
      signatureViewState.value = Left(failure);
      _syncMapIdentitySignatures(failure.identitySignatures);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  void _registerObxStreamListener() {
    ever(accountDashBoardController.accountId, (accountId) {
      final session = accountDashBoardController.sessionCurrent;
      if (accountId != null && session != null) {
        _getAllIdentities(session, accountId);
        _injectCleanUpPublicAssetsInteractorBindings(session, accountId);
        _handleIdentityCache();
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
    identitiesViewState.value = Right(success);

    final listIdentities = success.identities ?? [];
    accountDashBoardController.updateOwnEmailAddressFromIdentities(listIdentities);

    final newListIdentities = listIdentities.where(_validateIdentity).toList();

    if (newListIdentities.isEmpty) return;

    listAllIdentities.addAll(newListIdentities);

    identitySelected.value = listAllIdentities.first;

    _transformSignature();
  }
  
  bool _validateIdentity(Identity identity) {
    return identity.mayDelete == true &&
        identity.name?.trim().isNotEmpty == true;
  }

  void _transformSignature() {
    final listIdentitySignature = listAllIdentities.toListIdentitySignature();
    consumeState(_transformListSignatureInteractor.execute(listIdentitySignature));
  }

  void _syncMapIdentitySignatures(List<IdentitySignature> identitySignatures) {
    mapIdentitySignatures.value = Map.fromEntries(
      identitySignatures.map((identitySignature) => MapEntry(
        identitySignature.identityId,
        identitySignature.signature,
      )),
    );
  }

  void goToCreateNewIdentity(BuildContext context) async {
    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = IdentityCreatorArguments(accountId, session);

      newIdentityArguments = PlatformInfo.isWeb
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
    _removeIdentityCache();

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).you_have_created_a_new_identity);
    }

    _cleanUpPublicAssets(
      success.newIdentity.id,
      IdentityActionType.create,
      success.publicAssetsInIdentityArguments);

    _refreshAllIdentities();
  }

  void _createNewDefaultIdentitySuccess(CreateNewDefaultIdentitySuccess success) {
    _removeIdentityCache();

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).you_have_created_a_new_default_identity);
    }

    _cleanUpPublicAssets(
      success.newIdentity.id,
      IdentityActionType.create,
      success.publicAssetsInIdentityArguments);

    _refreshAllIdentities();
  }

  void openConfirmationDialogDeleteIdentityAction(BuildContext context, Identity identity) {
    Get.dialog(
      DeleteIdentityDialogBuilder(
        responsiveUtils: responsiveUtils,
        imagePaths: imagePaths,
        onDeleteIdentityAction: () => _dereferencePublicAssets(identity),
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void _deleteIdentityAction(IdentityId identityId) {
    final session = accountDashBoardController.sessionCurrent;
    final accountId = accountDashBoardController.accountId.value;
    if (accountId != null && session != null) {
      consumeState(_deleteIdentityInteractor.execute(session, accountId, identityId));
    } else {
      consumeState(Stream.value(Left(DeleteIdentityFailure(null))));
    }
  }

  Future<void> _dereferencePublicAssets(
    Identity identity
  ) async {
    popBack();

    final session = accountDashBoardController.sessionCurrent;
    final accountId = accountDashBoardController.accountId.value;
    final identityId = identity.id;

    final publicAssetIds = identity
      .signatureAsString
      .publicAssetIdsFromHtmlContent;
    final removeIdentityFromPublicAssetsInteractor = getBinding<RemoveIdentityFromPublicAssetsInteractor>(
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);

    // if there is no identityId, even the delete action will fail
    if (identityId == null) return;

    if (session == null
      || accountId == null
      || removeIdentityFromPublicAssetsInteractor == null
      || publicAssetIds.isEmpty) 
    {
      consumeState(Stream.value(Left(RemoveIdentityFromPublicAssetsFailureState(identityId: identityId))));
    } else {
      consumeState(removeIdentityFromPublicAssetsInteractor.execute(
        session,
        accountId,
        identityId: identityId,
        publicAssetIds: publicAssetIds
      ));
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
        ConfirmationDialogBuilder(
          key: const Key('dialog_message_delete_identity_failed'),
          imagePath: imagePaths,
          title: AppLocalizations.of(currentContext!).delete_failed,
          confirmText: '${AppLocalizations.of(currentContext!).got_it}!',
          onConfirmButtonAction: popBack,
          onCloseButtonAction: popBack,
        ),
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

      newIdentityArguments = PlatformInfo.isWeb
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
    _removeIdentityCache();

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).you_are_changed_your_identity_successfully);
    }

    _cleanUpPublicAssets(
      success.identityId,
      IdentityActionType.edit,
      success.publicAssetsInIdentityArguments);

    _refreshAllIdentities();
  }

  bool get isSignatureShow => identitySelected.value != null;

  void _injectCleanUpPublicAssetsInteractorBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapPublicAsset]);
      CleanUpPublicAssetsInteractorBindings().dependencies();
    } catch(e) {
      logError('$runtimeType::injectCleanUpPublicAssetsInteractorBindings(): exception: $e');
    }
  }

  void _cleanUpPublicAssets(
    IdentityId? identityId,
    IdentityActionType? identityActionType,
    PublicAssetsInIdentityArguments? publicAssetsInIdentityArguments) {
    final session = accountDashBoardController.sessionCurrent;
    final accountId = accountDashBoardController.accountId.value;

    if (session == null
      || accountId == null
      || identityId == null
      || identityActionType == null
      || publicAssetsInIdentityArguments == null) {
      return;
    }
    
    final cleanUpPublicAssetsInteractor = getBinding<CleanUpPublicAssetsInteractor>(
      tag: BindingTag.cleanUpPublicAssetsInteractorBindingsTag);
    if (cleanUpPublicAssetsInteractor == null) return;
    consumeState(cleanUpPublicAssetsInteractor.execute(
      session,
      accountId,
      identityId: identityId,
      identityActionType: identityActionType,
      publicAssetsInIdentityArguments: publicAssetsInIdentityArguments));
  }

  @override
  void handleReloaded(Session session) {
    log('IdentitiesController::handleReloaded:');
    _handleIdentityCache();
  }

  Future<void> _openIdentityEditorFromCache(GetIdentityCacheOnWebSuccess success) async {
    final identityCache = success.identityCache;
    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;
    if (identityCache == null || accountId == null || session == null) return;

    final arguments = IdentityCreatorArguments(
      accountId,
      session,
      identity: identityCache.identity,
      isDefault: identityCache.isDefault,
      publicAssetsInIdentityArguments: identityCache.publicAssetsInIdentityArguments,
      actionType: identityCache.identityActionType);

    newIdentityArguments = PlatformInfo.isWeb
      ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.identityCreator, arguments: arguments)
      : await push(AppRoutes.identityCreator, arguments: arguments);

    if (newIdentityArguments == null) {
      _removeIdentityCache();
    }

    if (newIdentityArguments is CreateNewIdentityRequest) {
      _createNewIdentityAction(session, accountId, newIdentityArguments);
    } else if (newIdentityArguments is EditIdentityRequest) {
      _editIdentityAction(session, accountId, newIdentityArguments);
    }
  }

  void _handleIdentityCache() {
    final session = accountDashBoardController.sessionCurrent;
    final accountId = accountDashBoardController.accountId;
    if (session == null
      || accountId.value == null
      || !PlatformInfo.isWeb) {
      return;
    }
    
    final getIdentityCacheOnWebInteractor = getBinding<GetIdentityCacheOnWebInteractor>(
      tag: BindingTag.restoreIdentityCacheInteractorBindingsTag);
    if (getIdentityCacheOnWebInteractor == null) return;

    consumeState(getIdentityCacheOnWebInteractor.execute(
      accountId.value!,
      session.username));
  }

  void _removeIdentityCache() {
    final removeIdentityCacheOnWebInteractor = getBinding<RemoveIdentityCacheOnWebInteractor>(
      tag: BindingTag.restoreIdentityCacheInteractorBindingsTag);
    if (removeIdentityCacheOnWebInteractor == null) return;
    consumeState(removeIdentityCacheOnWebInteractor.execute());
  }

  Future<void> _saveIdentityCacheOnWebAction(dynamic requestArgument) async {
    final session = accountDashBoardController.sessionCurrent;
    final accountId = accountDashBoardController.accountId;
    if (accountId.value == null || session?.username == null) return;

    IdentityCache? identityCache;

    switch (requestArgument) {
      case (CreateNewIdentityRequest createNewIdentityRequest):
        identityCache = IdentityCache(
          identity: createNewIdentityRequest.newIdentity,
          identityActionType: IdentityActionType.create,
          isDefault: createNewIdentityRequest.isDefaultIdentity,
          publicAssetsInIdentityArguments: createNewIdentityRequest.publicAssetsInIdentityArguments);
        break;
      case (EditIdentityRequest editIdentityRequest):
        identityCache = IdentityCache(
          identity: editIdentityRequest.identityRequest.toIdentityWithId(editIdentityRequest.identityId),
          identityActionType: IdentityActionType.edit,
          isDefault: editIdentityRequest.isDefaultIdentity,
          publicAssetsInIdentityArguments: editIdentityRequest.publicAssetsInIdentityArguments);
        break;
      default:
        break;
    }

    if (identityCache == null) return;
  
    consumeState(_saveIdentityCacheOnWebInteractor.execute(
      accountId.value!,
      session!.username,
      identityCache: identityCache
    ));
  }

  @override
  Future<void> onBeforeReconnect() => _saveIdentityCacheOnWebAction(newIdentityArguments);

  @override
  void onClose() {
    CleanUpPublicAssetsInteractorBindings().close();
    RestoreIdentityCacheInteractorBindings().close();
    newIdentityArguments = null;
    _beforeReconnectManager.removeListener(onBeforeReconnect);
    if (PlatformInfo.isWeb) {
      listIdentityScrollController?.dispose();
    }
    super.onClose();
  }
}