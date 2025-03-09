
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

  const ComposeButtonWidget({
    super.key,
    required this.imagePaths,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: 16,
        bottom: 8,
      ),
      width: ResponsiveUtils.defaultSizeMenu,
      alignment: Alignment.centerLeft,
      child: TMailButtonWidget(
        key: const Key('compose_email_button'),
        text: AppLocalizations.of(context).compose,
        icon: imagePaths.icComposeWeb,
        borderRadius: 10,
        iconSize: 24,
        iconColor: Colors.white,
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
        backgroundColor: AppColor.blue700,
        textStyle: ThemeUtils.textStyleBodyBody2(color: Colors.white),
        onTapActionCallback: onTapAction,
      ),
    );
  }
}
