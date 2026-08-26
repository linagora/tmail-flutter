import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/html_viewer/html_iframe_widget.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:universal_html/html.dart' as html;
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/model/drive_origin_validator.dart';
import 'package:workplace/presentation/view/drive_intent_skeleton_loader.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal_shell.dart';

class DriveIntentWebViewModal extends StatefulWidget {
  final DriveIntentLoader intentLoader;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets imageAssets;

  const DriveIntentWebViewModal({
    super.key,
    required this.intentLoader,
    required this.filePickerConfig,
    required this.imageAssets,
  });

  @override
  State<DriveIntentWebViewModal> createState() =>
      _DriveIntentWebViewModalState();
}

class _DriveIntentWebViewModalState extends State<DriveIntentWebViewModal>
    with DriveIntentMessageHandlerMixin, WebWindowMessageMixin<DriveIntentWebViewModal> {
  html.IFrameElement? _iframeElement;

  @override
  DriveOriginValidator get originValidator => const WebDriveOriginValidator();

  bool wideScreen(BuildContext context) {
    return ResponsiveUtils().isDesktop(context) ||
        ResponsiveUtils().isTabletLarge(context);
  }

  Widget _loadingWidget({
    required bool wideScreen,
    TMailButtonWidget? closeButton,
  }) {
    if (wideScreen) {
      return DriveIntentSkeletonLoader.table(
        imageAssets: widget.imageAssets,
        closeButton: closeButton,
      );
    }
    return DriveIntentSkeletonLoader.list(
      imageAssets: widget.imageAssets,
      closeButton: closeButton,
    );
  }

  @override
  void initState() {
    super.initState();
    // The modal owns its listener: bound to its own lifetime, not the opener's
    // (a context menu tile pops its route on tap and would tear it down early).
    // Registered before the iframe can post its first ready message.
    startWindowMessageListener(_forwardMessage);
    startLoading(widget.intentLoader);
  }

  @override
  Future<void> loadIntent(WorkplaceIntent intent) async {
    // No web equivalent of mobile's onReceivedError: cross-origin iframes
    // expose no navigation-failure signal, and probing the URL first could
    // false-close on CSP mismatches — readyTimeout is the only safe fallback.
    _iframeElement!.src = intent.intentUrl.toString();
  }

  void _forwardMessage(String raw, String? origin) =>
      onMessage(raw: raw, origin: origin);

  @override
  void onCleanup() {
    stopWindowMessageListener();
  }

  @override
  void dispose() {
    // Guards routes popped outside the finish path (system back, parent nav);
    // onCleanup is idempotent.
    onCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = wideScreen(context);
    final shell = DriveIntentWebViewModalShell(
      insetPadding: isWideScreen
          ? const EdgeInsets.all(24)
          : EdgeInsets.zero,
      constraints: isWideScreen
          ? const BoxConstraints(maxWidth: 800, maxHeight: 677)
          : const BoxConstraints.expand(),
      shape: isWideScreen
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            )
          : const RoundedRectangleBorder(),
      haveCloseButton: !isWideScreen,
      alignment: isWideScreen ? Alignment.center : null,
      closeIconPath: widget.imageAssets.closeIcon,
      onClose: cancel,
      onBarrierTap: () {
        if (!showSkeleton) cancel();
      },
      loadingWidget: showSkeleton
          ? (closeButton) => _loadingWidget(
              wideScreen: isWideScreen,
              closeButton: closeButton,
            )
          : null,
      child: HtmlIframeWidget(
        key: const ValueKey('drive-intent-webview'),
        borderRadius: 6,
        onIframeCreated: (iframe) {
          final viewRecreated = _iframeElement != null &&
              !identical(_iframeElement, iframe);
          _iframeElement = iframe;
          notifyPlatformViewReady(viewRecreated: viewRecreated);
        },
      ),
    );
    // Keep the iframe ancestry stable across resize (#4738).
    return Stack(
      children: [
        Positioned.fill(
          child: PointerInterceptor(child: const SizedBox.expand()),
        ),
        SafeArea(
          top: !isWideScreen,
          left: false,
          right: false,
          bottom: false,
          child: shell,
        ),
      ],
    );
  }

  @override
  Future<void> sendAck() async {
    // data: URIs have opaque 'null' origin — postMessage requires '*' for those.
    final targetOrigin = intentOrigin == 'null' ? '*' : intentOrigin;
    // dart:html's postMessage structured-clones the Map into a real JS
    // object, which is what Drive's getFilePickerConfig expects.
    _iframeElement?.contentWindow?.postMessage(widget.filePickerConfig.toJson(), targetOrigin);
  }
}
