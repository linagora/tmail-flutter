import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NoLabelYetWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final VoidCallback onCreateALabelAction;

  const NoLabelYetWidget({
    super.key,
    required this.imagePaths,
    required this.onCreateALabelAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 352),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(height: 16),
              _buildTitle(appLocalizations),
              const SizedBox(height: 36),
              _buildDescription(appLocalizations),
              const SizedBox(height: 16),
              _buildCreateButton(appLocalizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      imagePaths.icNoTag,
      width: 98,
      height: 98,
      fit: BoxFit.fill,
    );
  }

  Widget _buildTitle(AppLocalizations localizations) {
    return Text(
      localizations.noLabelsYet,
      textAlign: TextAlign.center,
      style: ThemeUtils.textStyleInter600(),
    );
  }

  Widget _buildDescription(AppLocalizations localizations) {
    return Text(
      localizations.noLabelsYetMessageDescriptions,
      textAlign: TextAlign.center,
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 16,
        height: 21.01 / 16,
        letterSpacing: -0.15,
        color: AppColor.gray424244.withValues(alpha: 0.64),
      ),
    );
  }

  Widget _buildCreateButton(AppLocalizations localizations) {
    return Container(
      constraints: const BoxConstraints(minWidth: 186),
      height: 48,
      child: ConfirmDialogButton(
        label: localizations.createALabel,
        backgroundColor: Colors.white,
        textColor: AppColor.primaryMain,
        borderColor: AppColor.primaryMain,
        icon: imagePaths.icAddIdentity,
        onTapAction: onCreateALabelAction,
      ),
    );
  }
}