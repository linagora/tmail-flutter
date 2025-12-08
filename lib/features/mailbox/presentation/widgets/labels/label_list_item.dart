import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_icon_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_name_widget.dart';

class LabelListItem extends StatelessWidget {
  final Label label;
  final ImagePaths imagePaths;
  final bool isDesktop;

  const LabelListItem({
    super.key,
    required this.label,
    required this.imagePaths,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.all(
      Radius.circular(
        isDesktop
            ? MailboxItemWidgetStyles.borderRadius
            : MailboxItemWidgetStyles.mobileBorderRadius,
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(borderRadius: borderRadius),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: isDesktop
                ? MailboxItemWidgetStyles.itemPadding
                : MailboxItemWidgetStyles.mobileItemPadding,
          ),
          height: isDesktop
              ? MailboxItemWidgetStyles.height
              : MailboxItemWidgetStyles.mobileHeight,
          child: Row(
            children: [
              LabelIconWidget(
                icon: imagePaths.icTag,
                color: label.backgroundColor,
                padding: EdgeInsetsDirectional.only(
                  end: isDesktop
                      ? MailboxItemWidgetStyles.labelIconSpace
                      : MailboxItemWidgetStyles.mobileLabelIconSpace,
                ),
              ),
              Expanded(
                child: LabelNameWidget(
                  name: label.safeDisplayName,
                  isDesktop: isDesktop,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
