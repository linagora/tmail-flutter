import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
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
    final folderIconWidget = SvgPicture.asset(
      folderIcon,
      width: MailboxIconWidgetStyles.iconSize,
      height: MailboxIconWidgetStyles.iconSize,
      colorFilter: AppColor.primaryLinShare.asFilter(),
      fit: BoxFit.fill,
    );

    final displayNameWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _displayNameTextStyle,
    );

    final selectedIconWidget = SvgPicture.asset(
      selectedIcon,
      width: MailboxIconWidgetStyles.iconSize,
      height: MailboxIconWidgetStyles.iconSize,
      fit: BoxFit.fill,
    );

    final itemHeight = isDesktop
        ? MailboxItemWidgetStyles.height
        : MailboxItemWidgetStyles.mobileHeight;

    final borderRadius = BorderRadius.all(Radius.circular(
      isDesktop
          ? MailboxItemWidgetStyles.borderRadius
          : MailboxItemWidgetStyles.mobileBorderRadius,
    ));

    Widget itemWidget = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
        hoverColor: AppColor.colorMailboxHovered,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: MailboxItemWidgetStyles.itemPadding,
          ),
          height: itemHeight,
          child: Row(
            children: [
              folderIconWidget,
              const SizedBox(width: MailboxItemWidgetStyles.labelIconSpace),
              Expanded(child: displayNameWidget),
              if (isSelected) ...[
                const SizedBox(width: MailboxItemWidgetStyles.labelIconSpace),
                selectedIconWidget,
              ],
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
