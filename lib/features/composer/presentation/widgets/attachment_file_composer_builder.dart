
import 'package:core/core.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDeleteAttachmentAction = void Function(Attachment attachment);

class AttachmentFileComposerBuilder {

  final BuildContext context;
  final ImagePaths imagePaths;
  final Attachment attachment;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets? itemMargin;

  OnDeleteAttachmentAction? _onDeleteAttachmentAction;

  Widget? buttonAction;

  AttachmentFileComposerBuilder(
      this.context,
      this.imagePaths,
      this.attachment,
      {
        this.maxWidth,
        this.maxHeight,
        this.itemMargin,
      }
  );

  void addOnDeleteAttachmentAction(OnDeleteAttachmentAction onDeleteAttachmentAction) {
    _onDeleteAttachmentAction = onDeleteAttachmentAction;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent ,
        highlightColor: Colors.transparent),
      child: Container(
        margin: itemMargin ?? EdgeInsets.zero,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        width: maxWidth,
        height: maxHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
          color: Colors.white),
        child: Stack(children: [
          ListTile(
              contentPadding: const EdgeInsets.only(right: kIsWeb ? 16 : 18),
              onTap: () {},
              leading: Transform(
                  transform: Matrix4.translationValues(8.0, kIsWeb ? -3.0 : -5.0, 0.0),
                  child: SvgPicture.asset(imagePaths.icFileAttachment, fit: BoxFit.fill)),
              title: Transform(
                  transform: Matrix4.translationValues(kIsWeb ? -4.0 : -10.0, kIsWeb ? -6.0 : -9.0, 0.0),
                  child: Text(
                    attachment.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColor.colorNameEmail, fontWeight: FontWeight.w500),
                  )),
              subtitle: attachment.size != null && attachment.size?.value != 0
                  ? Transform(
                      transform: Matrix4.translationValues(kIsWeb ? -4.0 : -10.0, kIsWeb ? -5.0 : -8.0, 0.0),
                      child: Text(
                          filesize(attachment.size?.value, 0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal)))
                  : null,
          ),
          Positioned(right: kIsWeb ? -5 : -12, top: kIsWeb ? -5 : -12, child: buildIconWeb(
              icon: SvgPicture.asset(imagePaths.icDeleteAttachment, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).delete,
              onTap: () => _onDeleteAttachmentAction?.call(attachment)))
        ]),
      )
    );
  }
}