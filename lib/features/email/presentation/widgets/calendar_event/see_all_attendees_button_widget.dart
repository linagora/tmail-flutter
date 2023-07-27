
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/see_all_attendees_button_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SeeAllAttendeesButtonWidget extends StatelessWidget {

  final VoidCallback onTap;

  const SeeAllAttendeesButtonWidget({
    super.key,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translationValues(SeeAllAttendeesButtonWidgetStyles.horizontalMargin, 0.0, 0.0),
      child: MaterialTextButton(
        label: AppLocalizations.of(context).seeAllAttendees,
        onTap: onTap,
        borderRadius: SeeAllAttendeesButtonWidgetStyles.borderRadius,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SeeAllAttendeesButtonWidgetStyles.horizontalPadding,
          vertical: SeeAllAttendeesButtonWidgetStyles.verticalPadding
        ),
        customStyle: const TextStyle(
          fontSize: SeeAllAttendeesButtonWidgetStyles.textSize,
          color: AppColor.colorTextButton
        ),
      ),
    );
  }
}
