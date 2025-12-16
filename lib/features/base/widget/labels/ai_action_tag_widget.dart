import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/labels/tag_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AiActionTagWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const AiActionTagWidget({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return TagWidget(
      text: AppLocalizations.of(context).actionRequired,
      backgroundColor: AppColor.aiActionTag,
      textColor: Colors.white,
      isTruncateText: true,
      showTooltip: PlatformInfo.isWeb,
      margin: margin,
    );
  }
}
