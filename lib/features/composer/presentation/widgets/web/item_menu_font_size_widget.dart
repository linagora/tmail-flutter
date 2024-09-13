
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/item_menu_font_size_widget_style.dart';

class ItemMenuFontSizeWidget extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();

  final int? value;
  final int selectedValue;

  ItemMenuFontSizeWidget({
    Key? key,
    required this.value,
    required this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: PointerInterceptor(
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$value',
                style: ItemMenuFontSizeWidgetStyle.labelTextStyle,
              ),
              if (value == selectedValue)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: ItemMenuFontSizeWidgetStyle.selectIconPadding,
                    child: SvgPicture.asset(_imagePaths.icSelectedSB),
                  )
                )
            ],
          ),
        ),
      ),
    );
  }
}