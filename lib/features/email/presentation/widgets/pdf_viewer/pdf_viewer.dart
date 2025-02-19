import 'dart:async';

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
import 'package:tmail_ui_user/features/email/domain/exceptions/download_attachment_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/loading_options.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/previewer_state.dart';
import 'package:twake_previewer_flutter/core/previewer_options/options/top_bar_options.dart';
import 'package:twake_previewer_flutter/core/previewer_options/previewer_options.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/twake_pdf_previewer.dart';

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

  final ValueNotifier<Object?> _pdfViewStateNotifier = ValueNotifier<Object?>(null);

  final DeviceInfoPlugin _deviceInfoPlugin = Get.find<DeviceInfoPlugin>();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _deviceInfoPlugin.deviceInfo,
      builder: (context, deviceInfo) {
        BrowserName? browserName;
        if (deviceInfo.hasData && deviceInfo.data is WebBrowserInfo) {
          browserName = (deviceInfo.data as WebBrowserInfo).browserName;
        }

        return ValueListenableBuilder(
          valueListenable: _pdfViewStateNotifier,
          builder: (context, viewState, child) {
            final previewerState = switch (viewState) {
              DownloadAttachmentForWebSuccess() => PreviewerState.success,
              DownloadAttachmentForWebFailure() => PreviewerState.failure,
              DownloadingAttachmentForWeb() => PreviewerState.loading,
              _ => PreviewerState.idle,
            };
        
            final bytes = switch (viewState) {
              DownloadAttachmentForWebSuccess(bytes: final bytes) => bytes,
              _ => null,
            };
        
            final downloadProgress = switch (viewState) {
              DownloadingAttachmentForWeb(progress: final progress) => progress / 100,
              _ => 0.0,
            };
        
            final progressText = switch (viewState) {
              DownloadingAttachmentForWeb(progress: final progress) => '${progress.round()}%',
              _ => '',
            };
        
            final title = switch (viewState) {
              DownloadAttachmentForWebSuccess(attachment: final attachment) => attachment.generateFileName(),
              _ => '',
            };
            
            return TwakePdfPreviewer(
              bytes: Uint8List.fromList(bytes ?? []),
              previewerOptions: PreviewerOptions(
                previewerState: previewerState,
                onError: (error) {
                  logError('_PDFViewerState::build:openData:onError:: $error');
                  _pdfViewStateNotifier.value = DownloadAttachmentForWebFailure(exception: error);
                },
                errorMessage: AppLocalizations.of(context).noPreviewAvailable,
              ),
              loadingOptions: LoadingOptions(
                progress: downloadProgress,
                progressColor: AppColor.primaryColor,
                text: progressText,
              ),
              onTapOutside: _closeView,
              topBarOptions: TopBarOptions(
                title: title,
                onDownload: bytes != null 
                  ? () => widget.downloadAction?.call(bytes, title)
                  : null,
                onPrint: browserName != null && isBrowserSupportedPrinting(browserName) && bytes != null
                  ? () => widget.printAction?.call(bytes, title)
                  : null,
                onClose: _closeView,
              ),
            );
          },
        );
      }
    );
  }

  void _closeView() {
    _downloadAttachmentCancelToken?.cancel();
    Navigator.maybeOf(context)?.pop();
  }
}
