import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NoLabelYetWidget extends StatelessWidget {
  final ImagePaths imagePaths;

  const NoLabelYetWidget({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 352.07),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconNoTag(icon: imagePaths.icNoTag),
            _LabelNoTag(
              text: appLocalizations.noLabelsYet,
              textStyle: ThemeUtils.textStyleInter600(),
              padding: const EdgeInsetsDirectional.only(top: 16),
            ),
            Flexible(
              child: _LabelNoTag(
                text: appLocalizations.noLabelsYetMessageDescriptions,
                textStyle: ThemeUtils.textStyleInter400.copyWith(
                  fontSize: 16,
                  height: 21.01 / 16,
                  letterSpacing: -0.15,
                  color: AppColor.gray424244.withValues(alpha: 0.64),
                ),
                padding: const EdgeInsetsDirectional.only(top: 36),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 186),
              height: 48,
              margin: const EdgeInsetsDirectional.only(top: 16),
              child: ConfirmDialogButton(
                label: AppLocalizations.of(context).createALabel,
                backgroundColor: Colors.white,
                textColor: AppColor.primaryMain,
                borderColor: AppColor.primaryMain,
                icon: imagePaths.icAddIdentity,
                onTapAction: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconNoTag extends StatelessWidget {
  final String icon;

  const _IconNoTag({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      width: 98,
      height: 98,
      fit: BoxFit.fill,
    );
  }
}

class _LabelNoTag extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final EdgeInsetsGeometry? padding;

  const _LabelNoTag({
    required this.text,
    required this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: textStyle,
      textAlign: TextAlign.center,
    );
    if (padding != null) {
      return Padding(padding: padding!, child: textWidget);
    } else {
      return textWidget;
    }
  }
}
