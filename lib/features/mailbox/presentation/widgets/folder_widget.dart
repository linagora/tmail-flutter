import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';

class FolderWidget extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onOpenFolderAction;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? iconPadding;
  final double? borderRadius;
  final double? height;
  final TextStyle? labelTextStyle;

  const FolderWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onOpenFolderAction,
    this.tooltip,
    this.padding,
    this.itemPadding,
    this.iconPadding,
    this.borderRadius,
    this.height,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius ?? MailboxItemWidgetStyles.borderRadius),
        ),
      ),
      padding: itemPadding ?? const EdgeInsets.symmetric(
        horizontal: MailboxItemWidgetStyles.itemPadding,
      ),
      height: height ?? MailboxItemWidgetStyles.height,
      child: Row(children: [
        MailboxIconWidget(
          icon: icon,
          padding: iconPadding,
          color: AppColor.iconFolder,
        ),
        Expanded(
          child: TextOverflowBuilder(
            label,
            style: labelTextStyle ?? ThemeUtils.textStyleBodyBody3(color: Colors.black),
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
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius ?? MailboxItemWidgetStyles.borderRadius),
        ),
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
