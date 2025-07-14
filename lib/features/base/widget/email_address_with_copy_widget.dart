
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/copy_subaddress_widget.dart';

class EmailAddressWithCopyWidget extends StatelessWidget {
  final String label;
  final String copyLabelIcon;
  final OnCopyButtonAction onCopyButtonAction;
  final TextStyle? textStyle;
  final Color? copyIconColor;

  const EmailAddressWithCopyWidget({
    super.key,
    required this.label,
    required this.copyLabelIcon,
    required this.onCopyButtonAction,
    this.textStyle,
    this.copyIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SelectableText(
            label,
            style: textStyle ?? ThemeUtils.textStyleM3BodyMedium,
            maxLines: 1,
          ),
        ),
        if (label.isNotEmpty)
          TMailButtonWidget.fromIcon(
            icon: copyLabelIcon,
            backgroundColor: Colors.transparent,
            iconSize: 20,
            iconColor: copyIconColor ??
                AppColor.textSecondary.withValues(alpha: 0.48),
            padding: const EdgeInsets.all(5),
            onTapActionCallback: onCopyButtonAction,
          ),
      ],
    );
  }
}
