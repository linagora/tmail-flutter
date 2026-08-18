import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal.dart';

typedef OnPickDriveCallback = void Function(DrivePickState state);

typedef FetchDriveIntentCallback =
    Future<WorkplaceIntent> Function({
      required WorkplaceFilePickerConfigRequest filePickerConfig,
    });

/// Shared state logic for widgets that open [DriveIntentWebViewModal].
///
/// Consumers must provide [pickerFetchIntent] and [pickerOnCallback], then
/// call [onPickerTap] from their tap handler.
mixin DrivePickerStateMixin<T extends StatefulWidget> on State<T> {
  FetchDriveIntentCallback get pickerFetchIntent;

  DriveIntentImageAssets get driveIntentImageAssets;

  num? get maxAttachmentSizeBytes;

  OnPickDriveCallback? get pickerOnCallback => null;

  bool _modalOpen = false;

  Future<void> onPickerTap() async {
    if (_modalOpen) return;
    _modalOpen = true;
    try {
      if (!mounted) {
        // Tap raced state disposal — nothing to show a modal or toast on.
        logError('DrivePickerStateMixin::onPickerTap: state disposed before opening modal');
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      // Captured up front: the caller may pop this context (e.g. a context
      // menu tile) before the intent future settles, disposing this state.
      final failingMessage = l10n.attachFromDriveFailingMessage;
      const addAsAttachmentTitle = null; // TODO: Add attachment title here after implement 103. Attach Drive File as Attachment
      final theme = _resolveWorkplaceTheme(context);
      final filePickerConfig = WorkplaceFilePickerConfigRequest(
        sharingLink: WorkplaceActionConfigRequest(label: l10n.addAsLink),
        downloadLink: addAsAttachmentTitle == null
            ? null
            : WorkplaceActionConfigRequest(
                label: addAsAttachmentTitle,
                maxFileSize: maxAttachmentSizeBytes,
                availableSize: maxAttachmentSizeBytes,
              ),
        theme: WorkplaceThemeConfigRequest.fromEntity(theme),
      );
      DrivePickOutcome? outcome;
      try {
        outcome = await openDrivePickerModal(filePickerConfig);
      } catch (e, s) {
        logError(
          'DrivePickerStateMixin::onPickerTap: modal failed',
          exception: e,
          stackTrace: s,
        );
        outcome = DrivePickOutcomeFailed(e);
      }
      _handleOutcome(outcome, failingMessage);
    } finally {
      _modalOpen = false;
    }
  }

  /// Overridable seam so tests can stub the modal instead of pumping a real
  /// WebView/iframe.
  @protected
  Future<DrivePickOutcome?> openDrivePickerModal(
    WorkplaceFilePickerConfigRequest filePickerConfig,
  ) {
    return showDialog<DrivePickOutcome>(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (_) => DriveIntentWebViewModal(
        // Must stay lazy so the modal subscribes to failures before the
        // token exchange or intent request starts.
        intentLoader: () => pickerFetchIntent(
          filePickerConfig: filePickerConfig,
        ),
        filePickerConfig: filePickerConfig,
        imageAssets: driveIntentImageAssets,
      ),
    );
  }

  void _handleOutcome(DrivePickOutcome? outcome, String? failingMessage) {
    switch (outcome) {
      case DrivePickOutcomePicked(:final documents):
        pickerOnCallback?.call(DrivePickResult(documents));
      case DrivePickOutcomeFailed(:final error):
        // Already reported to Sentry at the failing stage (modal mixin or the
        // catch above) — only dispatch the UI failure callback here.
        pickerOnCallback?.call(DrivePickFailure(error, message: failingMessage));
      case DrivePickOutcomeCancelled():
      case null:
        break;
    }
  }

  WorkplaceTheme _resolveWorkplaceTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? WorkplaceTheme.dark
        : WorkplaceTheme.light;
}
