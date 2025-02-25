import 'dart:async';
import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tmail_ui_user/features/base/widget/circle_loading_widget.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/download_attachment_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pagination_pdf_viewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/top_bar_attachment_viewer.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef DownloadPDFFileAction = Function(Uint8List bytes, String fileName);
typedef PrintPDFFileAction = Function(Uint8List bytes, String fileName);

class PDFViewer extends StatefulWidget {
  final Attachment attachment;
  final AccountId accountId;
  final String downloadUrl;
  final DownloadPDFFileAction? downloadAction;
  final PrintPDFFileAction? printAction;

  const PDFViewer({
    super.key,
    required this.attachment,
    required this.accountId,
    required this.downloadUrl,
    this.downloadAction,
    this.printAction,
  });

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  late DownloadAttachmentForWebInteractor? _downloadAttachmentForWebInteractor;
  late StreamController<dartz.Either<Failure, Success>> _downloadAttachmentStreamController;
  late StreamSubscription<dartz.Either<Failure, Success>> _downloadAttachmentStreamSubscription;

  StreamSubscription<dartz.Either<Failure, Success>>? _downloadInteractorStreamSubscription;
  CancelToken? _downloadAttachmentCancelToken;

  final PdfViewerController _pdfViewerController = PdfViewerController();
  final ValueNotifier<Object?> _pdfViewStateNotifier = ValueNotifier<Object?>(null);

  final DeviceInfoPlugin _deviceInfoPlugin = Get.find<DeviceInfoPlugin>();
  final FocusNode _keyboardFocusNode = FocusNode();
  final _showPagination = ValueNotifier<bool>(false);
  static const double _scrollbarWidth = 10;
  static const double _minScale = 1;
  static const double _maxScale = 4;

  @override
  void initState() {
    super.initState();
    _initialStreamListener();
    _downloadAttachmentAction();
  }
  
  void _initialStreamListener() {
    _downloadAttachmentStreamController = StreamController<dartz.Either<Failure, Success>>.broadcast();
    
    _downloadAttachmentStreamSubscription = _downloadAttachmentStreamController.stream.listen((viewState) {
      viewState.fold(
        (failure) => _pdfViewStateNotifier.value = failure,
        (success) => _pdfViewStateNotifier.value = success
      );
    });
  }
  
  void _downloadAttachmentAction() {
    _downloadAttachmentForWebInteractor = getBinding<DownloadAttachmentForWebInteractor>();

    if (_downloadAttachmentForWebInteractor == null) {
      _pdfViewStateNotifier.value = DownloadAttachmentForWebFailure(exception: DownloadAttachmentInteractorIsNull());
      return;
    }

    _downloadAttachmentCancelToken = CancelToken();
    _downloadInteractorStreamSubscription = _downloadAttachmentForWebInteractor!.execute(
      DownloadTaskId(widget.attachment.blobId!.value),
      widget.attachment, 
      widget.accountId,
      widget.downloadUrl,
      _downloadAttachmentStreamController,
      cancelToken: _downloadAttachmentCancelToken
    ).listen((viewState) {
      viewState.fold(
        (failure) => _pdfViewStateNotifier.value = failure,
        (success) => _pdfViewStateNotifier.value = success
      );
    });
  }

  bool isBrowserSupportedPrinting(BrowserName browserName) => !(browserName == BrowserName.edge
    || browserName == BrowserName.firefox
    || browserName == BrowserName.safari);

