import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../view/drive_intent_web_view_modal.dart';

class DriveAttachmentPickerButton extends StatefulWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final ComposerToolbarButtonStyle style;
  final void Function(List<DriveDocument>)? onPickResult;

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
      _DriveAttachmentPickerButtonState();
}

class _DriveAttachmentPickerButtonState
    extends State<DriveAttachmentPickerButton> {
  bool _modalOpen = false;

  // ADR-93: register window listener once at composer init (web only).
  void Function(String raw, String? origin)? _webModalHandler;
  void Function(html.Event)? _webWindowListener;

  @override
  void initState() {
    super.initState();
    if (PlatformInfo.isWeb) {
      _webWindowListener = (html.Event event) {
        if (event is! html.MessageEvent) return;
        final data = event.data;
        if (data is! String) return;
        _webModalHandler?.call(data, event.origin);
      };
      html.window.addEventListener('message', _webWindowListener!);
    }
  }

  @override
  void dispose() {
    if (PlatformInfo.isWeb && _webWindowListener != null) {
      html.window.removeEventListener('message', _webWindowListener!);
    }
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_modalOpen) return;
    _modalOpen = true;
    final result = await showDialog<List<DriveDocument>?>(
      context: context,
      builder: (_) => DriveIntentWebViewModal(
        url: widget.workplaceUri,
        intentId: 'debug',
        onRegisterExternalHandler: PlatformInfo.isWeb
            ? (handler) => _webModalHandler = handler
            : null,
      ),
    );
    _webModalHandler = null;
    _modalOpen = false;
    if (mounted && result != null) {
      widget.onPickResult?.call(result);
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
