
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_time_information_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventTimeInformationWidget extends StatelessWidget {

  final String timeEvent;

  const EventTimeInformationWidget({
    super.key,
    required this.timeEvent
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventTimeInformationWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).when,
            style: const TextStyle(
              fontSize: EventTimeInformationWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventTimeInformationWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Text(
          timeEvent,
          overflow: responsiveUtils.isPortraitMobile(context) ? null : CommonTextStyle.defaultTextOverFlow,
          softWrap: responsiveUtils.isPortraitMobile(context) ? null : CommonTextStyle.defaultSoftWrap,
          maxLines: responsiveUtils.isPortraitMobile(context) ? null : 1,
          style: const TextStyle(
            fontSize: EventTimeInformationWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventTimeInformationWidgetStyles.valueColor
          ),
        ))
      ],
    );
  }
}