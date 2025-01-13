
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_eml_content_shared_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_eml_content_in_memory_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
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

  final emlContentViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  Session? _session;
  AccountId? _accountId;
  String? _keyStored;

  EmailPreviewerController(
    this._getPreviewEmailEMLContentSharedInteractor,
    this._movePreviewEmlContentFromPersistentToMemoryInteractor,
    this._removePreviewEmailEmlContentSharedInteractor,
    this._getPreviewEmlContentInMemoryInteractor,
    this._parseEmailByBlobIdInteractor,
    this._previewEmailFromEmlFileInteractor,
  );

  @override
  void onInit() {
    consumeState(Stream.value(Right(GettingPreviewEmailEMLContentShared())));
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
      _movePreviewEmlContentFromPersistentToMemory(
          success.keyStored,
          success.emlPreviewer);
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

  void _movePreviewEmlContentFromPersistentToMemory(
    String keyStored,
    EMLPreviewer emlPreviewer,
  ) {
    consumeState(
      _movePreviewEmlContentFromPersistentToMemoryInteractor.execute(
        keyStored,
        emlPreviewer,
      ),
    );
  }

  void _removePreviewEmlContentShared(String keyStored) {
    consumeState(_removePreviewEmailEmlContentSharedInteractor.execute(keyStored));
  }

  void _getPreviewEMLContentInMemory(String keyStored) {
    consumeState(_getPreviewEmlContentInMemoryInteractor.execute(keyStored));
  }

  Future<void> onClickHyperLink(Uri? uri) async {
    if (uri == null) return;

    bool isEMlPreview = uri.toString().startsWith(RouteUtils.emailEMLPreviewerRoutePath);
    final url = _standardizeURL(uri.toString());

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

  String _standardizeURL(String url) {
    if (url.startsWith('${RouteUtils.mailtoPrefix}:')) {
      final mailtoLink = '${RouteUtils.baseOriginUrl}/mailto?uri=$url';
      return mailtoLink;
    }
    return url;
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
}