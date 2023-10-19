import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';

class AttachmentListActionButtonBuilder extends StatelessWidget {
  final String? name;
  final TextStyle? textStyle;
  final Color? bgColor;
  final Color? borderColor;
  final Function? action;

  const AttachmentListActionButtonBuilder({
    super.key,
    this.name,
    this.textStyle,
    this.bgColor,
    this.borderColor,
    this.action
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => action?.call(),
      child: Container(
        padding: AttachmentListStyles.buttonsPadding,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AttachmentListStyles.buttonRadius,
            border: Border.all(
                width: borderColor != null ? AttachmentListStyles.buttonBorderWidth : 0,
                color: borderColor ?? Colors.transparent
            )
        ),
        child: Center(
          child: Text(
              name ?? '',
              textAlign: TextAlign.center,
              style: textStyle
          ),
        ),
      ),
    );
  }
}
