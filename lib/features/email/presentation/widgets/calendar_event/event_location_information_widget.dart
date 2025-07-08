
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_location_information_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_information_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventLocationInformationWidget extends StatelessWidget {

  final String locationEvent;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;

  const EventLocationInformationWidget({
    super.key,
    required this.locationEvent,
    this.onOpenNewTabAction,
    this.onOpenComposerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventLocationInformationWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).where,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: EventLocationInformationWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventLocationInformationWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Linkify(
          onOpen: (element) {
            log('EventLocationInformationWidget::build:element: $element');
            if (element is UrlElement) {
              onOpenNewTabAction?.call(element.url);
            } else if (element is EmailElement) {
              onOpenComposerAction?.call(element.emailAddress);
            }
          },
          text: locationEvent,
          linkifiers: const [
            EmailLinkifier(),
            UrlLinkifier()
          ],
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: EventLocationInformationWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventLocationInformationWidgetStyles.valueColor
          ),
          options: const LinkifyOptions(
            removeWww: true,
            looseUrl: true,
            defaultToHttps: true
          ),
        ))
      ],
    );
  }
}