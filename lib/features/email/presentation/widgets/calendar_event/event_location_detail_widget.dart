
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_location_detail_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenNewTabAction = void Function(String link);
typedef OnOpenComposerAction = void Function(String emailAddress);

class EventLocationDetailWidget extends StatelessWidget {

  final String locationEvent;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;

  const EventLocationDetailWidget({
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
          width: EventLocationDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).location,
            style: const TextStyle(
              fontSize: EventLocationDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventLocationDetailWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Linkify(
          onOpen: (element) {
            log('EventLocationDetailWidget::build:element: $element');
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
          style: const TextStyle(
            fontSize: EventLocationDetailWidgetStyles.textSize,
            fontWeight: FontWeight.w500,
            color: EventLocationDetailWidgetStyles.valueColor
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