import 'package:core/core.dart';
import 'package:flutter/material.dart';
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
          ..widthDialog(MediaQuery.of(context).size.width - 16))
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
    return ConfirmDialogBuilder(imagePaths, useIconAsBasicLogo: true)
        ..key(const Key('confirm_dialog_delete_identity'))
        ..title(AppLocalizations.of(context).delete_identity)
        ..content(AppLocalizations.of(context).message_confirmation_dialog_delete_identity)
        ..onCloseButtonAction(popBack)
        ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
            onDeleteIdentityAction.call())
        ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack());
  }
}