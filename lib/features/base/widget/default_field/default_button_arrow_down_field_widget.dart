import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultButtonArrowDownFieldWidget extends StatelessWidget {
  final String text;
  final String iconArrowDown;
  final VoidCallback onTap;
  final Widget? icon;

  const DefaultButtonArrowDownFieldWidget({
    super.key,
    required this.text,
    required this.iconArrowDown,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        focusColor: AppColor.colorMailboxHovered,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: AppColor.m3Neutral90,
              width: 1,
            ),
          ),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          child: Row(
            children: [
              if (icon != null) icon!,
              Expanded(
                child: Text(
                  text,
                  style: ThemeUtils.textStyleBodyBody3(
                    color: AppColor.m3SurfaceBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SvgPicture.asset(iconArrowDown),
            ],
          ),
        ),
      ),
    );
  }
}
