import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCreateNewIdentityAction = void Function();

class CreateNewIdentityButtonWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final OnCreateNewIdentityAction onCreateNewIdentityAction;
  final EdgeInsetsGeometry? margin;

  const CreateNewIdentityButtonWidget({
    super.key,
    required this.imagePaths,
    required this.onCreateNewIdentityAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget(
      key: const Key('create_new_identity_button'),
      text: AppLocalizations.of(context).createNewIdentity,
      icon: imagePaths.icAddIdentity,
      backgroundColor: AppColor.primaryMain,
      borderRadius: 100,
      height: 48,
      maxWidth: 300,
      margin: margin,
      textStyle: ThemeUtils.textStyleM3LabelLarge(color: Colors.white),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 32,
      ),
      iconSize: 16,
      iconColor: Colors.white,
      iconSpace: 8,
      maxLines: 1,
      flexibleText: true,
      textOverflow: TextOverflow.ellipsis,
      mainAxisSize: MainAxisSize.min,
      onTapActionCallback: onCreateNewIdentityAction,
    );
  }
}
