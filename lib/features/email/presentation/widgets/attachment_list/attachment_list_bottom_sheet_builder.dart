import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_bottom_sheet_body_builder.dart';

typedef OnDownloadAllButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class AttachmentListBottomSheetBuilder {
  final BuildContext _context;
  final List<Attachment> _attachments;
  final ImagePaths _imagePaths;
  final ScrollController _scrollController;

  late double _statusBarHeight;

  OnDownloadAllButtonAction? _onDownloadAllButtonAction;
  OnDownloadAttachmentFileAction? _onDownloadAttachmentFileAction;
  OnViewAttachmentFileAction? _onViewAttachmentFileAction;
  OnCancelButtonAction? _onCancelButtonAction;
  OnCloseButtonAction? _onCloseButtonAction;

  AttachmentListBottomSheetBuilder(
    this._context,
    this._attachments,
    this._imagePaths,
    this._scrollController,
  ) {
    _statusBarHeight = Get.statusBarHeight / MediaQuery.of(_context).devicePixelRatio;
  }

  void onDownloadAllButtonAction(OnDownloadAllButtonAction? onDownloadAllButtonAction) {
    _onDownloadAllButtonAction = onDownloadAllButtonAction;
  }

  void onDownloadAttachmentFileAction(OnDownloadAttachmentFileAction onDownloadAttachmentFileAction) {
    _onDownloadAttachmentFileAction = onDownloadAttachmentFileAction;
  }

  void onViewAttachmentFileAction(OnViewAttachmentFileAction onViewAttachmentFileAction) {
    _onViewAttachmentFileAction = onViewAttachmentFileAction;
  }

  void onCancelButtonAction(OnCancelButtonAction onCancelButtonAction) {
    _onCancelButtonAction = onCancelButtonAction;
  }

  void onCloseButtonAction(OnCloseButtonAction onCloseButtonAction) {
    _onCloseButtonAction = onCloseButtonAction;
  }

  Future show() {
    return showModalBottomSheet(
      context: _context,
      isScrollControlled: true,
      barrierColor: AttachmentListStyles.barrierColor,
      backgroundColor: AttachmentListStyles.modalBackgroundColor,
      enableDrag: false,
      builder: (context) => AttachmentListBottomSheetBodyBuilder(
        imagePaths: _imagePaths,
        attachments: _attachments,
        statusBarHeight: _statusBarHeight,
        scrollController: _scrollController,
        onDownloadAllButtonAction: _onDownloadAllButtonAction,
        onDownloadAttachmentFileAction: _onDownloadAttachmentFileAction,
        onViewAttachmentFileAction: _onViewAttachmentFileAction,
        onCancelButtonAction: _onCancelButtonAction,
        onCloseButtonAction: _onCloseButtonAction,
      ),
    );
  }
}