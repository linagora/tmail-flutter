import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_button_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class RuleFilterActionDetailed extends StatelessWidget {
  final ImagePaths imagePaths;
  final EmailRuleFilterAction? actionType;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnTextChange? forwardEmailOnChangeAction;
  final VoidCallback? onTapActionDetailedCallback;

  const RuleFilterActionDetailed({
    Key? key,
    required this.imagePaths,
    this.actionType,
    this.mailboxSelected,
    this.errorValue,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.forwardEmailOnChangeAction,
    this.onTapActionDetailedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (actionType) {
      case EmailRuleFilterAction.moveMessage:
        return RuleFilterButtonField<PresentationMailbox>(
          value: mailboxSelected,
          imagePaths: imagePaths,
          borderColor: errorValue?.isNotEmpty == true
            ? AppColor.redFF3347
            : AppColor.m3Neutral90,
          onTapActionCallback: (_) => onTapActionDetailedCallback?.call(),
        );
      case EmailRuleFilterAction.forwardTo:
        return DefaultInputFieldWidget(
          errorText: errorValue,
          hintText: AppLocalizations.of(context).forwardEmailHintText,
          textEditingController: forwardEmailEditingController!,
          focusNode: forwardEmailFocusNode,
          inputColor: Colors.black,
          onTextChange: forwardEmailOnChangeAction,
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
