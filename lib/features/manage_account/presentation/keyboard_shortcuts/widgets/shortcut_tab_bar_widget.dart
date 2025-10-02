import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShortcutTabBarWidget extends StatelessWidget {
  final int index;
  final String label;
  final String? icon;
  final double? height;
  final double? width;

  const ShortcutTabBarWidget({
    super.key,
    required this.index,
    required this.label,
    this.icon,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.25,
        color: AppColor.gray424244,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return TabBarItem(
      index: index,
      transform: ColorsTransform(
        highlightColor: AppColor.gray424244,
        normalColor: AppColor.gray424244,
        builder: (context, _) {
          if (icon != null) {
            return Container(
              height: height,
              width: width,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    icon!,
                    width: 20,
                    height: 20,
                    colorFilter: AppColor.gray686E76.asFilter(),
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 10),
                  labelWidget,
                ],
              ),
            );
          } else {
            return Container(
              height: height,
              width: width,
              alignment: Alignment.center,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: labelWidget,
            );
          }
        },
      ),
    );
  }
}
