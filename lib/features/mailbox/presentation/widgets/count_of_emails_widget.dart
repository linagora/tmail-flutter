
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class CountOfEmailsWidget extends StatelessWidget {

  final String value;

  const CountOfEmailsWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: PlatformInfo.isMobile
        ? ThemeUtils.textStyleInter400()
        : Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black,
          ),
    );
  }
}
