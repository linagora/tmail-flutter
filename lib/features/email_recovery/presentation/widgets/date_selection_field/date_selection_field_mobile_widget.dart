import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_time_type.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/date_selection_field/date_selection_field_styles.dart';

class DateSelectionFieldMobileWidget extends StatelessWidget {
  final EmailRecoveryField field;
  final EmailRecoveryTimeType recoveryTimeSelected;
  final ImagePaths imagePaths;
  final VoidCallback? onTap;
  final DateTime? startDate;
  final DateTime? endDate;

  const DateSelectionFieldMobileWidget({
    super.key,
    required this.field,
    required this.recoveryTimeSelected,
    required this.imagePaths,
    this.onTap,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DateSelectionFieldStyles.paddingMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.getTitle(context),
            style: field.getTitleTextStyle(),
          ),
          const SizedBox(height: DateSelectionFieldStyles.titleSpaceMobile),
          Container(
            width: double.infinity,
            height: DateSelectionFieldStyles.height,
            decoration: const ShapeDecoration(
              color: AppColor.loginTextFieldBackgroundColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: DateSelectionFieldStyles.borderWidthMobile,
                  color: AppColor.colorInputBorderCreateMailbox
                ),
                borderRadius: DateSelectionFieldStyles.borderRadius
              )
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                radius: DateSelectionFieldStyles.radius,
                onTap: onTap,
                child: Padding(
                  padding: DateSelectionFieldStyles.inputFieldMobilePadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recoveryTimeSelected.getTitle(
                          context,
                          startDate: startDate,
                          endDate: endDate
                        ),
                        style: field.getHintTextStyle(),
                      ),
                      SvgPicture.asset(
                        imagePaths.icCalendar,
                        width: DateSelectionFieldStyles.icCalendarSize,
                        height: DateSelectionFieldStyles.icCalendarSize,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}