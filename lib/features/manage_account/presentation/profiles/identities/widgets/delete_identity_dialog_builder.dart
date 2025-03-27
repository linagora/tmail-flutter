import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/platform_info.dart';
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
    final appLocalizations = AppLocalizations.of(context);
    final deleteDialogBuilder = ResponsiveWidget(
      responsiveUtils: responsiveUtils, 
      mobile: _buildDeleteDialog(
        appLocalizations: appLocalizations,
        alignment: Alignment.bottomCenter,
        outsideDialogPadding: EdgeInsets.only(bottom: PlatformInfo.isWeb ? 42 : 16),
        widthDialog: MediaQuery.of(context).size.width - 16,
      ),
      landscapeMobile: _buildDeleteDialog(appLocalizations: appLocalizations),
      tablet: _buildDeleteDialog(appLocalizations: appLocalizations),
      tabletLarge: _buildDeleteDialog(appLocalizations: appLocalizations),
      landscapeTablet: _buildDeleteDialog(appLocalizations: appLocalizations),
      desktop: _buildDeleteDialog(appLocalizations: appLocalizations),
    );

    return PlatformInfo.isWeb
        ? PointerInterceptor(child: deleteDialogBuilder)
        : deleteDialogBuilder;
  }

  ConfirmationDialogBuilder _buildDeleteDialog({
    required AppLocalizations appLocalizations,
    Alignment? alignment,
    EdgeInsets? outsideDialogPadding,
    double? widthDialog,
  }) {
    return ConfirmationDialogBuilder(
      key: const Key('confirm_dialog_delete_identity'),
      imagePath: imagePaths,
      title: appLocalizations.delete_identity,
      textContent: appLocalizations.message_confirmation_dialog_delete_identity,
      cancelText: appLocalizations.delete,
      confirmText: appLocalizations.cancel,
      alignment: alignment,
      outsideDialogPadding: outsideDialogPadding,
      widthDialog: widthDialog,
      onCancelButtonAction: onDeleteIdentityAction,
      onConfirmButtonAction: popBack,
      onCloseButtonAction: popBack,
    );
  }
}