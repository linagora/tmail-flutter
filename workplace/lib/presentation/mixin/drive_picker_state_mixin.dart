import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/model/drive_picker_session.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal.dart';

typedef OnPickDriveCallback = Future<void> Function(DrivePickState state);

typedef FetchDriveIntentCallback =
    Future<WorkplaceIntent> Function({
      required WorkplaceFilePickerConfigRequest filePickerConfig,
    });

/// Shared state logic for widgets that open [DriveIntentWebViewModal].
///
/// Consumers must provide [pickerFetchIntent] and [pickerOnCallback], then
/// call [onPickerTap] from their tap handler.
mixin DrivePickerStateMixin<T extends StatefulWidget> on State<T> {
  DrivePickerSession get session;

  DriveIntentImageAssets get driveIntentImageAssets;

  OnPickDriveCallback? get pickerOnCallback => null;

  bool _modalOpen = false;

  Future<void> onPickerTap() async {
    if (_modalOpen) return;
    _modalOpen = true;
    // Kept outside the try so a failure after localization still toasts it.
    String? failingMessage;
    try {
      if (!mounted) {
        // Message needs the disposed context, so dispatch without one and let
        // the toast fall back to its generic failure text.
        logError('DrivePickerStateMixin::onPickerTap: state disposed before opening modal');
        await _dispatch(
          DrivePickFailure(StateError('drive picker state disposed before modal')),
        );
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      // Captured up front: the caller may pop this context (e.g. a context
      // menu tile) before the intent future settles, disposing this state.
      failingMessage = l10n.attachFromDriveFailingMessage;
      final snapshot = DrivePickerSessionResolver(session).resolve();
      final addAsAttachmentTitle =
          snapshot.uploadFromUrlSupported ? l10n.addAsAttachment : null;
      final theme = _resolveWorkplaceTheme(context);
      final filePickerConfig = WorkplaceFilePickerConfigRequest(
        sharingLink: WorkplaceActionConfigRequest(label: l10n.addAsLink),
        downloadLink: addAsAttachmentTitle == null
            ? null
            : WorkplaceActionConfigRequest(
                label: addAsAttachmentTitle,
                maxFileSize: snapshot.maxAttachmentSizeBytes,
                // What is left after the composer's existing attachments, so
                // the picker can't offer bytes the send guard would reject.
                availableSize: snapshot.remainingAttachmentCapacityBytes ??
                    snapshot.maxAttachmentSizeBytes,
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
      await _handleOutcome(outcome, failingMessage);
    } catch (e, s) {
      // Configuring the picker runs outside the modal's error boundary, so a
      // throw here would leave the tap silently doing nothing.
      logError(
        'DrivePickerStateMixin::onPickerTap: picker configuration failed',
        exception: e,
        stackTrace: s,
      );
      await _dispatch(DrivePickFailure(e, message: failingMessage));
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
        intentLoader: () => session.onFetchIntent(
          filePickerConfig: filePickerConfig,
        ),
        filePickerConfig: filePickerConfig,
        imageAssets: driveIntentImageAssets,
      ),
    );
  }

  Future<void> _handleOutcome(
    DrivePickOutcome? outcome,
    String? failingMessage,
  ) async {
    switch (outcome) {
      case DrivePickOutcomePicked(:final documents):
        await _dispatch(DrivePickResult(documents));
      case DrivePickOutcomeFailed(:final error):
        // Already reported to Sentry at the failing stage (modal mixin or the
        // catch above) — only dispatch the UI failure callback here.
        await _dispatch(DrivePickFailure(error, message: failingMessage));
      case DrivePickOutcomeCancelled():
      case null:
        break;
    }
  }

  /// Awaited so a throw in the consumer's handler is caught here instead of
  /// escaping as an unhandled zone error.
  Future<void> _dispatch(DrivePickState state) async {
    try {
      await pickerOnCallback?.call(state);
    } catch (e, s) {
      logError(
        'DrivePickerStateMixin::_dispatch: pick callback failed',
        exception: e,
        stackTrace: s,
      );
    }
  }

  WorkplaceTheme _resolveWorkplaceTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? WorkplaceTheme.dark
        : WorkplaceTheme.light;
}
