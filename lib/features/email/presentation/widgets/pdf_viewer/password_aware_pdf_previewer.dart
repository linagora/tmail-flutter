import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/loading_options.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/previewer_state.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/top_bar_options.dart';
import 'package:twake_previewer_flutter/core/previewer_options/previewer_options.dart';
import 'package:twake_previewer_flutter/core/utils/utils.dart';
import 'package:twake_previewer_flutter/core/widgets/previewer_template_widget.dart';
import 'package:twake_previewer_flutter/core/widgets/top_bar_widget.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/widgets/pdf_pagination_widget.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/widgets/pdf_previewer.dart';

/// Same layout as `TwakePdfPreviewer`, but forwards a [PdfPasswordProvider]
/// to pdfrx so that encrypted PDFs can be opened.
class PasswordAwarePdfPreviewer extends StatefulWidget {
  const PasswordAwarePdfPreviewer({
    super.key,
    required this.previewerOptions,
    required this.passwordProvider,
    this.bytes,
    this.loadingOptions,
    this.topBarOptions,
    this.onTapOutside,
    this.errorBannerBuilder,
  });

  final PreviewerOptions previewerOptions;
  final PdfPasswordProvider passwordProvider;
  final Uint8List? bytes;
  final LoadingOptions? loadingOptions;
  final TopBarOptions? topBarOptions;
  final VoidCallback? onTapOutside;
  final PdfViewerErrorBannerBuilder? errorBannerBuilder;

  @override
  State<PasswordAwarePdfPreviewer> createState() => _PasswordAwarePdfPreviewerState();
}

class _PasswordAwarePdfPreviewerState extends State<PasswordAwarePdfPreviewer> {
  final _pdfViewerController = PdfViewerController();
  final _keyboardFocusNode = FocusNode();
  bool _pdfViewerIsReady = false;

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBarOptions = widget.topBarOptions;
    final isPreviewSucceeded =
        widget.previewerOptions.previewerState == PreviewerState.success;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (value) => Utils.handleEscapeKey(value, topBarOptions?.onClose),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PreviewerTemplateWidget(
            previewerOptions: widget.previewerOptions,
            loadingOptions: widget.loadingOptions,
            child: _PasswordAwarePdfDocument(
              bytes: widget.bytes ?? Uint8List(0),
              controller: _pdfViewerController,
              passwordProvider: widget.passwordProvider,
              fileName: topBarOptions?.title,
              onTapOutside: widget.onTapOutside,
              onReady: () => setState(() => _pdfViewerIsReady = true),
              errorBannerBuilder: widget.errorBannerBuilder,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: TopBarWidget(
              title: topBarOptions?.title ?? '',
              closeAction: topBarOptions?.onClose,
              printAction: isPreviewSucceeded ? topBarOptions?.onPrint : null,
              downloadAction: isPreviewSucceeded ? topBarOptions?.onDownload : null,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: _pdfViewerIsReady
              ? PdfPaginationWidget(pdfViewerController: _pdfViewerController)
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Reuses the upstream [PdfPreviewer] configuration (layout, zoom, overlays)
/// and only swaps its document source for one carrying a password provider.
class _PasswordAwarePdfDocument extends PdfPreviewer {
  const _PasswordAwarePdfDocument({
    required super.bytes,
    required super.controller,
    required this.passwordProvider,
    super.fileName,
    super.onTapOutside,
    super.onReady,
    super.errorBannerBuilder,
  });

  final PdfPasswordProvider passwordProvider;

  @override
  Widget build(BuildContext context) {
    final upstreamViewer = super.build(context) as PdfViewer;

    return PdfViewer.data(
      bytes,
      sourceName: upstreamViewer.documentRef.sourceName,
      passwordProvider: passwordProvider,
      controller: upstreamViewer.controller,
      params: upstreamViewer.params,
      initialPageNumber: upstreamViewer.initialPageNumber,
    );
  }
}
