
import 'package:core/presentation/resources/image_paths.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/attachment_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_header_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

typedef OnToggleExpandAttachmentAction = void Function(bool isCollapsed);

class AttachmentComposerWidget extends StatefulWidget {

  final List<UploadFileState> listFileUploaded;
  final bool isCollapsed;
  final OnDeleteAttachmentAction onDeleteAttachmentAction;
  final OnToggleExpandAttachmentAction onToggleExpandAttachmentAction;
  final OnPreviewAttachmentAction onPreviewAttachmentAction;

  const AttachmentComposerWidget({
    super.key,
    required this.listFileUploaded,
    required this.isCollapsed,
    required this.onDeleteAttachmentAction,
    required this.onToggleExpandAttachmentAction,
    required this.onPreviewAttachmentAction,
  });

  @override
  State<AttachmentComposerWidget> createState() => _AttachmentComposerWidgetState();
}

class _AttachmentComposerWidgetState extends State<AttachmentComposerWidget> {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.isCollapsed;
  }

  @override
  void dispose() {
    _isCollapsed = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AttachmentComposerWidgetStyle.backgroundColor,
        boxShadow: AttachmentComposerWidgetStyle.shadow
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AttachmentHeaderComposerWidget(
            listFileUploaded: widget.listFileUploaded,
            isCollapsed: _isCollapsed,
            onToggleExpandAction: (isCollapsed) {
              setState(() => _isCollapsed = !isCollapsed);
              widget.onToggleExpandAttachmentAction(!isCollapsed);
            },
          ),
          if (!_isCollapsed)
            Container(
              width: double.infinity,
              padding: AttachmentComposerWidgetStyle.listItemPadding,
              constraints: const BoxConstraints(maxHeight: AttachmentComposerWidgetStyle.maxHeight),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: AttachmentComposerWidgetStyle.listItemSpace,
                  runSpacing: AttachmentComposerWidgetStyle.listItemSpace,
                  children: widget.listFileUploaded
                    .map((file) => AttachmentItemComposerWidget(
                      imagePaths: _imagePaths,
                      fileIcon: file.getIcon(_imagePaths),
                      fileName: file.fileName,
                      fileSize: filesize(file.fileSize),
                      uploadStatus: file.uploadStatus,
                      percentUploading: file.percentUploading,
                      uploadTaskId: file.uploadTaskId,
                      onDeleteAttachmentAction: widget.onDeleteAttachmentAction,
                      onPreviewAttachmentAction: widget.onPreviewAttachmentAction,
                    ))
                    .toList(),
                ),
              ),
            ),
        ]
      ),
    );
  }
}
