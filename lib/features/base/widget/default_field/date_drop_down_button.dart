import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';

typedef OnReceiveTimeSelected = void Function(
  EmailReceiveTimeType receiveTimeType,
);

class DateDropDownButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final List<EmailReceiveTimeType> receiveTimeTypes;
  final EmailReceiveTimeType receiveTimeTypeSelected;
  final DateTime? startDate;
  final DateTime? endDate;
  final OnReceiveTimeSelected onReceiveTimeSelected;

  const DateDropDownButton({
    Key? key,
    required this.imagePaths,
    required this.receiveTimeTypes,
    required this.receiveTimeTypeSelected,
    required this.onReceiveTimeSelected,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<EmailReceiveTimeType>(
          isExpanded: true,
          items: receiveTimeTypes
              .map((item) => _buildItemMenu(context, item))
              .toList(),
          value: receiveTimeTypeSelected,
          customButton: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: AppColor.m3Neutral90,
                width: 1,
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Row(children: [
              Expanded(
                child: Text(
                  receiveTimeTypeSelected.getTitle(
                    context,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                  style: ThemeUtils.textStyleBodyBody3(
                    color: AppColor.m3SurfaceBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SvgPicture.asset(imagePaths.icDropDown)
            ]),
          ),
          onChanged: (value) {
            if (value != null) {
              onReceiveTimeSelected.call(value);
            }
          },
          dropdownStyleData: DropdownStyleData(
            maxHeight: 332,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: Colors.white,
              border: Border.all(color: AppColor.m3Tertiary60),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 24)
              ]
            ),
            padding: const EdgeInsets.all(12),
            elevation: 0,
            offset: const Offset(0.0, -3.0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<EmailReceiveTimeType> _buildItemMenu(
    BuildContext context,
    EmailReceiveTimeType receiveTime,
  ) {
    return DropdownMenuItem<EmailReceiveTimeType>(
      value: receiveTime,
      enabled: receiveTime != receiveTimeTypeSelected,
      child: PointerInterceptor(
        child: Row(
          children: [
            Expanded(
              child: Text(
                receiveTime.getTitle(context),
                style: ThemeUtils.textStyleInter400.copyWith(
                  fontSize: 15,
                  height: 20 / 15,
                  letterSpacing: -0.15,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (receiveTime == receiveTimeTypeSelected)
              SvgPicture.asset(
                imagePaths.icChecked,
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
          ],
        ),
      ),
    );
  }
}
