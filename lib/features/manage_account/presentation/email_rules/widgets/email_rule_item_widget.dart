import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/tmail_rule_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEditEmailRuleAction = Function(TMailRule rule);
typedef OnDeleteEmailRuleAction = Function(TMailRule rule);
typedef OnMoreEmailRuleAction = Function(TMailRule rule);

class EmailRulesItemWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final TMailRule rule;
  final OnEditEmailRuleAction? onEditEmailRuleAction;
  final OnDeleteEmailRuleAction? onDeleteEmailRuleAction;
  final OnMoreEmailRuleAction? onMoreEmailRuleAction;

  const EmailRulesItemWidget({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.rule,
    this.onEditEmailRuleAction,
    this.onDeleteEmailRuleAction,
    this.onMoreEmailRuleAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveUtils.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.lightGrayF9FAFB,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      height: 72,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
      margin: const EdgeInsetsDirectional.only(top: 8),
      child: Row(
        children: [
          if (!isMobile) ...[
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.width / 2),
              child: Text(
                rule.name,
                style: ThemeUtils.textStyleBodyBody3(
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.gray49454F.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      margin: const EdgeInsetsDirectional.symmetric(
                        horizontal: 24,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: Text(
                        rule.getPreview(AppLocalizations.of(context)),
                        style: ThemeUtils.textStyleBodyBody3(
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icEdit,
              iconSize: 20,
              iconColor: AppColor.steelGrayA540,
              backgroundColor: Colors.transparent,
              margin: const EdgeInsetsDirectional.only(end: 12),
              onTapActionCallback: () => onEditEmailRuleAction?.call(rule),
            ),
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icDeleteComposer,
              iconSize: 20,
              iconColor: AppColor.steelGrayA540,
              backgroundColor: Colors.transparent,
              onTapActionCallback: () => onDeleteEmailRuleAction?.call(rule),
            ),
          ] else ...[
            Expanded(
              child: Text(
                rule.name,
                style: ThemeUtils.textStyleBodyBody3(
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icMoreVertical,
              iconSize: 20,
              iconColor: AppColor.steelGrayA540,
              backgroundColor: Colors.transparent,
              onTapActionCallback: () => onMoreEmailRuleAction?.call(rule),
            ),
          ],
        ],
      ),
    );
  }
}
