import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workplace/data/bridge/cozy_bridge.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_access_mode.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/model/drive_picker_session.dart';
import 'package:workplace/domain/state/workplace_intent_state.dart';
import 'package:workplace/domain/usecase/create_drive_intent_interactor.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/presentation/widget/drive_attachment_context_menu_tile.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

typedef OnDrivePickStateChanged =
    Future<void> Function(String? composerId, DrivePickState state);

/// Triggers the host app's OIDC refresh; returns the refreshed id token.
typedef OidcRefreshTrigger = Future<String?> Function();

class WorkplaceComposerAttachmentExtension implements ComposerAttachmentPlugin {
  final ValueListenable<Uri?> workplaceUri;

  /// Read when the picker opens, so the JMAP capability is always current.
  final ValueGetter<bool> uploadFromUrlSupported;
  final String? Function() oidcTokenGetter;

  final OidcRefreshTrigger oidcRefreshTrigger;
  final num? Function() maxAttachmentSizeBytesGetter;

  /// Per-composer: the remainder depends on what that composer already holds.
  final num? Function(String? composerId) remainingAttachmentCapacityBytesGetter;
  final OnDrivePickStateChanged? onPickState;

  late final _dataSource = WorkplaceDataSourceImpl();
  late final _repository = WorkplaceRepositoryImpl(_dataSource);
  late final _createIntentInteractor = CreateDriveIntentInteractor(_repository);
  late final _exchangeTokenInteractor = ExchangeDriveTokenInteractor(
    _repository,
  );

  WorkplaceComposerAttachmentExtension({
    required this.workplaceUri,
    required this.uploadFromUrlSupported,
    required this.oidcTokenGetter,
    required this.oidcRefreshTrigger,
    required this.maxAttachmentSizeBytesGetter,
    required this.remainingAttachmentCapacityBytesGetter,
    this.onPickState,
  });

  Future<WorkplaceIntent> _fetchIntent(
    Uri platformUrl, {
    required WorkplaceFilePickerConfigRequest filePickerConfig,
  }) async {
    // Try the bridge first; any failure falls back to the bearer-token flow.
    if (CozyBridge.isSupported && CozyBridge.isAvailable) {
      try {
        return await _createIntent(
          platformUrl,
          const BridgeAccessMode(),
          filePickerConfig: filePickerConfig,
        );
      } catch (_) {
        // fall through to the bearer-token flow below
        logWarning(
          'WorkplaceComposerAttachmentExtension::_fetchIntent: Cozy bridge createIntent failed, falling back to bearer-token flow',
          webConsoleEnabled: true,
        );
      }
    }

    final oidcToken = oidcTokenGetter();
    if (oidcToken == null) throw StateError('OIDC token is unavailable');
    final accessToken = await _exchangeAccessToken(platformUrl, oidcToken);
    if (accessToken == null) throw StateError('Drive access token exchange failed');
    return _createIntent(
      platformUrl,
      BearerTokenAccessMode(accessToken),
      filePickerConfig: filePickerConfig,
    );
  }

  Future<String?> _exchangeAccessToken(
    Uri platformUrl,
    String oidcToken, {
    bool refreshAttempted = false,
  }) async {
    final result = await _requestAccessToken(platformUrl, oidcToken);
    return result.fold(
      (failure) => _triggerRefreshOIDCToken(
        platformUrl: platformUrl,
        failedToken: oidcToken,
        failure: failure,
        refreshAttempted: refreshAttempted,
      ),
      (accessToken) => accessToken,
    );
  }

  Future<Either<Object, String?>> _requestAccessToken(
    Uri platformUrl,
    String oidcToken,
  ) async {
    String? accessToken;
    Object? caughtFailure;
    await for (final either in _exchangeTokenInteractor.execute(
      platformUrl,
      oidcToken,
    )) {
      either.fold(
        // reported by DriveIntentMessageHandlerMixin._failWith, the single funnel.
        (failure) => caughtFailure =
            failure is FeatureFailure ? failure.exception : WorkplaceExchangeTokenException(),
        (success) {
          if (success is ExchangeWorkplaceTokenSuccess) {
            accessToken = success.accessToken;
          }
        },
      );
    }
    return caughtFailure == null ? Right(accessToken) : Left(caughtFailure!);
  }

