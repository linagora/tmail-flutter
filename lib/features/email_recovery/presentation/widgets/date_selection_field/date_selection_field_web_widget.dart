import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_time_type.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/date_selection_field/date_selection_field_styles.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/date_selection_field/date_selection_dropdown_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DateSelectionFieldWebWidget extends StatelessWidget {
  final EmailRecoveryField field;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final DateTime? startDate;
  final DateTime? endDate;
  final EmailRecoveryTimeType? recoveryTimeSelected;
  final OnRecoveryTimeSelected? onRecoveryTimeSelected;
  final VoidCallback? onTapCalendar;
  final DateTime restorationHorizon;

  const DateSelectionFieldWebWidget({
    super.key,
    required this.field,
    required this.responsiveUtils,
    required this.imagePaths,
    this.startDate,
    this.endDate,
    this.recoveryTimeSelected,
    this.onRecoveryTimeSelected,
    this.onTapCalendar,
    required this.restorationHorizon
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DateSelectionFieldStyles.padding,
      child: SizedBox(
        height: DateSelectionFieldStyles.height,
        child: Row(
          children: [
            SizedBox(
              width: DateSelectionFieldStyles.titleWidth,
              child: Text(
                field.getTitle(context),
                style: field.getTitleTextStyle(),
              ),
            ),
            const SizedBox(width: DateSelectionFieldStyles.titleSpace),
            Expanded(
              child: DateSelectionDropDownButton(
                imagePaths: imagePaths,
                startDate: startDate,
                endDate: endDate,
                recoveryTimeSelected: recoveryTimeSelected,
                onRecoveryTimeSelected: onRecoveryTimeSelected,
                items: field.getSupportedTimeTypes(restorationHorizon),
              ),
            ),
            const SizedBox(width: DateSelectionFieldStyles.icCalenderSpace),
            buildIconWeb(
              icon: SvgPicture.asset(
                imagePaths.icCalendarSB,
                width: DateSelectionFieldStyles.icCalendarSize,
                height: DateSelectionFieldStyles.icCalendarSize,
                fit: BoxFit.fill,
              ),
              tooltip: AppLocalizations.of(context).selectDate,
              iconPadding: EdgeInsets.zero,
              onTap: onTapCalendar
            )
          ],
        ),
      ),
    );
  }
}