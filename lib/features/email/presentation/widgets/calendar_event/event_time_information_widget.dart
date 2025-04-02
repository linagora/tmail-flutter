
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_time_information_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventTimeInformationWidget extends StatelessWidget {

  final String timeEvent;
  final bool isFree;

  const EventTimeInformationWidget({
    super.key,
    required this.timeEvent,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final imagePaths = Get.find<ImagePaths>();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Flexible(child: Text(
          timeEvent,
          overflow: responsiveUtils.isPortraitMobile(context) ? null : CommonTextStyle.defaultTextOverFlow,
          softWrap: responsiveUtils.isPortraitMobile(context) ? null : CommonTextStyle.defaultSoftWrap,
          maxLines: responsiveUtils.isPortraitMobile(context) ? null : 1,
          style: const TextStyle(
            fontSize: EventTimeInformationWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventTimeInformationWidgetStyles.valueColor
          ),
        )),
        if (!isFree)
          ...[
            const SizedBox(width: EventTimeInformationWidgetStyles.horizontalSpacing),
            Tooltip(
              message: AppLocalizations.of(context).youHaveAnotherEventAtThatSameTime,
              child: SvgPicture.asset(
                imagePaths.icError,
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter: EventTimeInformationWidgetStyles.conflictColor.asFilter(),
              ),
            ),
          ]
      ],
    );
  }
}