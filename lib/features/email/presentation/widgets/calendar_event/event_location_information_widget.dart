
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_location_information_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventLocationInformationWidget extends StatelessWidget {

  final String locationEvent;

  const EventLocationInformationWidget({
    super.key,
    required this.locationEvent
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventLocationInformationWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).where,
            style: const TextStyle(
              fontSize: EventLocationInformationWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventLocationInformationWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Text(
          locationEvent,
          overflow: responsiveUtils.isPortraitMobile(context) ? null : CommonTextStyle.defaultTextOverFlow,
          softWrap: responsiveUtils.isPortraitMobile(context) ? null : CommonTextStyle.defaultSoftWrap,
          maxLines: responsiveUtils.isPortraitMobile(context) ? null : 1,
          style: const TextStyle(
            fontSize: EventLocationInformationWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventLocationInformationWidgetStyles.valueColor
          ),
        ))
      ],
    );
  }
}