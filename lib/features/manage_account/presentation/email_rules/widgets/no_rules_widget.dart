
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/add_rule_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NoRulesWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnAddRuleAction onAddRuleAction;

  const NoRulesWidget({
    super.key,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onAddRuleAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final isMobile = responsiveUtils.isMobile(context);
    final isDesktop = responsiveUtils.isDesktop(context);

    return Expanded(
      child: Container(
        padding: EdgeInsetsDirectional.only(top: isMobile ? 48 : 32),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                imagePaths.icNoRules,
                width: 98,
                height: 98,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 12),
              Text(
                appLocalizations.noRulesConfigured,
                style: ThemeUtils.textStyleInter600(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                appLocalizations.messageExplanationNoRulesConfigured,
                style: ThemeUtils.textStyleInter400.copyWith(
                  fontSize: 16,
                  height: 21.01 / 16,
                  letterSpacing: -0.15,
                  color: AppColor.gray424244.withValues(alpha: 0.64),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(minWidth: 230),
                height: 48,
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: isDesktop ? 0 : 16,
                ),
                child: ConfirmDialogButton(
                  label: AppLocalizations.of(context).createMyFirstRule,
                  backgroundColor: Colors.white,
                  textColor: AppColor.primaryMain,
                  borderColor: AppColor.primaryMain,
                  icon: imagePaths.icAddIdentity,
                  onTapAction: onAddRuleAction,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
