import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardHeaderWidget extends StatelessWidget {
  const ForwardHeaderWidget({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
  }) : super(key: key);

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 11),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          AppLocalizations.of(context).forwarding,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black)),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).forwardingSettingExplanation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.colorSettingExplanation)),
      ]),
    );
  }
}