import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';

class DestinationPickerFolderItem extends StatelessWidget {
  final bool isSelected;
  final bool isDesktop;
  final String text;
  final String folderIcon;
  final String selectedIcon;
  final EdgeInsetsGeometry? margin;
  final VoidCallback onTap;

  const DestinationPickerFolderItem({
    super.key,
    required this.isSelected,
    required this.isDesktop,
    required this.text,
    required this.folderIcon,
    required this.selectedIcon,
    required this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget itemWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              PlatformInfo.isWeb
                  ? MailboxItemWidgetStyles.borderRadius
                  : MailboxItemWidgetStyles.mobileBorderRadius,
            ),
          ),
        ),
        hoverColor: AppColor.colorMailboxHovered,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: MailboxItemWidgetStyles.itemPadding,
          ),
          height: PlatformInfo.isWeb
              ? MailboxItemWidgetStyles.height
              : MailboxItemWidgetStyles.mobileHeight,
          child: Row(
            spacing: MailboxItemWidgetStyles.labelIconSpace,
            children: [
              SvgPicture.asset(
                folderIcon,
                width: MailboxIconWidgetStyles.iconSize,
                height: MailboxIconWidgetStyles.iconSize,
                colorFilter: AppColor.primaryLinShare.asFilter(),
                fit: BoxFit.fill,
              ),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _displayNameTextStyle,
                ),
              ),
              if (isSelected)
                SvgPicture.asset(
                  selectedIcon,
                  width: MailboxIconWidgetStyles.iconSize,
                  height: MailboxIconWidgetStyles.iconSize,
                  fit: BoxFit.fill,
                ),
            ],
          ),
        ),
      ),
    );

    if (margin != null) {
      itemWidget = Padding(padding: margin!, child: itemWidget);
    }

    return itemWidget;
  }

  TextStyle get _displayNameTextStyle {
    if (isSelected) {
      return ThemeUtils.textStyleInter700(fontSize: 14);
    } else {
      return isDesktop
          ? ThemeUtils.textStyleBodyBody3(color: Colors.black)
          : ThemeUtils.textStyleInter500();
    }
  }
}
