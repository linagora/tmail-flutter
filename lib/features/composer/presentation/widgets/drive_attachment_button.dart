import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';
import 'package:drive_attachment/drive_attachment/presentation/notifier/drive_attachment_notifier.dart';
import 'package:drive_attachment/drive_attachment/presentation/notifier/drive_attachment_state.dart';
import 'package:drive_attachment/drive_attachment/presentation/provider/drive_access_token_notifier.dart';
import 'package:drive_attachment/drive_attachment/presentation/provider/workplace_fqdn_notifier.dart';
import 'package:drive_attachment/drive_attachment/presentation/view/drive_intent_web_view_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:universal_html/html.dart' as html;

class DriveAttachmentButton extends ConsumerStatefulWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Color? iconColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const DriveAttachmentButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    this.iconColor,
    this.iconSize = 20,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  ConsumerState<DriveAttachmentButton> createState() =>
      _DriveAttachmentButtonState();
}

class _DriveAttachmentButtonState extends ConsumerState<DriveAttachmentButton> {
  bool _modalOpen = false;

  // ADR-93: register window listener once at composer init (web only).
  // The active modal's message handler is stored here and called on each event.
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

  Future<void> _openModal(DriveIntentPending state) async {
    _modalOpen = true;
    final List<DriveDocument>? result = await showDialog<List<DriveDocument>?>(
      context: context,
      builder: (_) => DriveIntentWebViewModal(
        url: state.intent.intentUrl,
        intentId: state.intent.intentId,
        onRegisterExternalHandler: PlatformInfo.isWeb
            ? (handler) => _webModalHandler = handler
            : null,
      ),
    );
    _webModalHandler = null;
    _modalOpen = false;
    if (mounted) {
      ref
          .read(driveAttachmentNotifierProvider(widget.composerId).notifier)
          .onPickResult(result);
    }
  }

  Future<void> _onTap() async {
    final fqdn = ref.read(workplaceFqdnProvider);
    if (fqdn == null) return;
    final platformUrl =
        Uri.parse(fqdn.startsWith('http') ? fqdn : 'https://$fqdn');

    final accessToken = await ref.read(driveAccessTokenProvider.future);
    if (accessToken == null || !mounted) return;

    ref
        .read(driveAttachmentNotifierProvider(widget.composerId).notifier)
        .openDrivePicker(platformUrl: platformUrl, accessToken: accessToken);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DriveAttachmentState>(
      driveAttachmentNotifierProvider(widget.composerId),
      (_, next) {
        if (next is DriveIntentPending && !_modalOpen) {
          _openModal(next);
        }
      },
    );

    final fqdn = ref.watch(workplaceFqdnProvider);
    if (fqdn == null || fqdn.isEmpty) return const SizedBox.shrink();

    final driveState =
        ref.watch(driveAttachmentNotifierProvider(widget.composerId));
    if (driveState is DriveAttachmentFetchingIntent) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.iconColor,
        ),
      );
    }

    return TMailButtonWidget.fromIcon(
      icon: widget.imagePaths.icCloud,
      iconColor: widget.iconColor,
      backgroundColor: Colors.transparent,
      iconSize: widget.iconSize,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      tooltipMessage: AppLocalizations.of(context).browse,
      onTapActionCallback: _onTap,
    );
  }
}
