import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_time_type.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/date_selection_field/date_selection_dropdown_button_styles.dart';

typedef OnRecoveryTimeSelected = void Function(EmailRecoveryTimeType recoveryTime);

class DateSelectionDropDownButton extends StatelessWidget {

  final ImagePaths imagePaths;
  final List<EmailRecoveryTimeType> items;
  final DateTime? startDate;
  final DateTime? endDate;
  final EmailRecoveryTimeType? recoveryTimeSelected;
  final OnRecoveryTimeSelected? onRecoveryTimeSelected;

  const DateSelectionDropDownButton({
    super.key,
    required this.imagePaths,
    required this.items,
    this.startDate,
    this.endDate,
    this.recoveryTimeSelected,
    this.onRecoveryTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<EmailRecoveryTimeType>(
          isExpanded: true,
          items: items
            .map((item) => _buildItemMenu(context, item))
            .toList(),
          value: recoveryTimeSelected,
          customButton: Container(
            height: DateSelectionDropdownButtonStyles.height,
            decoration: BoxDecoration(
              borderRadius: DateSelectionDropdownButtonStyles.borderRadius,
              border: Border.all(
                color: AppColor.colorInputBorderCreateMailbox,
                width: DateSelectionDropdownButtonStyles.borderWidth,
              ),
              color: AppColor.colorInputBackgroundCreateMailbox
            ),
            padding: DateSelectionDropdownButtonStyles.padding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    recoveryTimeSelected?.getTitle(context, startDate: startDate, endDate: endDate) ?? '',
                    style: DateSelectionDropdownButtonStyles.selectedValueTexStyle,
                    maxLines: 1,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                  )
                ),
                SvgPicture.asset(imagePaths.icDropDown)
              ]
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              onRecoveryTimeSelected?.call(value);
            }
          },
          buttonStyleData: ButtonStyleData(
            height: DateSelectionDropdownButtonStyles.height,
            padding: DateSelectionDropdownButtonStyles.padding,
            decoration: BoxDecoration(
              borderRadius: DateSelectionDropdownButtonStyles.borderRadius,
              border: Border.all(
                color: AppColor.colorInputBorderCreateMailbox,
                width: DateSelectionDropdownButtonStyles.borderWidth,
              ),
              color: AppColor.colorInputBackgroundCreateMailbox
            )
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: DateSelectionDropdownButtonStyles.dropdownMaxHeight,
            decoration: DateSelectionDropdownButtonStyles.dropdownDecoration,
            elevation: DateSelectionDropdownButtonStyles.dropdownElevation,
            offset: DateSelectionDropdownButtonStyles.dropdownOffset,
            scrollbarTheme: ScrollbarThemeData(
              radius: DateSelectionDropdownButtonStyles.scrollbarRadius,
              thickness: WidgetStateProperty.all<double>(DateSelectionDropdownButtonStyles.scrollbarThickness),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: SvgPicture.asset(imagePaths.icDropDown),
          ),
          menuItemStyleData: DateSelectionDropdownButtonStyles.menuItemStyleData
        ),
      ),
    );
  }

  DropdownMenuItem<EmailRecoveryTimeType> _buildItemMenu(
    BuildContext context,
    EmailRecoveryTimeType recoveryTime
  ) {
    return DropdownMenuItem<EmailRecoveryTimeType>(
      value: recoveryTime,
      child: Semantics(
        excludeSemantics: true,
        child: PointerInterceptor(
          child: Container(
            color: Colors.transparent,
            height: DateSelectionDropdownButtonStyles.height,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    recoveryTime.getTitle(context),
                    style: DateSelectionDropdownButtonStyles.selectedValueTexStyle,
                    maxLines: 1,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                  )
                ),
                if (recoveryTime == recoveryTimeSelected)
                  SvgPicture.asset(
                    imagePaths.icChecked,
                    width: DateSelectionDropdownButtonStyles.checkedIconSize,
                    height: DateSelectionDropdownButtonStyles.checkedIconSize,
                    fit: BoxFit.fill
                  )
              ]
            ),
          ),
        ),
      ),
    );
  }
}