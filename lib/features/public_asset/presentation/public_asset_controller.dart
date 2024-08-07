import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:tmail_ui_user/features/public_asset/presentation/model/public_asset_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/platform_file_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

typedef PublicAssetId = Id;

class PublicAssetController extends BaseController {
  PublicAssetController(
    this._uploadAttachmentInteractor,
    this._createPublicAssetInteractor,
    {required this.arguments}
  );

  final UploadAttachmentInteractor _uploadAttachmentInteractor;
  final CreatePublicAssetInteractor _createPublicAssetInteractor;
  final PublicAssetArguments? arguments;

  List<PublicAssetId> oldPublicAssetIds = [];
  List<PublicAssetId> newPublicAssetIds = [];
  final _publicAssetStreamGroup = StreamGroup<Either<Failure, Success>>();
  StreamSubscription<Either<Failure, Success>>? _publicAssetStreamSubscription;

  StreamSubscription<Either<Failure, Success>>? get  publicAssetStreamSubscription
    => _publicAssetStreamSubscription;
  Session? get session => arguments?.session;
  AccountId? get accountId => arguments?.accountId;
  Identity? get identity => arguments?.identity;

  void _handleUploadState(Either<Failure, Success> uploadState) {
    log('PublicAssetController::handleUploadState::${uploadState.runtimeType}');
    uploadState.fold(
      (failure) {},
      (success) {
        log('PublicAssetController::handleUploadState::success::$success');
        if (success is SuccessAttachmentUploadState) {
          final filePath = success.fileInfo.filePath;
          if (PlatformInfo.isMobile && filePath != null) {
             _deleteCompressedFileOnMobile(filePath);
          }

          final blobId = success.attachment.blobId;
          if (session == null
            || accountId == null
            || blobId == null) return;

          consumeState(_createPublicAssetInteractor.execute(
            session!,
            accountId!,
            blobId: blobId,
            identityId: identity?.id));
        }
      }
    );
  }

  Future<void> _deleteCompressedFileOnMobile(String filePath) async {
    log('PublicAssetController::_deleteCompressedFileOnMobile: filePath: $filePath');
    try {
      final File file = File(filePath);
      if (await file.exists() && file.path.contains(IdentityCreatorConstants.prefixCompressedInlineImageTemp)) {
        await file.delete();
      }
    } catch (e) {
      logError('PublicAssetController::_deleteCompressedFileOnMobile: error: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _publicAssetStreamSubscription = _publicAssetStreamGroup.stream.listen(_handleUploadState);
  }

  @override
  void onClose() {
    oldPublicAssetIds.clear();
    newPublicAssetIds.clear();
    _publicAssetStreamSubscription?.cancel();
    _publicAssetStreamGroup.close();
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

  Future<void> _handleUploadAttachmentSuccess(UploadAttachmentSuccess success) async {
    await _publicAssetStreamGroup.add(success.uploadAttachment.progressState);
  }

  void _handleCreatePublicAssetSuccessState(CreatePublicAssetSuccessState success) {
    final publicAsset = success.publicAsset;
    if (publicAsset.id == null || publicAsset.publicURI == null) return;

    newPublicAssetIds.add(publicAsset.id!);
    final imageTag = '<img '
      'src="${publicAsset.publicURI!}" '
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
    oldPublicAssetIds = htmlContent.publicAssetIdsFromHtmlContent;
  }

  void uploadFileToBlob(PlatformFile platformFile) {
    _uploadFileToBlobAction(platformFile);
  }

  void _uploadFileToBlobAction(PlatformFile platformFile) {
    if (session == null || accountId == null) return;

    final fileInfo = platformFile.toFileInfo();
    final uploadUri = session!.getUploadUri(accountId!, jmapUrl: dynamicUrlInterceptors.jmapUrl);
    consumeState(_uploadAttachmentInteractor.execute(fileInfo, uploadUri));
  }
}