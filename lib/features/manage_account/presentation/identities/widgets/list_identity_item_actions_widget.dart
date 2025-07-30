import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEditIdentityAction = Function(Identity identity);
typedef OnDeleteIdentityAction = Function(Identity identity);

class ListIdentityItemActionsWidget extends StatelessWidget {
  final Identity identity;
  final ImagePaths imagePaths;
  final OnEditIdentityAction onEditIdentityAction;
  final OnDeleteIdentityAction onDeleteIdentityAction;
  final bool isDesktop;

  const ListIdentityItemActionsWidget({
    super.key,
    required this.identity,
    required this.imagePaths,
    required this.onEditIdentityAction,
    required this.onDeleteIdentityAction,
    this.isDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TMailButtonWidget(
          icon: imagePaths.icCompose,
          iconSize: 20,
          text: AppLocalizations.of(context).edit,
          backgroundColor: Colors.transparent,
          iconColor: AppColor.primaryColor,
          textStyle: ThemeUtils.textStyleInter500().copyWith(
            fontSize: 13,
            height: 1,
            letterSpacing: 0.39,
            color: AppColor.primaryColor,
          ),
          flexibleText: true,
          minWidth: 100,
          mainAxisSize: MainAxisSize.min,
          maxLines: 1,
          iconSpace: 4,
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: 5,
            horizontal: 8,
          ),
          onTapActionCallback: () => onEditIdentityAction(identity),
        ),
        TMailButtonWidget(
          icon: imagePaths.icDeleteRule,
          iconSize: 20,
          text: AppLocalizations.of(context).delete,
          backgroundColor: Colors.transparent,
          iconColor: AppColor.primaryColor,
          textStyle: ThemeUtils.textStyleInter500().copyWith(
            fontSize: 13,
            height: 1,
            letterSpacing: 0.39,
            color: AppColor.primaryColor,
          ),
          minWidth: 100,
          flexibleText: true,
          mainAxisSize: MainAxisSize.min,
          maxLines: 1,
          iconSpace: 4,
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: 5,
            horizontal: 8,
          ),
          onTapActionCallback: () => onDeleteIdentityAction(identity),
        ),
      ],
    );
  }
}
