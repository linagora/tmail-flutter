import 'dart:async';
import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tmail_ui_user/features/base/widget/circle_loading_widget.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/download_attachment_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pagination_pdf_viewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/top_bar_pdf_viewer.dart';
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
    _pdfViewerController.dispose();
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
                      return PdfViewer.openData(
                        viewState.bytes,
                        viewerController: _pdfViewerController,
                        onError: (error) {
                          logError('_PDFViewerState::build:openData:onError:: $error');
                          _pdfViewStateNotifier.value = DownloadAttachmentForWebFailure(exception: error);
                        },
                        params: PdfViewerParams(
                          panAxis: PanAxis.vertical,
                          scrollByMouseWheel: 0.5,
                          layoutPages: (viewSize, pages) {
                            List<Rect> rect = [];
                            final viewWidth = viewSize.width;
                            final viewHeight = viewSize.height;
                            final maxHeight = pages.fold<double>(0.0, (maxHeight, page) => max(maxHeight, page.height));
                            final maxWidth = pages.fold<double>(0.0, (maxWidth, page) => max(maxWidth, page.width));
                            final ratio = viewHeight / max(maxHeight, maxWidth);
                            log('_PDFViewerState::build: viewWidth = $viewWidth | viewHeight = $viewHeight | maxHeight = $maxHeight | ratio = $ratio');
                            var top = 0.0;
                            double padding = 16.0;
                            for (var page in pages) {
                              final width = page.width * ratio;
                              final height = page.height * ratio;
                              final left = viewWidth > viewHeight ? (viewWidth / 2) - (width / 2) : 0.0;
                              rect.add(Rect.fromLTWH(left, top, width, height));
                              top += height + padding;
                            }
                            return rect;
                          },
                          onClickOutSidePageViewer: _closeView
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
                        return TopBarPDFViewer(
                          attachment: widget.attachment,
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
                child: TopBarPDFViewer(
                  attachment: widget.attachment,
                  closeAction: () {
                    _downloadAttachmentCancelToken?.cancel();
                    Navigator.maybeOf(context)?.pop();
                  },
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _pdfViewerController,
              builder: (_, __, ___) {
                if (_pdfViewerController.isReady) {
                  return Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: PaginationPDFViewer(
                      pdfViewerController: _pdfViewerController,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }
            ),
            ValueListenableBuilder(
              valueListenable: _pdfViewerController,
              builder: (context, m, child) {
                if (!_pdfViewerController.isReady) return Container();
                final v = _pdfViewerController.viewRect;
                final all = _pdfViewerController.fullSize;
                final top = v.top / all.height * v.height;
                final height = v.height / all.height * v.height;
                return Positioned(
                  right: 0,
                  top: top,
                  height: height,
                  width: 8,
                  child: Container(color: AppColor.colorTextBody),
                );
              },
            ),
          ],
        ),
      ),
    );
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
}
