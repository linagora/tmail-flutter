import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnActionChanged = Function(EmailRuleFilterAction? action);

class RuleFilterActionRow extends StatelessWidget {
  final List<EmailRuleFilterAction> actionList;
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;
  final EmailRuleFilterAction? actionSelected;
  final OnActionChanged? onActionChanged;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnTextChange? onChangeForwardEmail;
  final VoidCallback? onTapActionDetailedCallback;

  const RuleFilterActionRow({
    Key? key,
    required this.actionList,
    required this.imagePaths,
    required this.onDeleteRuleConditionAction,
    this.actionSelected,
    this.onActionChanged,
    this.mailboxSelected,
    this.errorValue,
    this.onTapActionDetailedCallback,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.onChangeForwardEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropDownButtonWidget<EmailRuleFilterAction>(
            items: actionList,
            itemSelected: actionSelected,
            onChanged: (newAction) => onActionChanged!(newAction),
            supportSelectionIcon: true,
            supportHint: true,
            labelTextStyle: ThemeUtils.textStyleBodyBody3(
              color: Colors.black,
            ),
            heightItem: 40,
            hintTextStyle: ThemeUtils.textStyleBodyBody3(
              color: AppColor.steelGray400,
            ),
            hintText: AppLocalizations.of(context).selectAction,
          ),
        ),
        if (actionSelected == EmailRuleFilterAction.moveMessage)
          ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                AppLocalizations.of(context).toFolder,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: ThemeUtils.textStyleInter400.copyWith(
                  fontSize: 14,
                  height: 18 / 14,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: RuleFilterButtonField<PresentationMailbox>(
                value: mailboxSelected,
                imagePaths: imagePaths,
                borderColor: errorValue?.isNotEmpty == true
                  ? AppColor.redFF3347
                  : AppColor.m3Neutral90,
                onTapActionCallback: (_) => onTapActionDetailedCallback?.call(),
              ),
            ),
          ]
        else if (actionSelected?.isForwardTo == true)
          Expanded(
            child: DefaultInputFieldWidget(
              errorText: errorValue,
              hintText: AppLocalizations.of(context).forwardEmailHintText,
              textEditingController: forwardEmailEditingController!,
              focusNode: forwardEmailFocusNode,
              inputColor: Colors.black,
              onTextChange: onChangeForwardEmail,
            ),
          ),
        RuleFilterDeleteButtonWidget(
          imagePaths: imagePaths,
          onDeleteRuleConditionAction: onDeleteRuleConditionAction,
        ),
      ],
    );
  }
}