  @override
  void dispose() {
    _pdfViewStateNotifier.dispose();
    _downloadAttachmentStreamSubscription.cancel();
    _downloadAttachmentStreamController.close();
    _downloadInteractorStreamSubscription?.cancel();
    _downloadInteractorStreamSubscription = null;
    _downloadAttachmentCancelToken = null;
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyboardEventListener,
      child: Center(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder(
                  valueListenable: _pdfViewStateNotifier,
                  builder: (context, viewState, widget) {
                    if (viewState is DownloadAttachmentForWebSuccess) {
                      return PdfViewer.data(
                        viewState.bytes,
                        sourceName: this.widget.attachment.generateFileName(),
                        controller: _pdfViewerController,
                        params: PdfViewerParams(
                          panAxis: PanAxis.vertical,
                          scrollByMouseWheel: 0.5,
                          backgroundColor: Colors.transparent,
                          onViewerReady: (_, __) {
                            _pdfViewerController.setZoom(
                              _pdfViewerController.centerPosition,
                              1);
                            _showPagination.value = true;
                          },
                          calculateCurrentPageNumber: _calculateCurrentPageNumber,
                          minScale: _minScale,
                          maxScale: _maxScale,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          onInteractionEnd: (details) {
                            if (_pdfViewerController.currentZoom < _minScale) {
                              _pdfViewerController.setZoom(
                                _pdfViewerController.centerPosition,
                                _minScale,
                              );
                            } else if (_pdfViewerController.currentZoom > _maxScale) {
                              _pdfViewerController.setZoom(
                                _pdfViewerController.centerPosition,
                                _maxScale,
                              );
                            }
                          },
                          layoutPages: (pages, params) => _layoutPdf(
                            context,
                            pages,
                            params,
                          ),
                          viewerOverlayBuilder: (_, __, ___) => [
                            Positioned(
                              left: 0,
                              height: _pdfViewerController.documentSize.height,
                              width: _tapOutSideZoneWidth,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: _closeView,
                                child: const IgnorePointer(
                                  child: SizedBox.expand(),
                                ),
                              ),
                            ),
                            Positioned(
                              right: _scrollbarWidth,
                              height: _pdfViewerController.documentSize.height,
                              width: _tapOutSideZoneWidth - _scrollbarWidth,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: _closeView,
                                child: const IgnorePointer(
                                  child: SizedBox.expand(),
                                ),
                              ),
                            ),
                            PdfViewerScrollThumb(
                              controller: _pdfViewerController,
                              orientation: ScrollbarOrientation.right,
                              thumbSize: const Size(_scrollbarWidth, 100),
                              thumbBuilder: (_, __, ___, ____) => const ColoredBox(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (viewState is DownloadingAttachmentForWeb) {
                      return CircularPercentIndicator(
                        percent: viewState.progress / 100,
                        progressColor: AppColor.primaryColor,
                        lineWidth: 4.0,
                        backgroundColor: Colors.white,
                        radius: 40,
                        center: Text(
                          '${viewState.progress.round()}%',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      );
                    } else if (viewState is DownloadAttachmentForWebFailure) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context).noPreviewAvailable,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircleLoadingWidget(
                          size: 80,
                          strokeWidth: 4.0,
                        )
                      );
                    }
                  },
                )
              ),
            ),
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: ValueListenableBuilder(
                valueListenable: _pdfViewStateNotifier,
                builder: (context, viewState, child) {
                  if (viewState is DownloadAttachmentForWebSuccess) {
                    return FutureBuilder<BaseDeviceInfo>(
                      future: _deviceInfoPlugin.deviceInfo,
                      builder: (context, deviceInfo) {
                        BrowserName? browserName;
                        if (deviceInfo.hasData && deviceInfo.data is WebBrowserInfo) {
                          browserName = (deviceInfo.data as WebBrowserInfo).browserName;
                        }
                        return TopBarAttachmentViewer(
                          title: widget.attachment.generateFileName(),
                          downloadAction: () => widget.downloadAction?.call(
                            viewState.bytes,
                            widget.attachment.generateFileName()
                          ),
                          printAction: browserName != null && isBrowserSupportedPrinting(browserName)
                            ? () => widget.printAction?.call(viewState.bytes, widget.attachment.generateFileName())
                            : null,
                        );
                      });
                  }
                  return child ?? const SizedBox.shrink();
                },
                child: TopBarAttachmentViewer(
                  title: widget.attachment.generateFileName(),
                  closeAction: _closeView,
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _showPagination,
              builder: (context, showPagination, child) {
                if (!showPagination) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: PaginationPDFViewer(
                    pdfViewerController: _pdfViewerController,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int? _calculateCurrentPageNumber(
    Rect visibleRect,
    List<Rect> pageRects,
    PdfViewerController controller,
  ) {
    if (pageRects.isEmpty) {
      return null;
    }

    if (pageRects.first.top == visibleRect.top) {
      return 1; // view at top
    }

    if (pageRects.last.bottom == visibleRect.bottom) {
      return pageRects.length; // view at bottom
    }

    final intersectRatios = <double>[];
    for (var i = 0; i < pageRects.length; i++) {
      final intersect = pageRects[i].intersect(visibleRect);
      if (intersect.isEmpty) {
        intersectRatios.add(0);
        continue;
      }

      final intersectRatio = (intersect.width * intersect.height) / (pageRects[i].width * pageRects[i].height);
      intersectRatios.add(intersectRatio);
    }
    final maxIntersectRatio = intersectRatios.reduce(max);
    return intersectRatios.indexOf(maxIntersectRatio) + 1;
  }

  void _closeView() {
    _downloadAttachmentCancelToken?.cancel();
    Navigator.maybeOf(context)?.pop();
  }

  void _handleKeyboardEventListener(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _closeView();
    }
  }

  double get _tapOutSideZoneWidth {
    final documentWidth = _pdfViewerController.documentSize.width
      - _pdfViewerController.params.margin * 2;
    final documentRenderWidth = documentWidth * _pdfViewerController.currentZoom;
    final viewSizeWidth = _pdfViewerController.viewSize.width;

    return viewSizeWidth > documentRenderWidth
      ? (viewSizeWidth - documentRenderWidth) / 2
      : 0;
  }

  PdfPageLayout _layoutPdf(
    BuildContext context,
    List<PdfPage> pages,
    PdfViewerParams params,
  ) {
    final viewWidth = MediaQuery.sizeOf(context).width;
    final viewHeight = MediaQuery.sizeOf(context).height;
    final width = pages.fold(
      0.0,
      (prev, page) => max(prev, page.width)) + params.margin * 2;
    final pageLayouts = <Rect>[];
    double top = params.margin;
    for (final page in pages) {
      pageLayouts.add(
        Rect.fromLTWH(
          viewWidth > viewHeight
            ? (width - page.width) / 2
            : 0,
          top,
          page.width,
          page.height,
        ),
      );
      top += page.height + params.margin;
    }

    return PdfPageLayout(
      pageLayouts: pageLayouts,
      documentSize: Size(width, top),
    );
  }
}
