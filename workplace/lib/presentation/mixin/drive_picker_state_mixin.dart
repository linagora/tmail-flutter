import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

/// Shared state logic for widgets that open [DriveIntentWebViewModal].
///
/// Consumers must provide [pickerWorkplaceUri] and [pickerOnPickResult], then
/// call [onPickerTap] from their tap handler.
mixin DrivePickerStateMixin<T extends StatefulWidget> on State<T> {
  Uri get pickerWorkplaceUri;
  OnPickDriveAttachmentResult? get pickerOnPickResult;

  void Function(void Function(String raw, String? origin))? get externalHandlerRegistrar => null;
  void clearExternalHandler() {}

  bool _modalOpen = false;

  Future<void> onPickerTap() async {
    if (_modalOpen) return;
    try {
      _modalOpen = true;
      final result = await showDialog<List<DriveDocument>?>(
        context: context,
        builder: (_) => DriveIntentWebViewModal(
          url: pickerWorkplaceUri,
          intentId: 'debug',
          onRegisterExternalHandler: externalHandlerRegistrar,
        ),
      );
      clearExternalHandler();
      _modalOpen = false;
      if (mounted && result != null) pickerOnPickResult?.call(result);
    } catch (e) {
      logWarning('DrivePickerStateMixin::onPickerTap: $e');
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
  void Function(void Function(String raw, String? origin))? get externalHandlerRegistrar =>
      (handler) => _webModalHandler = handler;

  @override
  void clearExternalHandler() => _webModalHandler = null;

  @override
  void initState() {
    super.initState();
    startWindowMessageListener((data, origin) => _webModalHandler?.call(data, origin));
  }

  @override
  void dispose() {
    stopWindowMessageListener();
    super.dispose();
  }
}
