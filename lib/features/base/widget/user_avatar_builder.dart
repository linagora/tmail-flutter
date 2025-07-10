import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';

class UserAvatarBuilder extends StatelessWidget {
  final String username;
  final double? size;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final VoidCallback? onTapAction;

  const UserAvatarBuilder({
    Key? key,
    required this.username,
    this.size,
    this.textStyle,
    this.padding,
    this.textStyle,
    this.onTapAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarBuilder = AvatarBuilder()
      ..text(username)
      ..size(size ?? 32)
      ..addTextStyle(textStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ))
      ..avatarColor(username.gradientColors);

    if (onTapAction != null) {
      avatarBuilder.addOnTapActionClick(onTapAction!);
    }

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: avatarBuilder.build(),
      );
    } else {
      return avatarBuilder.build();
    }
  }
}
