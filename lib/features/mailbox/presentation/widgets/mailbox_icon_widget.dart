import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';

class MailboxIconWidget extends StatelessWidget {
  final String icon;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const MailboxIconWidget({
    super.key,
    required this.icon,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.only(
        end: MailboxItemWidgetStyles.labelIconSpace,
      ),
      child: SvgPicture.asset(
        icon,
        width: MailboxIconWidgetStyles.iconSize,
        height: MailboxIconWidgetStyles.iconSize,
        colorFilter: color?.asFilter(),
        fit: BoxFit.fill,
      ),
    );
  }
}
