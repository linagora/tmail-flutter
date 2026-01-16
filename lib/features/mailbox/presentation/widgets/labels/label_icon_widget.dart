import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';

class LabelIconWidget extends StatelessWidget {
  final String icon;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const LabelIconWidget({
    super.key,
    required this.icon,
    this.iconSize = MailboxIconWidgetStyles.iconSize,
    this.padding = const EdgeInsetsDirectional.only(
      end: MailboxItemWidgetStyles.labelIconSpace,
    ),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SvgPicture.asset(
        icon,
        width: iconSize,
        height: iconSize,
        colorFilter: color?.asFilter(),
        fit: BoxFit.fill,
      ),
    );
  }
}
