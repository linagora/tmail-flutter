import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RulePreviewBanner extends StatelessWidget {
  final ImagePaths imagePaths;
  final String message;
  final bool isAction;
  final EdgeInsetsGeometry? margin;

  const RulePreviewBanner({
    super.key,
    required this.imagePaths,
    required this.message,
    required this.isAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: isAction ? AppColor.lightGreenF0FDF4 : AppColor.lightBlueEFF6FF,
        border: Border.all(
          color:
              isAction ? AppColor.lightGreenBBF7D0 : AppColor.lightBlueBFDBFE,
        ),
      ),
      padding: const EdgeInsets.all(4),
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            isAction ? imagePaths.icCheck : imagePaths.icInfoCircleOutline,
            width: 20,
            height: 20,
            colorFilter: isAction
                ? AppColor.green166534.asFilter()
                : AppColor.m3SysLight.asFilter(),
            fit: BoxFit.fill,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: ThemeUtils.textStyleInter400.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: isAction ? AppColor.green166534 : AppColor.m3SysLight,
                ),
                children: [
                  TextSpan(
                    text: '${appLocalizations.preview}:',
                    style: ThemeUtils.textStyleInter700().copyWith(
                      fontSize: 14,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color:
                          isAction ? AppColor.green166534 : AppColor.m3SysLight,
                    ),
                  ),
                  TextSpan(text: ' $message'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
