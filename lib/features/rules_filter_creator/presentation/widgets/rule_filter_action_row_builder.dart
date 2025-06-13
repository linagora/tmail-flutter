import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/styles/rule_filter_action_styles.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_detailed_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_remove_button_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterActionRow extends StatelessWidget {
  final List<EmailRuleFilterAction> actionList;
  final EmailRuleFilterAction? actionSelected;
  final Function(EmailRuleFilterAction?)? onActionChanged;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final Function()? tapActionDetailedCallback;
  final ImagePaths? imagePaths;
  final Function()? tapRemoveActionCallback;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnChangeFilterInputAction? onChangeForwardEmail;

  const RuleFilterActionRow({
    Key? key,
    required this.actionList,
    this.actionSelected,
    this.onActionChanged,
    this.mailboxSelected,
    this.errorValue,
    this.tapActionDetailedCallback,
    this.imagePaths,
    this.tapRemoveActionCallback,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.onChangeForwardEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supportedAction = actionList.where((action) => action.isSupported).toList();
    return Row(
      crossAxisAlignment: actionSelected == EmailRuleFilterAction.moveMessage ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropDownButtonWidget<EmailRuleFilterAction>(
            items: supportedAction,
            itemSelected: actionSelected,
            onChanged: (newAction) => onActionChanged!(newAction),
            supportSelectionIcon: true,
            supportHint: true,
            hintText: AppLocalizations.of(context).selectAction,
          ),
        ),
        actionSelected == EmailRuleFilterAction.moveMessage
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: RuleFilterActionStyles.mainPadding),
              child: Text(
                AppLocalizations.of(context).toFolder,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                maxLines: RuleFilterActionStyles.maxLines,
                style: RuleFilterActionStyles.textStyle,
              ),
            )
          : SizedBox(
              width: actionSelected == EmailRuleFilterAction.forwardTo ? RuleFilterActionStyles.itemDistance : 0,
            ),
        Expanded(
          child: RuleFilterActionDetailed(
            actionType: actionSelected,
            mailboxSelected: mailboxSelected,
            errorValue: errorValue,
            tapActionDetailedCallback: tapActionDetailedCallback,
            forwardEmailEditingController: forwardEmailEditingController,
            forwardEmailFocusNode: forwardEmailFocusNode,
            forwardEmailOnChangeAction: onChangeForwardEmail,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: RuleFilterActionStyles.mainPadding),
          alignment: Alignment.center,
          child: RuleFilterConditionRemoveButton(
            imagePath: imagePaths,
            tapRemoveRuleFilterConditionCallback: tapRemoveActionCallback,
          ),
        )
      ],
    );
  }
}
