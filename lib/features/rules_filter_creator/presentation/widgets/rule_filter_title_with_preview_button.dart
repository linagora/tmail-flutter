
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterTitleWithPreviewButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final bool isPreviewEnabled;
  final VoidCallback onTogglePreviewAction;

  const RuleFilterTitleWithPreviewButton({
    super.key,
    required this.imagePaths,
    required this.isPreviewEnabled,
    required this.onTogglePreviewAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              appLocalizations.condition,
              style: ThemeUtils.textStyleInter600().copyWith(
                fontSize: 14,
                height: 18 / 14,
                color: Colors.black,
              ),
            ),
          ),
          TMailButtonWidget(
            text: isPreviewEnabled
              ? appLocalizations.hide
              : appLocalizations.preview,
            icon: isPreviewEnabled ? imagePaths.icEyeOff : imagePaths.icEye,
            iconSize: 12,
            iconColor: AppColor.primaryMain,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            textStyle: ThemeUtils.textStyleInter400.copyWith(
              fontSize: 11,
              height: 16 / 11,
              letterSpacing: 0.5,
              color: AppColor.primaryMain,
            ),
            onTapActionCallback: onTogglePreviewAction,
          )
        ],
      ),
    );
  }
}
