import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/copy_subaddress_widget.dart';

class ProfileLabelWidget extends StatelessWidget {
  final String label;
  final String copyLabelIcon;
  final OnCopyButtonAction onCopyButtonAction;

  const ProfileLabelWidget({
    super.key,
    required this.label,
    required this.copyLabelIcon,
    required this.onCopyButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SelectableText(
              label,
              style: ThemeUtils.textStyleM3BodyMedium,
              maxLines: 1,
            ),
          ),
          if (label.isNotEmpty)
            TMailButtonWidget.fromIcon(
              icon: copyLabelIcon,
              backgroundColor: Colors.transparent,
              iconSize: 20,
              iconColor: AppColor.textSecondary.withOpacity(0.48),
              padding: const EdgeInsets.all(5),
              onTapActionCallback: onCopyButtonAction,
            ),
        ],
      ),
    );
  }
}
