import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';

class FolderItemWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final String folderName;
  final bool isSelected;
  final Color? iconColor;
  final String? iconSelected;
  final TextStyle? textStyle;
  final VoidCallback? onTapAction;

  const FolderItemWidget({
    super.key,
    required this.imagePaths,
    required this.folderName,
    this.isSelected = false,
    this.iconColor,
    this.iconSelected,
    this.textStyle,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    Widget itemWidget = Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: MailboxItemWidgetStyles.itemPadding,
      ),
      height: MailboxItemWidgetStyles.height,
      child: Row(
        children: [
          SvgPicture.asset(
            imagePaths.icFolderMailbox,
            width: MailboxIconWidgetStyles.iconSize,
            height: MailboxIconWidgetStyles.iconSize,
            colorFilter:
                iconColor?.asFilter() ?? AppColor.primaryLinShare.asFilter(),
            fit: BoxFit.fill,
          ),
          const SizedBox(width: MailboxItemWidgetStyles.labelIconSpace),
          Expanded(
            child: Text(
              folderName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle ??
                  (isSelected
                      ? ThemeUtils.textStyleInter700(
                          color: Colors.black,
                          fontSize: 14,
                        )
                      : ThemeUtils.textStyleBodyBody3(
                          color: Colors.black,
                        )),
            ),
          ),
          const SizedBox(width: MailboxItemWidgetStyles.labelIconSpace),
          if (isSelected)
            SvgPicture.asset(
              iconSelected ?? imagePaths.icCheck,
              width: MailboxIconWidgetStyles.iconSize,
              height: MailboxIconWidgetStyles.iconSize,
              fit: BoxFit.fill,
            ),
        ],
      ),
    );

    if (onTapAction != null) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(MailboxItemWidgetStyles.borderRadius),
          ),
          hoverColor: AppColor.blue100,
          onTap: onTapAction,
          child: itemWidget,
        ),
      );
    } else {
      return itemWidget;
    }
  }
}
