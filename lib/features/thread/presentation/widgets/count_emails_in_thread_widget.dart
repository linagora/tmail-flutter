import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class CountEmailsInThreadWidget extends StatelessWidget {
  final int count;

  const CountEmailsInThreadWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ThemeUtils.textStyleBodyBody2(color: AppColor.steelGray400),
    );
  }
}
