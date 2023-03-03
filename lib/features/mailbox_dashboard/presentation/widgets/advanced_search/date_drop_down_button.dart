import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';

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
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColor.colorInputBorderCreateMailbox,
                width: 1,
              ),
              color: AppColor.colorInputBackgroundCreateMailbox
            ),
            padding: const EdgeInsets.only(left: 12, right: 10),
            child: Row(children: [
              Expanded(child: Text(
                receiveTimeSelected?.getTitle(context, startDate: startDate, endDate: endDate) ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
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
          icon: SvgPicture.asset(imagePaths.icDropDown),
          buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
          buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColor.colorInputBorderCreateMailbox,
              width: 1,
            ),
            color: AppColor.colorInputBackgroundCreateMailbox,
          ),
          itemHeight: 44,
          buttonHeight: 44,
          selectedItemHighlightColor: Colors.white,
          itemPadding: const EdgeInsets.symmetric(horizontal: 12),
          dropdownMaxHeight: 200,
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          offset: const Offset(0.0, -8.0),
          dropdownElevation: 4,
          scrollbarRadius: const Radius.circular(40),
          scrollbarThickness: 6
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
              style: const TextStyle(
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