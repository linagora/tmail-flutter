import 'dart:async';

import 'package:async/async.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/domain/extensions/string_to_public_asset_extension.dart';
import 'package:tmail_ui_user/features/public_asset/domain/state/create_public_asset_state.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/create_public_asset_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/utils/identity_creator_constants.dart';
import 'package:tmail_ui_user/features/public_asset/domain/usecase/delete_public_assets_interactor.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/model/public_asset_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef PublicAssetId = Id;

class PublicAssetController extends BaseController {
  PublicAssetController(
    this._uploadAttachmentInteractor,
    this._createPublicAssetInteractor,
    this._deletePublicAssetsInteractor,
    {required this.arguments}
  );

  final UploadAttachmentInteractor _uploadAttachmentInteractor;
  final CreatePublicAssetInteractor _createPublicAssetInteractor;
  final DeletePublicAssetsInteractor _deletePublicAssetsInteractor;
  final PublicAssetArguments? arguments;

  List<PublicAssetId> preExistingPublicAssetIds = [];
  List<PublicAssetId> newlyPickedPublicAssetIds = [];
  final _publicAssetStreamGroup = StreamGroup<Either<Failure, Success>>();
  StreamSubscription<Either<Failure, Success>>? _publicAssetStreamSubscription;
  final isUploading = false.obs;

  Session? get session => arguments?.session;
  AccountId? get accountId => arguments?.accountId;
  Identity? get identity => arguments?.identity;

  static const String _backButtonInterceptorName = 'PublicAssetControllerBackButtonInterceptor';

  void _handleUploadState(Either<Failure, Success> uploadState) {
    log('PublicAssetController::handleUploadState::${uploadState.runtimeType}');
    uploadState.fold(
      (failure) => consumeState(Stream.value(Left(CreatePublicAssetFailureState()))),
      (success) {
        log('PublicAssetController::handleUploadState::success::$success');
        if (success is SuccessAttachmentUploadState) {
          final filePath = success.fileInfo.filePath;
          if (PlatformInfo.isMobile && filePath != null) {
            getBinding<FileUtils>()?.deleteCompressedFileOnMobile(
              filePath,
              pathContains: IdentityCreatorConstants.prefixCompressedInlineImageTemp);
          }

          final blobId = success.attachment.blobId;
          if (session == null
            || accountId == null
            || blobId == null) {
              consumeState(Stream.value(Left(CreatePublicAssetFailureState())));
              return;
            }

          consumeState(_createPublicAssetInteractor.execute(
            session!,
            accountId!,
            blobId: blobId,
            identityId: identity?.id));
        }
      }
    );
  }

  @override
  void onInit() {
    super.onInit();
    _publicAssetStreamSubscription = _publicAssetStreamGroup.stream.listen(_handleUploadState);
    BackButtonInterceptor.add((_, __) {
      discardChanges();
      return false;
    }, name: _backButtonInterceptorName);
  }

  @override
  void onClose() {
    preExistingPublicAssetIds.clear();
    newlyPickedPublicAssetIds.clear();
    _publicAssetStreamSubscription?.cancel();
    _publicAssetStreamGroup.close();
    BackButtonInterceptor.removeByName(_backButtonInterceptorName);
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is UploadAttachmentSuccess) {
      _handleUploadAttachmentSuccess(success);
    } else if (success is CreatePublicAssetSuccessState) {
      _handleCreatePublicAssetSuccessState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is CreatePublicAssetFailureState) {
      _handleCreatePublicAssetFailureState();
    } else if (failure is PublicAssetOverQuotaFailureState) {
      _handlePublicAssetOverQuotaFailureState(failure);
    } else if (failure is UploadAttachmentFailure) {
      _handleUploadAttachmentFailure(failure);
    }
  }

  @override
  void handleUrgentExceptionOnWeb({Failure? failure, Exception? exception}) {
    super.handleUrgentExceptionOnWeb(failure: failure, exception: exception);
    if (failure is UploadAttachmentFailure) {
      isUploading.value = false;
    }
  }

  void _handlePublicAssetOverQuotaFailureState(PublicAssetOverQuotaFailureState failure) {
    isUploading.value = false;
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        failure.publicAssetQuotaExceededException.message
          ?? AppLocalizations.of(currentContext!).generalSignatureImageUploadError);
    }
  }

  void _handleCreatePublicAssetFailureState() {
    isUploading.value = false;
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).generalSignatureImageUploadError);
    }
  }

  void _handleUploadAttachmentFailure(UploadAttachmentFailure failure) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastErrorMessage(
          currentOverlayContext!,
          failure.fileInfo.isInline == true
              ? AppLocalizations.of(currentContext!).thisImageCannotBeAdded
              : AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments,
          leadingSVGIconColor: Colors.white,
          leadingSVGIcon: failure.fileInfo.isInline == true
              ? imagePaths.icInsertImage
              : imagePaths.icAttachment
      );
    }
  }

  Future<void> _handleUploadAttachmentSuccess(UploadAttachmentSuccess success) async {
    await _publicAssetStreamGroup.add(success.uploadAttachment.progressState);
  }

  void _handleCreatePublicAssetSuccessState(CreatePublicAssetSuccessState success) {
    isUploading.value = false;
    final publicAsset = success.publicAsset;
    if (publicAsset.id == null || publicAsset.publicURI == null) return;

    newlyPickedPublicAssetIds.add(publicAsset.id!);
    final imageTag = '<img '
      'src="${publicAsset.publicURI!}" '
      'style="max-width: 100%;" '
      'public-asset-id="${publicAsset.id!.value}">';
    if (PlatformInfo.isWeb) {
      Get
        .find<IdentityCreatorController>()
        .richTextWebController
        ?.editorController
        .insertHtml(imageTag);
    } else {
      Get
        .find<IdentityCreatorController>()
        .richTextMobileTabletController
        ?.htmlEditorApi
        ?.insertHtml(imageTag);
    }
  }

  void getOldPublicAssetFromHtmlContent(String htmlContent) {
    preExistingPublicAssetIds = htmlContent.publicAssetIdsFromHtmlContent;
  }

  void restorePreExistingPublicAssetsFromCache(List<PublicAssetId> publicAssetIds) {
    preExistingPublicAssetIds = publicAssetIds;
  }

  void restoreNewlyPickedPublicAssetsFromCache(List<PublicAssetId> publicAssetIds) {
    newlyPickedPublicAssetIds = publicAssetIds;
  }

  void uploadFileToBlob(PlatformFile platformFile) {
    isUploading.value = true;
    _uploadFileToBlobAction(platformFile);
  }

  void _uploadFileToBlobAction(PlatformFile platformFile) {
    if (session == null || accountId == null) return;

    final fileInfo = platformFile.toFileInfo();
    try {
      final uploadUri = session!.getUploadUri(accountId!, jmapUrl: dynamicUrlInterceptors.jmapUrl);
      consumeState(_uploadAttachmentInteractor.execute(fileInfo, uploadUri));
    } catch (e) {
      log('PublicAssetController::_uploadFileToBlobAction: $e');
      consumeState(Stream.value(Left(UploadAttachmentFailure(e, fileInfo))));
    }
  }

  void discardChanges() {
    if (session == null || accountId == null || newlyPickedPublicAssetIds.isEmpty) return;
    consumeState(_deletePublicAssetsInteractor.execute(
      session!,
      accountId!,
      publicAssetIds: newlyPickedPublicAssetIds));
  }
}