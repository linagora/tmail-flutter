
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_description_detail_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_location_detail_widget.dart';

class EventDescriptionDetailWidget extends StatelessWidget {

  final String description;
  final OnOpenNewTabAction? onOpenNewTabAction;
  final OnOpenComposerAction? onOpenComposerAction;

  const EventDescriptionDetailWidget({
    super.key,
    required this.description,
    this.onOpenNewTabAction,
    this.onOpenComposerAction,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = Get.find<ImagePaths>();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColor.colorEventDescriptionBackground,
        borderRadius: BorderRadius.all(Radius.circular(EventDescriptionDetailWidgetStyles.borderRadius)),
      ),
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(EventDescriptionDetailWidgetStyles.contentPadding),
      child: Stack(
        children: [
          Linkify(
            onOpen: (element) {
              log('EventDescriptionDetailWidget::build:element: $element');
              if (element is UrlElement) {
                onOpenNewTabAction?.call(element.url);
              } else if (element is EmailElement) {
                onOpenComposerAction?.call(element.emailAddress);
              }
            },
            text: description,
            linkifiers: const [
              EmailLinkifier(),
              UrlLinkifier()
            ],
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: EventDescriptionDetailWidgetStyles.textSize,
              color: EventDescriptionDetailWidgetStyles.valueColor
            ),
            options: const LinkifyOptions(
              removeWww: true,
              looseUrl: true,
              defaultToHttps: true
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: SvgPicture.asset(imagePath.icFormatQuote)
          )
        ],
      ),
    );
  }
}