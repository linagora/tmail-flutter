import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rule_item_widget.dart';

class ListEmailRulesWidget extends StatelessWidget {
  final List<TMailRule> listEmailRule;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnEditEmailRuleAction? onEditEmailRuleAction;
  final OnDeleteEmailRuleAction? onDeleteEmailRuleAction;
  final OnMoreEmailRuleAction? onMoreEmailRuleAction;

  const ListEmailRulesWidget({
    Key? key,
    required this.listEmailRule,
    required this.imagePaths,
    required this.responsiveUtils,
    this.onEditEmailRuleAction,
    this.onDeleteEmailRuleAction,
    this.onMoreEmailRuleAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveUtils.isMobile(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 12,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listEmailRule.length,
        primary: false,
        padding: EdgeInsetsDirectional.only(
          bottom: 16,
          start: isMobile ? 16 : 0,
          end: isMobile ? 16 : 0,
        ),
        itemBuilder: (context, index) {
          final ruleWithId = listEmailRule[index].copyWith(
            id: RuleId.fromString(index.toString()),
          );
          return EmailRulesItemWidget(
            rule: ruleWithId,
            responsiveUtils: responsiveUtils,
            imagePaths: imagePaths,
            onEditEmailRuleAction: onEditEmailRuleAction,
            onDeleteEmailRuleAction: onDeleteEmailRuleAction,
            onMoreEmailRuleAction: onMoreEmailRuleAction,
          );
        },
      ),
    );
  }
}