  /// Retries once on a stale-token response with the current token if another
  /// request already refreshed it, else with a freshly refreshed one
  /// (Workplace's Dio has no refresh interceptor of its own).
  Future<String?> _triggerRefreshOIDCToken({
    required Uri platformUrl,
    required String failedToken,
    required Object failure,
    required bool refreshAttempted,
  }) async {
    if (refreshAttempted || !_isStaleSubjectToken(failure)) {
      throw failure;
    }

    // Mirrors AuthorizationInterceptors.validateToRetryTheRequestWithNewToken.
    final currentToken = oidcTokenGetter();
    if (currentToken != null && currentToken != failedToken) {
      return _exchangeAccessToken(platformUrl, currentToken, refreshAttempted: true);
    }

    final refreshedToken = await oidcRefreshTrigger();
    logWarning(
      'WorkplaceComposerAttachmentExtension::_triggerRefreshOIDCToken: '
      'failedIdTokenHash=${failedToken.hashCode} | '
      'refreshedIdTokenHash=${refreshedToken?.hashCode}',
    );
    // The IdP may omit id_token on refresh, in which case the current one is
    // kept — retrying would re-send the token that just 401'd.
    if (refreshedToken == null || refreshedToken == failedToken) throw failure;

    return _exchangeAccessToken(platformUrl, refreshedToken, refreshAttempted: true);
  }

  // RFC 8693 says 400 invalid_grant for a bad subject_token; token_exchange has
  // also been seen answering 401. Both mean the id token needs refreshing.
  bool _isStaleSubjectToken(Object failure) {
    if (failure is! DioException) return false;
    final statusCode = failure.response?.statusCode;
    return statusCode == 400 || statusCode == 401;
  }

  Future<WorkplaceIntent> _createIntent(
    Uri platformUrl,
    WorkplaceIntentAccessMode accessMode, {
    required WorkplaceFilePickerConfigRequest filePickerConfig,
  }) async {
    WorkplaceIntent? intent;
    await for (final either in _createIntentInteractor.execute(
      platformUrl,
      accessMode,
      config: WorkplaceIntentConfig(
        addAsLink: WorkplaceActionConfig(label: filePickerConfig.sharingLink.label),
        addAsAttachment: filePickerConfig.downloadLink == null
            ? null
            : WorkplaceActionConfig(
                label: filePickerConfig.downloadLink!.label,
                maxFileSize: filePickerConfig.downloadLink!.maxFileSize,
                availableSize: filePickerConfig.downloadLink!.availableSize,
              ),
        theme: switch (filePickerConfig.theme.type) {
          WorkplaceThemeType.light => WorkplaceTheme.light,
          WorkplaceThemeType.dark => WorkplaceTheme.dark,
        },
      ),
    )) {
      either.fold(
        (failure) {
          // reported by DriveIntentMessageHandlerMixin._failWith, the single funnel.
          throw failure is FeatureFailure ? failure.exception : WorkplaceCreateIntentException();
        },
        (success) {
          if (success is CreateWorkplaceIntentSuccess) intent = success.intent;
        },
      );
    }
    return intent!;
  }

  @override
  Widget buildToolbarButton(
    BuildContext context, {
    required String composerId,
    required ImagePaths imagePaths,
    ComposerToolbarButtonStyle style = const ComposerToolbarButtonStyle(),
  }) {
    return ValueListenableBuilder<Uri?>(
      valueListenable: workplaceUri,
      builder: (_, uri, __) {
        if (uri == null) return const SizedBox.shrink();
        return DriveAttachmentPickerButton(
          composerId: composerId,
          imagePaths: imagePaths,
          style: style,
          session: _sessionFor(uri, composerId),
          onPickCallback: onPickState == null
              ? null
              : (state) => onPickState!(composerId, state),
        );
      },
    );
  }

  @override
  Widget buildContextMenuTile(
    BuildContext context, {
    required ImagePaths imagePaths,
  }) {
    return ValueListenableBuilder<Uri?>(
      valueListenable: workplaceUri,
      builder: (_, uri, __) {
        if (uri == null) return const SizedBox.shrink();
        return DriveAttachmentContextMenuTile(
          imagePaths: imagePaths,
          session: _sessionFor(uri, null),
          onPickCallback: onPickState == null
              ? null
              : (state) => onPickState!(null, state),
        );
      },
    );
  }

  DrivePickerSession _sessionFor(Uri uri, String? composerId) => DrivePickerSession(
        uploadFromUrlSupported: uploadFromUrlSupported,
        maxAttachmentSizeBytesGetter: maxAttachmentSizeBytesGetter,
        remainingAttachmentCapacityBytesGetter: () =>
            remainingAttachmentCapacityBytesGetter(composerId),
        onFetchIntent: ({required filePickerConfig}) => _fetchIntent(
          uri,
          filePickerConfig: filePickerConfig,
        ),
      );
}
