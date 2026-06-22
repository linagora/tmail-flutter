import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal.dart';

typedef OnPickDriveAttachmentResult = void Function(List<DriveDocument>);

class DriveAttachmentPickerButton extends StatefulWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final ComposerToolbarButtonStyle style;
  final OnPickDriveAttachmentResult? onPickResult;

  const DriveAttachmentPickerButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    this.style = const ComposerToolbarButtonStyle(),
    this.onPickResult,
  });

  @override
  State<DriveAttachmentPickerButton> createState() =>
      _DriveAttachmentPickerButtonState.create();
}

abstract class _DriveAttachmentPickerButtonState
    extends State<DriveAttachmentPickerButton> {
  _DriveAttachmentPickerButtonState();

  factory _DriveAttachmentPickerButtonState.create() => PlatformInfo.isWeb
      ? _WebDriveAttachmentPickerButtonState()
      : _MobileDriveAttachmentPickerButtonState();

  bool _modalOpen = false;

  /// Returns the external handler registrar passed to [DriveIntentWebViewModal].
  /// Mobile returns null; web subclass returns a closure that captures its field.
  void Function(void Function(String raw, String? origin))? get _externalHandlerRegistrar => null;

  /// Called after the modal closes so web subclass can clear its handler.
  void _clearExternalHandler() {}

  Future<void> _onTap() async {
    if (_modalOpen) return;
    try {
      _modalOpen = true;
      final result = await showDialog<List<DriveDocument>?>(
        context: context,
        builder: (_) => DriveIntentWebViewModal(
          url: widget.workplaceUri,
          intentId: 'debug',
          onRegisterExternalHandler: _externalHandlerRegistrar,
        ),
      );
      _clearExternalHandler();
      _modalOpen = false;
      if (mounted && result != null) {
        widget.onPickResult?.call(result);
      }
    } catch (e) {
      logWarning('DriveAttachmentPickerButton::_onTap: $e');
      _modalOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: widget.imagePaths.icCloudPlus,
      iconColor: widget.style.iconColor,
      backgroundColor: Colors.transparent,
      iconSize: widget.style.iconSize,
      borderRadius: widget.style.borderRadius,
      padding: widget.style.padding,
      margin: widget.style.margin,
      tooltipMessage: widget.style.tooltipLabel,
      onTapActionCallback: _onTap,
    );
  }
}

class _MobileDriveAttachmentPickerButtonState
    extends _DriveAttachmentPickerButtonState {}

class _WebDriveAttachmentPickerButtonState
    extends _DriveAttachmentPickerButtonState
    with WebWindowMessageMixin<DriveAttachmentPickerButton> {
  // ADR-93: register window listener once at composer init (web only).
  void Function(String raw, String? origin)? _webModalHandler;

  @override
  void Function(void Function(String raw, String? origin))? get _externalHandlerRegistrar =>
      (handler) => _webModalHandler = handler;

  @override
  void _clearExternalHandler() => _webModalHandler = null;

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
