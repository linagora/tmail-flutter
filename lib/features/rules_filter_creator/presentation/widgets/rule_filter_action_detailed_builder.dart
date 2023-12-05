import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterActionDetailed extends StatelessWidget {
  final EmailRuleFilterAction? actionType;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final Function()? tapActionDetailedCallback;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnChangeFilterInputAction? forwardEmailOnChangeAction;

  const RuleFilterActionDetailed({
    Key? key,
    this.actionType,
    this.mailboxSelected,
    this.errorValue,
    this.tapActionDetailedCallback,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.forwardEmailOnChangeAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = errorValue?.isNotEmpty == true ? AppColor.colorInputBorderErrorVerifyName : AppColor.colorInputBorderCreateMailbox;
    switch (actionType) {
      case EmailRuleFilterAction.moveMessage:
        return RuleFilterButtonField<PresentationMailbox>(
          value: mailboxSelected,
          borderColor: borderColor,
          tapActionCallback: (value) {
            tapActionDetailedCallback!();
          },
        );
      case EmailRuleFilterAction.forwardTo:
        return RulesFilterInputField(
          errorText: errorValue,
          hintText: AppLocalizations.of(context).forwardEmailHintText,
          editingController: forwardEmailEditingController,
          focusNode: forwardEmailFocusNode,
          onChangeAction: forwardEmailOnChangeAction,
        );
      case EmailRuleFilterAction.maskAsSeen:
      case EmailRuleFilterAction.starIt:
      case EmailRuleFilterAction.rejectIt:
      case EmailRuleFilterAction.markAsSpam:
      default:
        return const SizedBox.shrink();
    }
  }
}
