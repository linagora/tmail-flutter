
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/dropdown_button_font_size_widget_style.dart';

class DropdownButtonFontSizeWidget extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();

  final int value;

  DropdownButtonFontSizeWidget({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: RichTextStyleType.fontSize.getTooltipButton(context),
      child: Container(
        padding: DropdownButtonFontSizeWidgetStyle.padding,
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: DropdownButtonFontSizeWidgetStyle.borderWidth,
              color: DropdownButtonFontSizeWidgetStyle.borderColor
            ),
            borderRadius: BorderRadius.all(Radius.circular(DropdownButtonFontSizeWidgetStyle.radius)),
          ),
        ),
        height: DropdownButtonFontSizeWidgetStyle.height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: DropdownButtonFontSizeWidgetStyle.labelPadding,
              decoration: const ShapeDecoration(
                color: DropdownButtonFontSizeWidgetStyle.labelBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(DropdownButtonFontSizeWidgetStyle.labelRadius))
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: DropdownButtonFontSizeWidgetStyle.labelTextStyle,
              ),
            ),
            const SizedBox(width: DropdownButtonFontSizeWidgetStyle.space),
            SvgPicture.asset(_imagePaths.icStyleArrowDown)
          ],
        ),
      ),
    );
  }
}