import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDownloadAttachmentFileAction = void Function(Attachment attachment);
typedef OnViewAttachmentFileAction = void Function(Attachment attachment);

class AttachmentItemWidget extends StatefulWidget {

  final Attachment attachment;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final EdgeInsetsGeometry? margin;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;
  final String? singleEmailControllerTag;

  const AttachmentItemWidget({
    Key? key,
    required this.attachment,
    required this.imagePaths,
    required this.responsiveUtils,
    this.margin,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
    this.singleEmailControllerTag,
  }) : super(key: key);

  @override
  State<AttachmentItemWidget> createState() => _AttachmentItemWidgetState();
}

class _AttachmentItemWidgetState extends State<AttachmentItemWidget> {

  final ValueNotifier<bool> _isHovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.responsiveUtils.isMobile(context);

    return Obx(() {
      final controller = Get.find<SingleEmailController>(tag: widget.singleEmailControllerTag);
      final attachmentsViewState = controller.attachmentsViewState;
      bool isLoading = false;
      if (widget.attachment.blobId != null) {
        isLoading = !EmailUtils.checkingIfAttachmentActionIsEnabled(
            attachmentsViewState[widget.attachment.blobId!]);
      }

      const loadingIndicator = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );

      final attachmentIcon = SvgPicture.asset(
        widget.attachment.getIcon(widget.imagePaths),
        width: 34.3,
        height: 34.3,
        fit: BoxFit.fill,
      );

      final attachmentTitleWithMiddleDots = ExtendedText(
        widget.attachment.generateFileName(),
        maxLines: 1,
        overflowWidget: TextOverflowWidget(
          position: TextOverflowPosition.middle,
          clearType: TextOverflowClearType.clipRect,
          child: Text(
            "...",
            style: ThemeUtils.textStyleInter500().copyWith(
              color: Colors.black,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
        ),
        style: ThemeUtils.textStyleInter500().copyWith(
          color: Colors.black,
          fontSize: 14,
          height: 1.0,
          letterSpacing: 0.0,
        ),
      );

      final attachmentTitleWithEndDots = Text(
        widget.attachment.generateFileName(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ThemeUtils.textStyleInter500().copyWith(
          color: Colors.black,
          fontSize: 14,
          height: 1.0,
          letterSpacing: 0.0,
        ),
      );

      Widget infoWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformInfo.isCanvasKit
              ? attachmentTitleWithMiddleDots
              : attachmentTitleWithEndDots,
          const SizedBox(height: 8),
          Text(
            filesize(widget.attachment.size?.value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ThemeUtils.textStyleInter400.copyWith(
              color: AppColor.gray6D7885,
              fontSize: 12,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          )
        ],
      );

      if (isMobile || PlatformInfo.isMobile) {
        infoWidget = Row(
          children: [
            Expanded(child: infoWidget),
            TMailButtonWidget.fromIcon(
              icon: widget.imagePaths.icDownloadAttachment,
              iconSize: 24,
              iconColor: AppColor.primaryLinShare,
              backgroundColor: Colors.transparent,
              borderRadius: 100,
              padding: const EdgeInsets.all(12),
              onTapActionCallback:
                  isLoading ? null : () => _onTapDownloadAction(widget.attachment),
            ),
          ],
        );
      }

      Widget bodyItemWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: isMobile ? 137 : 94,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
            ),
            child: TMailContainerWidget(
              width: 49,
              height: 49,
              borderRadius: 4,
              backgroundColor: AppColor.grayF3F6F9,
              child: isLoading ? loadingIndicator : attachmentIcon,
            ),
          ),
          Expanded(
            child: Container(
              alignment: AlignmentDirectional.centerStart,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 11),
              child: infoWidget,
            ),
          ),
        ],
      );

      bodyItemWidget = TMailContainerWidget(
        height: _getHeightItem(isMobile),
        width: _getWidthItem(context, isMobile),
        borderRadius: 10,
        border: Border.all(
          width: 0.5,
          color: Colors.black.withValues(alpha: 0.12),
        ),
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: widget.margin,
        onTapActionCallback:
            isLoading ? null : () => _onViewOrDownloadAction(widget.attachment),
        child: bodyItemWidget,
      );

      if (isMobile || PlatformInfo.isMobile) {
        return bodyItemWidget;
      } else {
        return MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: Stack(
            children: [
              bodyItemWidget,
              PositionedDirectional(
                top: 16,
                end: 16,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isHovered,
                  builder: (_, hovered, __) {
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: hovered ? 1.0 : 0.0,
                          child: TMailButtonWidget.fromIcon(
                            icon: widget.imagePaths.icDownloadAttachment,
                            iconSize: 24,
                            iconColor: Colors.white,
                            backgroundColor: AppColor.steelGrayA540,
                            borderRadius: 100,
                            padding: const EdgeInsets.all(6),
                            onTapActionCallback: () =>
                                _onTapDownloadAction(widget.attachment),
                          ),
                        ),
                        if (hovered)
                          Positioned(
                            top: 42,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: hovered ? 1.0 : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.black4D4D4D,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.16),
                                      blurRadius: 24,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                child: Text(
                                  AppLocalizations.of(context).download,
                                  style: ThemeUtils.textStyleInter600().copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 20 / 12,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  void _onTapDownloadAction(Attachment attachment) {
    widget.downloadAttachmentAction?.call(attachment);
  }

  void _onViewOrDownloadAction(Attachment attachment) {
    (widget.viewAttachmentAction ?? widget.downloadAttachmentAction)?.call(attachment);
  }

  double _getHeightItem(bool isMobile) => isMobile
      ? EmailUtils.mobileItemMaxHeight
      : EmailUtils.defaultItemMaxHeight;

  double _getWidthItem(BuildContext context, bool isMobile) => isMobile
      ? min(
          EmailUtils.mobileItemMaxWidth,
          widget.responsiveUtils.getDeviceWidth(context),
        )
      : EmailUtils.defaultItemMaxWidth;

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }
}