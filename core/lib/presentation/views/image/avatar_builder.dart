import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

typedef OnTapActionClick = void Function();
typedef OnTapWithPositionAction = void Function(RelativeRect position);

class AvatarBuilder extends StatelessWidget {
  final String? text;
  final double? size;
  final Color? bgColor;
  final Color? textColor;
  final OnTapActionClick? onTapAction;
  final OnTapWithPositionAction? onTapWithPositionAction;
  final List<Color>? avatarColors;
  final List<BoxShadow>? boxShadows;
  final TextStyle? textStyle;

  const AvatarBuilder({
    super.key,
    this.text,
    this.size,
    this.bgColor,
    this.textColor,
    this.onTapAction,
    this.onTapWithPositionAction,
    this.avatarColors,
    this.boxShadows,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTapAction,
        onTapDown: (detail) {
          if (onTapWithPositionAction != null) {
            final screenSize = MediaQuery.of(context).size;
            final offset = detail.globalPosition;
            final position = RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              screenSize.width - offset.dx,
              screenSize.height - offset.dy,
            );
            onTapWithPositionAction!(position);
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: size ?? 40,
          height: size ?? 40,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            shadows: boxShadows ?? [],
            gradient: avatarColors?.isNotEmpty == true
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.decal,
                  colors: avatarColors ?? [])
              : null,
            color: bgColor ?? AppColor.avatarColor
          ),
          child: Text(
            text ?? '',
            style: textStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 20,
              color: textColor ?? AppColor.avatarTextColor
            )
          )
        ),
      ),
    );
  }
}
