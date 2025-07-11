import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_date_drop_down_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenDatPicker = void Function();

class DefaultDateDropDownFieldWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final List<EmailReceiveTimeType> receiveTimeTypes;
  final EmailReceiveTimeType receiveTimeTypeSelected;
  final OnReceiveTimeSelected onReceiveTimeSelected;
  final OnOpenDatPicker onOpenDatPicker;
  final DateTime? startDate;
  final DateTime? endDate;
  final EdgeInsetsGeometry? padding;

  const DefaultDateDropDownFieldWidget({
    super.key,
    required this.imagePaths,
    required this.receiveTimeTypes,
    required this.receiveTimeTypeSelected,
    required this.onReceiveTimeSelected,
    required this.onOpenDatPicker,
    this.startDate,
    this.endDate,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Row(
      children: [
        Expanded(
          child: DateDropDownButton(
            imagePaths: imagePaths,
            receiveTimeTypes: receiveTimeTypes,
            startDate: startDate,
            endDate: endDate,
            receiveTimeTypeSelected: receiveTimeTypeSelected,
            onReceiveTimeSelected: onReceiveTimeSelected,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: AppColor.m3Neutral90,
              width: 1,
            ),
          ),
          height: 40,
          width: 40,
          child: TMailButtonWidget.fromIcon(
            icon: imagePaths.icCalendarSB,
            iconSize: 22,
            iconColor: AppColor.steelGray400,
            backgroundColor: Colors.transparent,
            tooltipMessage: AppLocalizations.of(context).selectDate,
            onTapActionCallback: onOpenDatPicker,
          ),
        ),
      ],
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}
