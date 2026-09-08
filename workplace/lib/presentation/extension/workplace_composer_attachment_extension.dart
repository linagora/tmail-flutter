import 'package:core/presentation/extensions/composer_attachment_plugin.dart';
import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/presentation/intent_fetcher/bridge_drive_intent_fetcher.dart';
import 'package:workplace/presentation/intent_fetcher/drive_intent_fetcher.dart';
import 'package:workplace/presentation/intent_fetcher/fallback_drive_intent_fetcher.dart';
import 'package:workplace/presentation/intent_fetcher/token_drive_intent_fetcher.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/model/drive_picker_session.dart';
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

  // Bridge first (container session), token exchange as the fallback route.
  late final DriveIntentFetcher _intentFetcher = FallbackDriveIntentFetcher([
    BridgeDriveIntentFetcher(),
    TokenDriveIntentFetcher(oidcTokenGetter: oidcTokenGetter),
  ]);

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
  }) =>
      _intentFetcher.fetchIntent(platformUrl, _toIntentConfig(filePickerConfig));

  WorkplaceIntentConfig _toIntentConfig(
    WorkplaceFilePickerConfigRequest filePickerConfig,
  ) =>
      WorkplaceIntentConfig(
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
      );

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
