import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';

class FolderWidget extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onOpenFolderAction;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const FolderWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onOpenFolderAction,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(MailboxItemWidgetStyles.borderRadius),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: MailboxItemWidgetStyles.itemPadding,
      ),
      height: MailboxItemWidgetStyles.height,
      child: Row(children: [
        SvgPicture.asset(
          icon,
          width: MailboxIconWidgetStyles.iconSize,
          height: MailboxIconWidgetStyles.iconSize,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: MailboxItemWidgetStyles.labelIconSpace),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: TextOverflowBuilder(
              label,
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
        )
      ]),
    );

    if (tooltip != null) {
      item = Tooltip(
        message: tooltip,
        child: item,
      );
    }

    item = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenFolderAction,
        borderRadius: const BorderRadius.all(
          Radius.circular(MailboxItemWidgetStyles.borderRadius),
        ),
        hoverColor: AppColor.blue100,
        child: item,
      ),
    );

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: item,
      );
    } else {
      return item;
    }
  }
}
