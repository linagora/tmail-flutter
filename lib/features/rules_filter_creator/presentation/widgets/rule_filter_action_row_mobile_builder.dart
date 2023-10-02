import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/styles/rule_filter_action_styles.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_detailed_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterActionRowMobile extends StatelessWidget {
  final EmailRuleFilterAction? actionSelected;
  final Function()? tapActionCallback;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final Function()? tapActionDetailedCallback;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnChangeFilterInputAction? onChangeForwardEmail;

  const RuleFilterActionRowMobile({
    Key? key,
    this.actionSelected,
    this.tapActionCallback,
    this.mailboxSelected,
    this.errorValue,
    this.tapActionDetailedCallback,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.onChangeForwardEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuleFilterButtonField<EmailRuleFilterAction>(
          value: actionSelected,
          tapActionCallback: (value) {
            tapActionCallback!();
          },
          hintText: AppLocalizations.of(context).selectAction,
        ),
        actionSelected == EmailRuleFilterAction.moveMessage
          ? Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: RuleFilterActionStyles.mainPadding),
              child: Text(
                AppLocalizations.of(context).toMailbox,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                maxLines: RuleFilterActionStyles.maxLines,
                style: RuleFilterActionStyles.textStyle,
              ),
            )
          : SizedBox(
              height: actionSelected == EmailRuleFilterAction.forwardTo ? RuleFilterActionStyles.itemDistance : 0,
            ),
        RuleFilterActionDetailed(
          actionType: actionSelected,
          mailboxSelected: mailboxSelected,
          errorValue: errorValue,
          tapActionDetailedCallback: tapActionDetailedCallback,
          forwardEmailEditingController: forwardEmailEditingController,
          forwardEmailFocusNode: forwardEmailFocusNode,
          forwardEmailOnChangeAction: onChangeForwardEmail,
        ),
      ],
    );
  }
}
