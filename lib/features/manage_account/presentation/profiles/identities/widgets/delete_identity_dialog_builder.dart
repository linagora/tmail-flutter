import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnDeleteIdentityAction = void Function();

class DeleteIdentityDialogBuilder extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final OnDeleteIdentityAction onDeleteIdentityAction;

  const DeleteIdentityDialogBuilder({
    Key? key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.onDeleteIdentityAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deleteDialogBuilder = ResponsiveWidget(
      responsiveUtils: responsiveUtils, 
      mobile: (_buildDeleteDialog(context)
          ..alignment(Alignment.bottomCenter)
          ..outsideDialogPadding(EdgeInsets.only(bottom: PlatformInfo.isWeb ? 42 : 16))
          ..widthDialog(MediaQuery.of(context).size.width - 16)
          ..heightDialog(280))
        .build(),
      landscapeMobile: _buildDeleteDialog(context).build(),
      tablet: _buildDeleteDialog(context).build(),
      tabletLarge: _buildDeleteDialog(context).build(),
      landscapeTablet: _buildDeleteDialog(context).build(),
      desktop: _buildDeleteDialog(context).build());

    return PlatformInfo.isWeb
        ? PointerInterceptor(child: deleteDialogBuilder)
        : deleteDialogBuilder;
  }

  ConfirmDialogBuilder _buildDeleteDialog(BuildContext context) {
    return ConfirmDialogBuilder(imagePaths)
        ..key(const Key('confirm_dialog_delete_identity'))
        ..title(AppLocalizations.of(context).delete_identity)
        ..styleTitle(const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.colorActionDeleteConfirmDialog))
        ..paddingTitle(const EdgeInsets.all(0.0))
        ..content(AppLocalizations.of(context).message_confirmation_dialog_delete_identity)
        ..styleContent(const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColor.colorContentEmail))
        ..paddingContent(const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0))
        ..addIcon(Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: SvgPicture.asset(imagePaths.icDeleteDialogIdentity, fit: BoxFit.fill),
        ))
        ..marginIcon(EdgeInsets.zero)
        ..colorCancelButton(AppColor.colorButtonCancelDialog)
        ..styleTextCancelButton(const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColor.colorTextButton))
        ..colorConfirmButton(AppColor.colorActionDeleteConfirmDialog)
        ..styleTextConfirmButton(const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.white))
        ..paddingButton(const EdgeInsets.only(bottom: 24, left: 24, right: 24))
        ..backgroundColor(Colors.black26)
        ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
            onDeleteIdentityAction.call())
        ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack());
  }
}