import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnToggleExpandAttachmentPinAction = Function(bool isCollapsed);

class EmailAttachmentsPinHeaderWidget extends StatelessWidget {
  final int countAttachments;
  final num totalSizeAttachments;
  final bool isCollapsed;
  final bool isMobile;
  final ImagePaths imagePaths;
  final OnToggleExpandAttachmentPinAction onToggleExpandAction;
  final OnTapActionCallback? onDownloadAllAttachmentsAction;

  const EmailAttachmentsPinHeaderWidget({
    super.key,
    required this.countAttachments,
    required this.totalSizeAttachments,
    required this.isCollapsed,
    required this.imagePaths,
    required this.isMobile,
    required this.onToggleExpandAction,
    this.onDownloadAllAttachmentsAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleExpand,
      child: Container(
        padding: const EdgeInsetsDirectional.all(8),
        decoration: isCollapsed
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColor.colorLineComposer,
                    width: 1,
                  ),
                ),
              ),
        child: Row(
          children: [
            TMailButtonWidget.fromIcon(
              icon: isCollapsed
                  ? imagePaths.icArrowRight
                  : imagePaths.icArrowBottom,
              iconSize: 20,
              iconColor: AppColor.steelGrayA540,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
              onTapActionCallback: _toggleExpand,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '$countAttachments ${AppLocalizations.of(context).attachments}',
                      style: ThemeUtils.textStyleInter500().copyWith(
                        fontSize: 13,
                        height: 16 / 13,
                        color: AppColor.steelGrayA540,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    child: Text(
                      filesize(totalSizeAttachments),
                      style: ThemeUtils.textStyleInter500().copyWith(
                        fontSize: 12,
                        height: 14 / 12,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            if (onDownloadAllAttachmentsAction != null)
              TMailButtonWidget(
                icon: imagePaths.icDownloadAll,
                text: isMobile
                    ? AppLocalizations.of(context).downloadAll
                    : AppLocalizations.of(context).archiveAndDownload,
                iconSize: 20,
                iconColor: AppColor.steelGrayA540,
                iconAlignment: TextDirection.rtl,
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                onTapActionCallback: onDownloadAllAttachmentsAction,
              ),
          ],
        ),
      ),
    );
  }

  void _toggleExpand() => onToggleExpandAction(!isCollapsed);
}
