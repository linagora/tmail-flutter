import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MoreAttachmentsButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final int remainingAttachments;
  final bool isMobile;
  final VoidCallback? onShowAllAttachmentsAction;
  final EdgeInsetsGeometry? margin;

  const MoreAttachmentsButton({
    super.key,
    required this.remainingAttachments,
    required this.imagePaths,
    required this.isMobile,
    required this.onShowAllAttachmentsAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget(
      text: AppLocalizations.of(context).moreAttachments(
        remainingAttachments,
      ),
      icon: imagePaths.icAttachment,
      iconSize: 24,
      iconColor: AppColor.steelGrayA540,
      iconSpace: 12,
      verticalDirection: true,
      mainAxisSize: MainAxisSize.min,
      alignment: Alignment.center,
      textStyle: ThemeUtils.textStyleInter500().copyWith(
        fontSize: 14,
        height: 1.0,
        color: AppColor.steelGrayA540,
      ),
      borderRadius: 10,
      border: Border.all(
        color: Colors.black.withValues(alpha: 0.12),
        width: 0.5,
      ),
      backgroundColor: AppColor.lightGrayF5F5F5,
      width: isMobile
          ? EmailUtils.mobileItemMaxWidth
          : EmailUtils.defaultItemMaxWidth,
      height: EmailUtils.defaultItemMaxHeight,
      margin: margin,
      onTapActionCallback: onShowAllAttachmentsAction,
    );
  }
}
