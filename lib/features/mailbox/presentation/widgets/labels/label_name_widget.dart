import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class LabelNameWidget extends StatelessWidget {
  final String name;
  final bool isDesktop;

  const LabelNameWidget({
    super.key,
    required this.name,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: isDesktop
          ? ThemeUtils.textStyleBodyBody3(color: Colors.black)
          : ThemeUtils.textStyleInter500(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
