
import 'package:core/core.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/email/presentation/model/attachment_file.dart';

typedef OnOpenAttachmentFileActionClick = void Function();

class AttachmentFileTileBuilder {

  final ImagePaths _imagePaths;
  final AttachmentFile _attachmentFile;

  OnOpenAttachmentFileActionClick? _onOpenAttachmentFileActionClick;

  AttachmentFileTileBuilder(this._imagePaths, this._attachmentFile);

  AttachmentFileTileBuilder onOpenAttachmentFileActionClick(
      OnOpenAttachmentFileActionClick onOpenAttachmentFileActionClick) {
    _onOpenAttachmentFileActionClick = onOpenAttachmentFileActionClick;
    return this;
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
            onTap: () {
              if (_onOpenAttachmentFileActionClick != null) {
                _onOpenAttachmentFileActionClick!();
              }},
            leading: Transform(
              transform: Matrix4.translationValues(0.0, 2.0, 0.0),
              child: SvgPicture.asset(_imagePaths.icAttachmentFile, width: 24, height: 24, fit: BoxFit.fill)),
            title: Transform(
              transform: Matrix4.translationValues(-18.0, -8.0, 0.0),
              child: Text(
                _attachmentFile.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColor.attachmentFileNameColor, fontWeight: FontWeight.w500),
              )),
            subtitle: _attachmentFile.size != null && _attachmentFile.size?.value != 0
              ? Transform(
                  transform: Matrix4.translationValues(-18.0, -8.0, 0.0),
                  child: Text(
                    filesize(_attachmentFile.size?.value),
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