
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDeleteAttachmentAction = void Function(UploadFileState fileState);

class AttachmentFileComposerBuilder extends StatelessWidget with AppLoaderMixin {

  final _imagePaths = Get.find<ImagePaths>();

  final UploadFileState fileState;
  final double? maxWidth;
  final EdgeInsetsGeometry? itemMargin;
  final OnDeleteAttachmentAction? onDeleteAttachmentAction;
  final Widget? buttonAction;

  AttachmentFileComposerBuilder(this.fileState, {
    super.key,
    this.maxWidth,
    this.itemMargin,
    this.buttonAction,
    this.onDeleteAttachmentAction,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent ,
            highlightColor: Colors.transparent),
        child: Container(
          margin: itemMargin ?? EdgeInsets.zero,
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          width: maxWidth,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
              color: Colors.white),
          child: Stack(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              focusColor: AppColor.primaryColor,
              hoverColor: AppColor.primaryColor,
              onTap: () {},
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                  bottom: PlatformInfo.isWeb ? 6 : 14
                ),
                child: SvgPicture.asset(
                    fileState.getIcon(_imagePaths),
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill),
              ),
              title: Transform(
                  transform: Matrix4.translationValues(
                    DirectionUtils.isDirectionRTLByLanguage(context) ? 0.0 : (PlatformInfo.isWeb ? 0.0 : -8.0),
                    PlatformInfo.isWeb ? -8.0 : -10.0,
                    0.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: PlatformInfo.isWeb ? 20 : 16),
                    child: ExtendedText(
                      fileState.fileName,
                      maxLines: 1,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      overflowWidget: TextOverflowWidget(
                        position: Directionality.maybeOf(context) == TextDirection.rtl
                          ? TextOverflowPosition.start
                          : TextOverflowPosition.end,
                        child: const Text(
                          '...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  )
              ),
              subtitle: fileState.fileSize != 0
                  ? Transform(
                      transform: Matrix4.translationValues(
                        DirectionUtils.isDirectionRTLByLanguage(context) ? 0.0 : PlatformInfo.isWeb ? 0.0 : -8.0,
                        PlatformInfo.isWeb ? -8.0 : -10.0,
                        0.0),
                      child: Text(
                          filesize(fileState.fileSize),
                          maxLines: 1,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColor.colorContentEmail)))
                  : null,
            ),
            PositionedDirectional(
              end: PlatformInfo.isWeb ? -5 : -12,
              top: PlatformInfo.isWeb ? -5 : -12,
              child: buildIconWeb(
                icon: SvgPicture.asset(_imagePaths.icDeleteAttachment, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).delete,
                onTap: () {
                  if (onDeleteAttachmentAction != null) {
                    onDeleteAttachmentAction!.call(fileState);
                  }
                }
              )
            ),
            Align(alignment: AlignmentDirectional.bottomCenter, child: _progressLoading),
          ]),
        )
    );
  }

  Widget get _progressLoading {
    switch(fileState.uploadStatus) {
      case UploadFileStatus.waiting:
        return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 50),
            child: horizontalLoadingWidget);
      case UploadFileStatus.uploading:
        return Padding(
            padding: const EdgeInsets.only(top: 50),
            child: horizontalPercentLoadingWidget(fileState.percentUploading));
      case UploadFileStatus.uploadFailed:
      case UploadFileStatus.succeed:
        return const SizedBox.shrink();
    }
  }
}