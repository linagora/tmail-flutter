import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnAddNewIdentityAction = Function();

class IdentitiesHeaderWidget extends StatelessWidget {

  const IdentitiesHeaderWidget({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
    this.onAddNewIdentityAction,
  }) : super(key: key);

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnAddNewIdentityAction? onAddNewIdentityAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          AppLocalizations.of(context).identities,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.black)),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).identitiesSettingExplanation,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColor.colorSettingExplanation)),
        const SizedBox(height: 24),
        (ButtonBuilder(imagePaths.icAddIdentity)
          ..key(const Key('button_add_identity'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColor.colorCreateNewIdentityButton))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..iconColor(AppColor.colorTextButton)
          ..size(28)
          ..radiusSplash(12)
          ..padding(const EdgeInsets.symmetric(vertical: 10))
          ..textStyle(const TextStyle(
              fontSize: 16,
              color: AppColor.colorTextButton,
              fontWeight: FontWeight.w500))
          ..onPressActionClick(() => onAddNewIdentityAction?.call())
          ..text(AppLocalizations.of(context).createNewIdentity, isVertical: false)
        ).build()
      ]),
    );
  }
}