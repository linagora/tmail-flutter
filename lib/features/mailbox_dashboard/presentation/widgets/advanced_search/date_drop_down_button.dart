import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';

class DateDropDownButton extends StatelessWidget {

  final ImagePaths imagePaths;
  final DateTime? startDate;
  final DateTime? endDate;
  final EmailReceiveTimeType? receiveTimeSelected;
  final Function(EmailReceiveTimeType)? onReceiveTimeSelected;

  const DateDropDownButton(
    this.imagePaths, {
    Key? key,
    this.startDate,
    this.endDate,
    this.receiveTimeSelected,
    this.onReceiveTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<EmailReceiveTimeType>(
          isExpanded: true,
          items: EmailReceiveTimeType.values
            .map((item) => _buildItemMenu(context, item))
            .toList(),
          value: receiveTimeSelected,
          customButton: Container(
            height: AdvancedSearchInputFormStyle.inputFieldHeight,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius),
              ),
              border: Border.all(
                color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
                width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
              ),
              color: AdvancedSearchInputFormStyle.inputFieldBackgroundColor,
            ),
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Row(children: [
              Expanded(child: Text(
                receiveTimeSelected?.getTitle(context, startDate: startDate, endDate: endDate) ?? '',
                style: AdvancedSearchInputFormStyle.inputTextStyle,
                maxLines: 1,
                softWrap: CommonTextStyle.defaultSoftWrap,
                overflow: CommonTextStyle.defaultTextOverFlow,
              )),
              SvgPicture.asset(imagePaths.icDropDown)
            ]),
          ),
          onChanged: (value) {
            if (value != null) {
              onReceiveTimeSelected?.call(value);
            }
          },
          buttonStyleData: ButtonStyleData(
            height: AdvancedSearchInputFormStyle.inputFieldHeight,
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius),
              ),
              border: Border.all(
                color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
                width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
              ),
              color: AdvancedSearchInputFormStyle.inputFieldBackgroundColor,
            )
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
            elevation: 4,
            offset: const Offset(0.0, -8.0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: SvgPicture.asset(imagePaths.icDropDown),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 12),
          )
        ),
      ),
    );
  }

  DropdownMenuItem<EmailReceiveTimeType> _buildItemMenu(
    BuildContext context,
    EmailReceiveTimeType receiveTime
  ) {
    return DropdownMenuItem<EmailReceiveTimeType>(
      value: receiveTime,
      child: PointerInterceptor(
        child: Container(
          color: Colors.transparent,
          height: 44,
          child: Row(children: [
            Expanded(child: Text(
              receiveTime.getTitle(context),
              style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black
              ),
              maxLines: 1,
              softWrap: CommonTextStyle.defaultSoftWrap,
              overflow: CommonTextStyle.defaultTextOverFlow,
            )),
            if (receiveTime == receiveTimeSelected)
              SvgPicture.asset(
                imagePaths.icChecked,
                width: 20,
                height: 20,
                fit: BoxFit.fill
              )
          ]),
        ),
      ),
    );
  }
}