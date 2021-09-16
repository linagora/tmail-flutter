
import 'package:core/core.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';

typedef OnDownloadAttachmentFileActionClick = void Function(Attachment attachment);

class AttachmentFileTileBuilder {

  final ImagePaths _imagePaths;
  final Attachment _attachment;

  OnDownloadAttachmentFileActionClick? _onDownloadAttachmentFileActionClick;

  AttachmentFileTileBuilder(this._imagePaths, this._attachment);

  void onDownloadAttachmentFileActionClick(OnDownloadAttachmentFileActionClick onDownloadAttachmentFileActionClick) {
    _onDownloadAttachmentFileActionClick = onDownloadAttachmentFileActionClick;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent ,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('attach_file_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.attachmentFileBorderColor),
          color: Colors.white),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            focusColor: AppColor.primaryColor,
            hoverColor: AppColor.primaryColor,
            onTap: () {
              if (_onDownloadAttachmentFileActionClick != null) {
                _onDownloadAttachmentFileActionClick!(_attachment);
              }},
            leading: Transform(
              transform: Matrix4.translationValues(14.0, 2.0, 0.0),
              child: SvgPicture.asset(_imagePaths.icAttachmentFile, width: 24, height: 24, fit: BoxFit.fill)),
            title: Transform(
              transform: Matrix4.translationValues(-8.0, -8.0, 0.0),
              child: Text(
                _attachment.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColor.attachmentFileNameColor, fontWeight: FontWeight.w500),
              )),
            subtitle: _attachment.size != null && _attachment.size?.value != 0
              ? Transform(
                  transform: Matrix4.translationValues(-8.0, -8.0, 0.0),
                  child: Text(
                    filesize(_attachment.size?.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColor.attachmentFileSizeColor)))
              : null
          ),
        )
      )
    );
  }
}