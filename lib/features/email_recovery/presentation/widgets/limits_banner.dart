import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class LimitsBanner extends StatelessWidget {
  final String bannerContent;
  final EdgeInsetsGeometry? padding;
  final bool isCenter;

  const LimitsBanner({
    super.key,
    required this.bannerContent,
    this.isCenter = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Text(
      bannerContent,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      style: ThemeUtils.textStyleM3BodyMedium1,
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}