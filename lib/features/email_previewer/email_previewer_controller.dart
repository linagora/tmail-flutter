
import 'dart:async';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_eml_content_shared_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_eml_content_in_memory_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class EmailPreviewerController extends ReloadableController {

  final GetPreviewEmailEMLContentSharedInteractor _getPreviewEmailEMLContentSharedInteractor;
  final MovePreviewEmlContentFromPersistentToMemoryInteractor _movePreviewEmlContentFromPersistentToMemoryInteractor;
  final RemovePreviewEmailEmlContentSharedInteractor _removePreviewEmailEmlContentSharedInteractor;
  final GetPreviewEmlContentInMemoryInteractor _getPreviewEmlContentInMemoryInteractor;
  final ParseEmailByBlobIdInteractor _parseEmailByBlobIdInteractor;
  final PreviewEmailFromEmlFileInteractor _previewEmailFromEmlFileInteractor;
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;
  final DownloadManager _downloadManager;

  final emlContentViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final downloadAttachmentState = Rx<dynamic>(null);

  Session? _session;
  AccountId? _accountId;
  String? _keyStored;
  bool _isDownloadingAttachment = false;
  CancelToken? _downloadAttachmentCancelToken;
  StreamController<Either<Failure, Success>>? _downloadAttachmentStreamController;
  StreamSubscription<Either<Failure, Success>>? _downloadAttachmentStreamSubscription;
  StreamSubscription<Either<Failure, Success>>? _downloadInteractorStreamSubscription;

  EmailPreviewerController(
    this._getPreviewEmailEMLContentSharedInteractor,
    this._movePreviewEmlContentFromPersistentToMemoryInteractor,
    this._removePreviewEmailEmlContentSharedInteractor,
    this._getPreviewEmlContentInMemoryInteractor,
    this._parseEmailByBlobIdInteractor,
    this._previewEmailFromEmlFileInteractor,
    this._downloadAttachmentForWebInteractor,
    this._downloadManager,
  );

  @override
  void onInit() {
    consumeState(Stream.value(Right(GettingPreviewEmailEMLContentShared())));
    _initialDownloadAttachmentStreamListener();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _getPreviewEmailEMLContentShared();
  }

  @override
  void onClose() {
    _accountId = null;
    _session = null;
    _keyStored = null;
    _isDownloadingAttachment = false;
    _downloadAttachmentCancelToken?.cancel();
    _downloadAttachmentCancelToken = null;
    _downloadAttachmentStreamSubscription?.cancel();
    _downloadAttachmentStreamController?.close();
    _downloadAttachmentStreamSubscription = null;
    _downloadAttachmentStreamController = null;
    _downloadInteractorStreamSubscription?.cancel();
    _downloadInteractorStreamSubscription = null;
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GettingPreviewEmailEMLContentShared ||
        success is GettingPreviewEMLContentInMemory) {
      emlContentViewState.value = Right(success);
    } else if (success is GetPreviewEMLContentInMemorySuccess) {
      emlContentViewState.value = Right(success);
      _updateWindowBrowserTitle(success.emlPreviewer.title);
    } else if (success is GetPreviewEmailEMLContentSharedSuccess) {
      emlContentViewState.value = Right(success);
      _updateWindowBrowserTitle(success.emlPreviewer.title);
      _movePreviewEmlContentFromPersistentToMemory(success.emlPreviewer);
    } else if (success is ParseEmailByBlobIdSuccess) {
      _handleParseEmailByBlobIdSuccess(success);
    } else if (success is PreviewEmailFromEmlFileSuccess) {
      emlContentViewState.value = Right(success);
      _updateWindowBrowserTitle(success.emlPreviewer.title);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetPreviewEmailEMLContentSharedFailure) {
      if (failure.keyStored == null) {
        emlContentViewState.value = Left(failure);
        return;
      }

      if (failure.exception is NotFoundDataWithThisKeyException) {
        _getPreviewEMLContentInMemory(failure.keyStored!);
      } else {
        emlContentViewState.value = Left(failure);
        _removePreviewEmlContentShared(failure.keyStored!);
      }
    } else if (failure is GetPreviewEMLContentInMemoryFailure) {
      if (failure.exception is NotFoundDataWithThisKeyException) {
        _keyStored = failure.keyStored;
        reload();
      } else {
        emlContentViewState.value = Left(failure);
      }
    } else if (failure is GetCredentialFailure ||
        failure is GetStoredTokenOidcFailure ||
        failure is GetAuthenticatedAccountFailure ||
        failure is GetSessionFailure ||
        failure is ParseEmailByBlobIdFailure ||
        failure is PreviewEmailFromEmlFileFailure) {
      emlContentViewState.value = Left(failure);
    }else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleReloaded(Session session) {
    _session = session;
    _accountId = session.accountId;

    if (_keyStored != null) {
      _parseEmailByBlobId(session.accountId, _keyStored!);
    }
  }

  void _getPreviewEmailEMLContentShared() {
    final parameters = Get.parameters;

    if (parameters.isEmpty) {
      consumeState(Stream.value(Left(GetPreviewEmailEMLContentSharedFailure(
          exception: NotFoundBlobIdException([])))));
      return;
    }

    final keyStored = parameters[RouteUtils.paramID];
    if (keyStored?.trim().isNotEmpty == true) {
      consumeState(_getPreviewEmailEMLContentSharedInteractor.execute(keyStored!));
    } else {
      consumeState(Stream.value(Left(GetPreviewEmailEMLContentSharedFailure(
          exception: NotFoundBlobIdException([])))));
    }
  }

  void _movePreviewEmlContentFromPersistentToMemory(EMLPreviewer emlPreviewer) {
    consumeState(
      _movePreviewEmlContentFromPersistentToMemoryInteractor.execute(emlPreviewer),
    );
  }

  void _removePreviewEmlContentShared(String keyStored) {
    consumeState(_removePreviewEmailEmlContentSharedInteractor.execute(keyStored));
  }

  void _getPreviewEMLContentInMemory(String keyStored) {
    consumeState(_getPreviewEmlContentInMemoryInteractor.execute(keyStored));
  }

  Future<void> onClickHyperLink(Uri? uri) async {
    log('EmailPreviewerController::onClickHyperLink:Uri = $uri');
    if (uri == null) return;

    if (uri.scheme == Constant.attachmentScheme) {
      final attachment = EmailUtils.parsingAttachmentByUri(uri);
      if (attachment == null) return;

      _downloadAttachment(attachment);
    } else {
      _openNewWindowByHyperLink(uri);
    }
  }

  void _openNewWindowByHyperLink(Uri uri) {
    bool isEMlPreview = uri.toString().startsWith(RouteUtils.emailEMLPreviewerRoutePath);
    final url = _standardizeURL(uri);
    log('EmailPreviewerController::_openNewWindowByHyperLink: url = $url');

    bool isOpen = HtmlUtils.openNewWindowByUrl(
      url,
      isFullScreen: !isEMlPreview,
      isCenter: false,
    );

    if (!isOpen && currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).cannotOpenNewWindow);
    }
  }

  String _standardizeURL(Uri uri) {
    if (uri.scheme == RouteUtils.mailtoPrefix) {
      return '${RouteUtils.baseOriginUrl}/mailto?uri=${uri.toString()}';
    }
    return uri.toString();
  }

  void _parseEmailByBlobId(AccountId accountId, String blobId) {
    consumeState(_parseEmailByBlobIdInteractor.execute(
      accountId,
      Id(blobId),
    ));
  }

  void _handleParseEmailByBlobIdSuccess(ParseEmailByBlobIdSuccess success) {
    if (_session == null) {
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(NotFoundSessionException()))));
      return;
    }

    if (_accountId == null) {
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(NotFoundAccountIdException()))));
      return;
    }

    if (currentContext == null) {
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(NotFoundContextException()))));
      return;
    }

    consumeState(_previewEmailFromEmlFileInteractor.execute(
      PreviewEmailEMLRequest(
        accountId: _accountId!,
        userName: _session!.username,
        blobId: success.blobId,
        email: success.email,
        locale: Localizations.localeOf(currentContext!),
        appLocalizations: AppLocalizations.of(currentContext!),
        baseDownloadUrl: _session!.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl),
        isShared: false,
      ),
    ));
  }

  void _updateWindowBrowserTitle(String title) {
    HtmlUtils.setWindowBrowserTitle(title);
  }

  void _downloadAttachment(Attachment attachment) {
    if (_isDownloadingAttachment) {
      if (currentContext == null || currentOverlayContext == null) return;

      appToast.showToastWarningMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).downloadAttachmentInEMLPreviewWarningMessage);
      return;
    }

    _isDownloadingAttachment = true;
    downloadAttachmentState.value = Right(StartDownloadAttachmentForWeb(
      attachment.downloadTaskId,
      attachment));

    if (_accountId != null && _session != null) {
      _startDownloadAttachment(attachment);
    } else {
      _getAuthenticatedAccountAction(attachment);
    }
  }

  void _startDownloadAttachment(Attachment attachment) {
    _downloadInteractorStreamSubscription = _downloadAttachmentForWebInteractor
        .execute(
            attachment.downloadTaskId,
            attachment,
            _accountId!,
            _session!.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl),
            _downloadAttachmentStreamController!)
        .listen(_handleDownloadAttachmentViewState);
  }

  void _initialDownloadAttachmentStreamListener() {
    _downloadAttachmentCancelToken = CancelToken();
    _downloadAttachmentStreamController = StreamController<Either<Failure, Success>>();
    _downloadAttachmentStreamSubscription = _downloadAttachmentStreamController
        ?.stream
        .listen(_handleDownloadAttachmentViewState);
  }

  void _handleDownloadAttachmentViewState(Either<Failure, Success> viewState) {
    viewState.fold(
      (failure) {
        downloadAttachmentState.value = failure;
        if (failure is DownloadAttachmentForWebFailure) {
          _isDownloadingAttachment = false;
        }
      },
      (success) {
        downloadAttachmentState.value = success;
        if (success is DownloadAttachmentForWebSuccess) {
          _isDownloadingAttachment = false;
          _handleDownloadAttachmentSuccess(success);
        }
      }
    );
  }

  Future<void> _getAuthenticatedAccountAction(Attachment attachment) async {
    final authenticatedAccountViewState = await getAuthenticatedAccountInteractor
      .execute()
      .last;

    final authenticatedSuccessState = authenticatedAccountViewState
        .getOrElse(() => UIState.idle);

    if (authenticatedSuccessState is! GetStoredTokenOidcSuccess &&
        authenticatedSuccessState is! GetCredentialViewState) {
      _isDownloadingAttachment = false;

      if (currentContext == null || currentOverlayContext == null) return;

      appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).attachment_download_failed);
      return;
    }

    if (authenticatedSuccessState is GetStoredTokenOidcSuccess) {
      setDataToInterceptors(
        baseUrl: authenticatedSuccessState.baseUrl.toString(),
        tokenOIDC: authenticatedSuccessState.tokenOidc,
        oidcConfiguration: authenticatedSuccessState.oidcConfiguration);
    } else if (authenticatedSuccessState is GetCredentialViewState) {
      setDataToInterceptors(
        baseUrl: authenticatedSuccessState.baseUrl.toString(),
        userName: authenticatedSuccessState.userName,
        password: authenticatedSuccessState.password);
    }

    final sessionViewState = await getSessionInteractor.execute().last;
    final sessionSuccessState = sessionViewState.getOrElse(() => UIState.idle);

    if (sessionSuccessState is GetSessionSuccess) {
      _session = sessionSuccessState.session;
      _accountId = _session?.accountId;

      _startDownloadAttachment(attachment);
    } else {
      _isDownloadingAttachment = false;

      appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).attachment_download_failed);
    }
  }

  void _handleDownloadAttachmentSuccess(DownloadAttachmentForWebSuccess success) {
    _downloadManager.createAnchorElementDownloadFileWeb(
        success.bytes,
        success.attachment.generateFileName());
  }
}