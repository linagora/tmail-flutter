import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_detailed_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterActionRowMobile extends StatelessWidget {
  final ImagePaths imagePaths;
  final EmailRuleFilterAction? actionSelected;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnTextChange? onChangeForwardEmail;
  final VoidCallback? onTapActionDetailedCallback;
  final VoidCallback? onTapActionCallback;

  const RuleFilterActionRowMobile({
    Key? key,
    required this.imagePaths,
    this.actionSelected,
    this.mailboxSelected,
    this.errorValue,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.onChangeForwardEmail,
    this.onTapActionDetailedCallback,
    this.onTapActionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuleFilterButtonField<EmailRuleFilterAction>(
          value: actionSelected,
          imagePaths: imagePaths,
          onTapActionCallback: (_) => onTapActionCallback?.call(),
          hintText: AppLocalizations.of(context).selectAction,
        ),
        actionSelected == EmailRuleFilterAction.moveMessage
          ? Container(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
            )
          : SizedBox(
              height: actionSelected?.isForwardTo == true ? 12 : 0,
            ),
        RuleFilterActionDetailed(
          imagePaths: imagePaths,
          actionType: actionSelected,
          mailboxSelected: mailboxSelected,
          errorValue: errorValue,
          forwardEmailEditingController: forwardEmailEditingController,
          forwardEmailFocusNode: forwardEmailFocusNode,
          forwardEmailOnChangeAction: onChangeForwardEmail,
          onTapActionDetailedCallback: onTapActionDetailedCallback,
        ),
      ],
    );
  }
}
