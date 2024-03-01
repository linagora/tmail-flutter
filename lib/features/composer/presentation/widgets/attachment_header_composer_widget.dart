import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_header_composer_widget_style.dart';
import 'package:tmail_ui_user/features/upload/presentation/extensions/list_upload_file_state_extension.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

typedef OnToggleExpandAttachmentViewAction = Function(bool isCollapsed);

class AttachmentHeaderComposerWidget extends StatelessWidget {

  final List<UploadFileState> listFileUploaded;
  final bool isCollapsed;
  final OnToggleExpandAttachmentViewAction onToggleExpandAction;

  final _imagePaths = Get.find<ImagePaths>();

  AttachmentHeaderComposerWidget({
    super.key,
    required this.listFileUploaded,
    required this.isCollapsed,
    required this.onToggleExpandAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggleExpandAction.call(isCollapsed),
      child: Container(
        padding: AttachmentHeaderComposerWidgetStyle.padding,
        decoration: isCollapsed
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AttachmentHeaderComposerWidgetStyle.borderColor,
                  width: 1
                )
              )
            ),
        child: Row(
          children: [
            TMailButtonWidget.fromIcon(
              icon: isCollapsed
                ? _imagePaths.icArrowRight
                : _imagePaths.icArrowBottom,
              iconSize: AttachmentHeaderComposerWidgetStyle.iconSize,
              iconColor: AttachmentHeaderComposerWidgetStyle.iconColor,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              onTapActionCallback: () => onToggleExpandAction.call(isCollapsed),
            ),
            const SizedBox(width: AttachmentHeaderComposerWidgetStyle.space / 2),
            Text(
              '${listFileUploaded.length} ${AppLocalizations.of(context).attachments}',
              style: AttachmentHeaderComposerWidgetStyle.labelTextSize
            ),
            const SizedBox(width: AttachmentHeaderComposerWidgetStyle.space),
            Container(
              decoration: const BoxDecoration(
                color: AttachmentHeaderComposerWidgetStyle.sizeLabelBackground,
                borderRadius: BorderRadius.all(Radius.circular(AttachmentHeaderComposerWidgetStyle.sizeLabelRadius))
              ),
              padding: AttachmentHeaderComposerWidgetStyle.sizeLabelPadding,
              child: Text(
                filesize(listFileUploaded.totalSize),
                style: AttachmentHeaderComposerWidgetStyle.sizeLabelTextSize,
              ),
            ),
            if (_isExceedMaximumSizeFileAttachedInComposer)
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icQuotasWarning,
                iconSize: 20,
                margin: const EdgeInsetsDirectional.only(start: 4),
                padding: const EdgeInsets.all(3),
                iconColor: AppColor.colorBackgroundQuotasWarning,
                tooltipMessage: AppLocalizations.of(context).warningMessageWhenExceedGenerallySizeInComposer,
                backgroundColor: Colors.transparent,
              )
          ],
        ),
      ),
    );
  }

  bool get _isExceedMaximumSizeFileAttachedInComposer =>
    listFileUploaded.totalSize > AppConfig.warningAttachmentFileSizeInMegabytes * 1024 * 1024;
}
