
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_description_detail_widget_styles.dart';

class EventDescriptionDetailWidget extends StatelessWidget {

  final String description;

  const EventDescriptionDetailWidget({
    super.key,
    required this.description
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
          Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: EventDescriptionDetailWidgetStyles.textSize,
              color: Colors.black
            )
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