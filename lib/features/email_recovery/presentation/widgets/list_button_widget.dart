import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/list_button_widget_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/text_action_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListButtonWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onRestore;
  final ResponsiveUtils responsiveUtils;

  const ListButtonWidget({
    super.key,
    required this.onCancel,
    required this.onRestore,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextActionButtonWidget(
            colorButton: AppColor.colorBgSearchBar,
            colorText: AppColor.primaryColor,
            text: AppLocalizations.of(context).cancel,
            onAction: onCancel
          ),
        ),
        SizedBox(width: responsiveUtils.isMobile(context) 
          ? ListButtonWidgetStyles.mobileSpace
          : ListButtonWidgetStyles.space
        ),
        Expanded(
          child: TextActionButtonWidget(
            colorButton: AppColor.primaryColor,
            colorText: Colors.white,
            text: AppLocalizations.of(context).restore,
            onAction: onRestore
          )
        )
      ],
    );
  }
}