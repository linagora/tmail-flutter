import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardHeaderWidget extends StatelessWidget {
  const ForwardHeaderWidget({
    Key? key,
    required this.addEmailForward,
    required this.imagePaths,
    required this.responsiveUtils,
  }) : super(key: key);

  final VoidCallback addEmailForward;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).forwarding,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 4),
        const SizedBox(height: 24),
        _buildButtonAddNewEmailsForward(context),
      ]),
    );
  }

  Widget _buildButtonAddNewEmailsForward(BuildContext context) {
    if (!responsiveUtils.isMobile(context)) {
      return (ButtonBuilder(imagePaths.icAddEmailForward)
            ..key(const Key('button_add_emails_forward'))
            ..decoration(BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..maxWidth(130)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 12))
            ..textStyle(const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ))
            ..onPressActionClick(() => addEmailForward.call())
            ..text(
              AppLocalizations.of(context).addEmailForward,
              isVertical: false,
            ))
          .build();
    } else {
      return (ButtonBuilder(imagePaths.icAddEmailForward)
            ..key(const Key('button_add_emails_forward'))
            ..decoration(BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 12))
            ..textStyle(const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ))
            ..onPressActionClick(() => addEmailForward.call())
            ..text(
              AppLocalizations.of(context).addEmailForward,
              isVertical: false,
            ))
          .build();
    }
  }
}
