
import 'package:core/core.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';

typedef OnDownloadAttachmentFileActionClick = void Function(Attachment attachment);
typedef OnExpandAttachmentActionClick = void Function();

class AttachmentFileTileBuilder {

  final ImagePaths _imagePaths;
  final Attachment _attachment;
  final int _attachmentSize;
  final int _limitDisplayAttachment;
  ExpandMode? _expandMode;

  OnDownloadAttachmentFileActionClick? _onDownloadAttachmentFileActionClick;
  OnExpandAttachmentActionClick? _onExpandAttachmentActionClick;

  Widget? buttonAction;
  double? heightItem;

  AttachmentFileTileBuilder(
    this._imagePaths,
    this._attachment,
    this._attachmentSize,
    this._limitDisplayAttachment,
  );

  void onDownloadAttachmentFileActionClick(OnDownloadAttachmentFileActionClick onDownloadAttachmentFileActionClick) {
    _onDownloadAttachmentFileActionClick = onDownloadAttachmentFileActionClick;
  }

  void onExpandAttachmentActionClick(OnExpandAttachmentActionClick onExpandAttachmentActionClick) {
    _onExpandAttachmentActionClick = onExpandAttachmentActionClick;
  }

  void setExpandMode(ExpandMode? expandMode) {
    _expandMode = expandMode;
  }

  void addButtonAction(Widget action) {
    buttonAction = action;
  }

  void height(double height) {
    heightItem = height;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent ,
        highlightColor: Colors.transparent),
      child: Container(
        key: const Key('attach_file_tile'),
        alignment: Alignment.center,
        margin: EdgeInsets.only(top:heightItem != null ? 8 : 0),
        height: heightItem,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.attachmentFileBorderColor),
          color: Colors.white),
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.zero),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                focusColor: AppColor.primaryColor,
                hoverColor: AppColor.primaryColor,
                onTap: () {
                  if (_onDownloadAttachmentFileActionClick != null) {
                    _onDownloadAttachmentFileActionClick!(_attachment);
                  }},
                leading: Transform(
                  transform: Matrix4.translationValues(14.0, 2.0, 0.0),
                  child: SvgPicture.asset(_imagePaths.icFileAttachment, width: 24, height: 24, fit: BoxFit.fill)),
                title: Transform(
                  transform: Matrix4.translationValues(-8.0, -8.0, 0.0),
                  child: Text(
                    _attachment.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColor.attachmentFileNameColor, fontWeight: FontWeight.w500),
                  )),
                subtitle: _attachment.size != null && _attachment.size?.value != 0
                  ? Transform(
                      transform: Matrix4.translationValues(-8.0, -8.0, 0.0),
                      child: Text(
                        filesize(_attachment.size?.value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColor.attachmentFileSizeColor)))
                  : null,
                trailing: buttonAction != null
                  ? Transform(
                      transform: Matrix4.translationValues(-5.0, heightItem != null ? -6.0 : 0.0, 0.0),
                      child: buttonAction)
                  : null
              ),
              if (buttonAction == null)
                Transform(
                  transform: Matrix4.translationValues(5.0, 5.0, 0.0),
                  child: IconButton(
                    icon: SvgPicture.asset(_imagePaths.icDownload, width: 24, height: 24, fit: BoxFit.fill),
                    onPressed: () {
                      if (_onDownloadAttachmentFileActionClick != null) {
                        _onDownloadAttachmentFileActionClick!(_attachment);
                      }
                    }
                  )),
              if (_attachmentSize > _limitDisplayAttachment && _expandMode == ExpandMode.COLLAPSE) _buildItemBackground()
            ]
          )
        )
      )
    );
  }

  Widget _buildItemBackground() {
    return GestureDetector(
      onTap: () {
        if (_onExpandAttachmentActionClick != null) {
          _onExpandAttachmentActionClick!();
        }
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(color: AppColor.backgroundCountAttachment),
          Text(
            '+${_attachmentSize - _limitDisplayAttachment + 1}',
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}