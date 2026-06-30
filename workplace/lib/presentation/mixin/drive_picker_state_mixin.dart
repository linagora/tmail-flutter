import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
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
    final fetch = pickerFetchIntent;
    _modalOpen = true;
    try {
      final l10n = AppLocalizations.of(context)!;
      final intent = await fetch(
        addAsLinkTitle: l10n.addAsLink,
        addAsAttachmentTitle: l10n.addAsAttachment,
      );
      if (!mounted) {
        throw WorkplaceUIDisposedException();
      }
      final result = await showDialog<List<DriveDocument>?>(
        context: context,
        builder: (_) => DriveIntentWebViewModal(
          url: intent.intentUrl,
          intentId: intent.intentId,
          onRegisterExternalHandler: externalHandlerRegistrar,
        ),
      );
      if (result != null) pickerOnCallback?.call(DrivePickResult(result));
    } catch (e) {
      logWarning('DrivePickerStateMixin::onPickerTap: $e');
      final message = mounted
          ? AppLocalizations.of(context)?.attachFromDriveFailingMessage
          : null;
      pickerOnCallback?.call(DrivePickFailure(e, message: message));
    } finally {
      clearExternalHandler();
      _modalOpen = false;
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
