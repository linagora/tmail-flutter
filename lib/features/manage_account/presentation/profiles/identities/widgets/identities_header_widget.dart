import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_icon_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnAddNewIdentityAction = Function();

class IdentitiesHeaderWidget extends StatelessWidget {

  const IdentitiesHeaderWidget({
    Key? key,
    required this.onAddNewIdentityAction,
  }) : super(key: key);

  final OnAddNewIdentityAction onAddNewIdentityAction;

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).identities,
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.black)),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).identitiesSettingExplanation,
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColor.colorSettingExplanation)),
        const SizedBox(height: 24),
        MaterialTextIconButton(
          key: const Key('button_add_identity'),
          label: AppLocalizations.of(context).createNewIdentity,
          icon: imagePaths.icAddIdentity,
          iconSize: 28,
          minimumSize: const Size(double.infinity, 44),
          onTap: onAddNewIdentityAction
        )
      ]
    );
  }
}