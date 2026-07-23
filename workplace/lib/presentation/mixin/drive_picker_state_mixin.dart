import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
import 'package:workplace/presentation/model/drive_pick_outcome.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal.dart';

typedef OnPickDriveCallback = void Function(DrivePickState state);

typedef FetchDriveIntentCallback =
    Future<WorkplaceIntent> Function({
      required String addAsLinkTitle,
      required String addAsAttachmentTitle,
    });

/// Shared state logic for widgets that open [DriveIntentWebViewModal].
///
/// Consumers must provide [pickerFetchIntent] and [pickerOnCallback], then
/// call [onPickerTap] from their tap handler.
mixin DrivePickerStateMixin<T extends StatefulWidget> on State<T> {
  FetchDriveIntentCallback get pickerFetchIntent;

  OnPickDriveCallback? get pickerOnCallback => null;

  void Function(void Function(String raw, String? origin))?
  get externalHandlerRegistrar => null;
  void clearExternalHandler() {}

  bool _modalOpen = false;

  Future<void> onPickerTap() async {
    if (_modalOpen) return;
    _modalOpen = true;
    try {
      if (!mounted) {
        throw WorkplaceUIDisposedException();
      }
      final l10n = AppLocalizations.of(context)!;
      // Captured up front: the caller may pop this context (e.g. a context
      // menu tile) before the intent future settles, disposing this state.
      final failingMessage = l10n.attachFromDriveFailingMessage;
      final intentFuture = pickerFetchIntent(
        addAsLinkTitle: l10n.addAsLink,
        addAsAttachmentTitle: l10n.addAsAttachment,
      );
      DrivePickOutcome? outcome;
      try {
        outcome = await showDialog<DrivePickOutcome>(
          context: context,
          useSafeArea: false,
          barrierDismissible: false,
          builder: (_) => DriveIntentWebViewModal(
            intentFuture: intentFuture,
            onRegisterExternalHandler: externalHandlerRegistrar,
          ),
        );
      } catch (e) {
        outcome = DrivePickOutcomeFailed(e);
      }
      _handleOutcome(outcome, failingMessage);
    } finally {
      clearExternalHandler();
      _modalOpen = false;
    }
  }

  void _handleOutcome(DrivePickOutcome? outcome, String? failingMessage) {
    switch (outcome) {
      case DrivePickOutcomePicked(:final documents):
        pickerOnCallback?.call(DrivePickResult(documents));
      case DrivePickOutcomeFailed(:final error):
        logWarning('DrivePickerStateMixin::onPickerTap: $error');
        pickerOnCallback?.call(DrivePickFailure(error, message: failingMessage));
      case DrivePickOutcomeCancelled():
      case null:
        break;
    }
  }
}

/// Web-specific extension of [DrivePickerStateMixin] that wires a single
/// `window.onmessage` listener (ADR-93) into the modal handler slot.
mixin DrivePickerWebStateMixin<T extends StatefulWidget>
    on State<T>, DrivePickerStateMixin<T>, WebWindowMessageMixin<T> {
  void Function(String raw, String? origin)? _webModalHandler;

  @override
  void Function(void Function(String raw, String? origin))?
  get externalHandlerRegistrar =>
      (handler) => _webModalHandler = handler;

  @override
  void clearExternalHandler() => _webModalHandler = null;

  @override
  void initState() {
    super.initState();
    startWindowMessageListener(
      (data, origin) => _webModalHandler?.call(data, origin),
    );
  }

  @override
  void dispose() {
    stopWindowMessageListener();
    super.dispose();
  }
}
