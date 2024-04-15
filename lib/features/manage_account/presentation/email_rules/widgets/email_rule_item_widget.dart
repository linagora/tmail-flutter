import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef EditRuleAction = Function(BuildContext context, TMailRule rule);
typedef DeleteRuleAction = Function(BuildContext context, TMailRule rule);
typedef OpenEditRuleMenuAction = Function(BuildContext context, TMailRule rule);

class EmailRulesItemWidget extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final TMailRule rule;
  final List<MailboxId>? mailboxIds;
  final EditRuleAction? editRuleAction;
  final DeleteRuleAction? deleteRuleAction;
  final OpenEditRuleMenuAction? openEditRuleMenuAction;

  const EmailRulesItemWidget({
    Key? key,
    required this.rule,
    required this.responsiveUtils,
    required this.imagePaths,
    this.mailboxIds,
    this.editRuleAction,
    this.deleteRuleAction,
    this.openEditRuleMenuAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
        bottom: 15,
        left: responsiveUtils.isMobile(context) ? 16 : 24,
        right: responsiveUtils.isMobile(context) ? 0 : 24
      ),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          rule.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black
          )
        ),
        if (_isMailboxAppendInNotExist)
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icQuotasWarning,
            iconSize: 20,
            margin: const EdgeInsetsDirectional.only(start: 4),
            padding: const EdgeInsets.all(3),
            iconColor: AppColor.colorBackgroundQuotasWarning,
            tooltipMessage: AppLocalizations.of(context).warningRuleCannotAppliedWhenTargetFolderNoExist,
            backgroundColor: Colors.transparent,
          ),
        const Spacer(),
        if (!responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                imagePaths.icEditRule,
                fit: BoxFit.fill,
                colorFilter: AppColor.primaryColor.asFilter(),
              ),
              onTap: () {
                editRuleAction?.call(context, rule);
              }),
        if (!responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                imagePaths.icDeleteRule,
                fit: BoxFit.fill,
              ),
              onTap: () {
                deleteRuleAction?.call(context, rule);
              }),
        if (responsiveUtils.isMobile(context))
          buildIconWeb(
              icon: SvgPicture.asset(
                imagePaths.icOpenEditRule,
                fit: BoxFit.fill,
              ),
              iconPadding: const EdgeInsets.all(0),
              onTap: () {
                openEditRuleMenuAction?.call(context, rule);
              }),
      ]),
    );
  }

  bool get _isMailboxAppendInNotExist {
    final ruleMailboxIds= rule.action.appendIn.mailboxIds;

    return mailboxIds != null
      && ruleMailboxIds.isNotEmpty
      && ruleMailboxIds.any((mailboxId) => !mailboxIds!.contains(mailboxId));
  }
}
