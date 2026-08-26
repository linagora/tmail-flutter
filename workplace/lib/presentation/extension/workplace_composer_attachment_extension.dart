import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
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

class WorkplaceComposerAttachmentExtension implements ComposerAttachmentPlugin {
  final ValueListenable<Uri?> workplaceUri;

  /// Read when the picker opens, so the JMAP capability is always current.
  final ValueGetter<bool> uploadFromUrlSupported;
  final String? Function() oidcTokenGetter;
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
    required this.maxAttachmentSizeBytesGetter,
    required this.remainingAttachmentCapacityBytesGetter,
    this.onPickState,
  });

  Future<WorkplaceIntent> _fetchIntent(
    Uri platformUrl, {
    required WorkplaceFilePickerConfigRequest filePickerConfig,
  }) async {
    final oidcToken = oidcTokenGetter();
    if (oidcToken == null) throw StateError('OIDC token is unavailable');
    final accessToken = await _exchangeAccessToken(platformUrl, oidcToken);
    if (accessToken == null) throw StateError('Drive access token exchange failed');
    return _createIntent(
      platformUrl,
      accessToken,
      filePickerConfig: filePickerConfig,
    );
  }

  Future<String?> _exchangeAccessToken(
    Uri platformUrl,
    String oidcToken,
  ) async {
    String? accessToken;
    await for (final either in _exchangeTokenInteractor.execute(
      platformUrl,
      oidcToken,
    )) {
      either.fold(
        (failure) {
          logWarning(
            'WorkplaceComposerAttachmentExtension::_exchangeAccessToken failed: $failure',
          );
          throw failure is FeatureFailure ? failure.exception : WorkplaceExchangeTokenException();
        },
        (success) {
          if (success is ExchangeWorkplaceTokenSuccess) {
            accessToken = success.accessToken;
          }
        },
      );
    }
    return accessToken;
  }

  Future<WorkplaceIntent> _createIntent(
    Uri platformUrl,
    String accessToken, {
    required WorkplaceFilePickerConfigRequest filePickerConfig,
  }) async {
    WorkplaceIntent? intent;
    await for (final either in _createIntentInteractor.execute(
      platformUrl,
      accessToken,
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
    )) {
      either.fold(
        (failure) {
          logWarning(
            'WorkplaceComposerAttachmentExtension::_createIntent failed: $failure',
          );
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
