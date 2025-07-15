
import 'package:core/presentation/utils/theme_utils.dart';
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
        customStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: SeeAllAttendeesButtonWidgetStyles.textSize,
          color: SeeAllAttendeesButtonWidgetStyles.textColor
        ),
      ),
    );
  }
}
