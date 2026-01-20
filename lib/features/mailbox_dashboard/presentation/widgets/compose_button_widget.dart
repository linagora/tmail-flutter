
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ComposeButtonWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final VoidCallback onTapAction;
  final bool isCollapsed;

  const ComposeButtonWidget({
    super.key,
    required this.imagePaths,
    required this.onTapAction,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: isCollapsed ? 8 : 16,
        end: isCollapsed ? 8 : 16,
        top: 16,
        bottom: 8,
      ),
      width: isCollapsed
          ? ResponsiveUtils.defaultSizeMenuCollapsed
          : ResponsiveUtils.defaultSizeMenu,
      alignment: Alignment.center,
      child: isCollapsed
          ? TMailButtonWidget.fromIcon(
              key: const Key('compose_email_button_collapsed'),
              icon: imagePaths.icComposeWeb,
              borderRadius: 10,
              iconSize: 24,
              height: 44,
              width: 44,
              iconColor: Colors.white,
              backgroundColor: AppColor.blue700,
              tooltipMessage: AppLocalizations.of(context).compose,
              onTapActionCallback: onTapAction,
            )
          : TMailButtonWidget(
              key: const Key('compose_email_button'),
              text: AppLocalizations.of(context).compose,
              icon: imagePaths.icComposeWeb,
              borderRadius: 10,
              iconSize: 24,
              height: 44,
              iconColor: Colors.white,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              backgroundColor: AppColor.blue700,
              textStyle: ThemeUtils.textStyleBodyBody2(color: Colors.white),
              onTapActionCallback: onTapAction,
            ),
    );
  }
}
