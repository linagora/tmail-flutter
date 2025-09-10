import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_row_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_row_mobile_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';

class RuleFilterActionWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final bool isMobile;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;
  final EmailRuleFilterAction? actionSelected;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final VoidCallback? onTapActionDetailedCallback;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnTextChange? onChangeForwardEmail;
  final OnActionChanged? onActionChanged;
  final VoidCallback? onActionChangeMobile;

  const RuleFilterActionWidget({
    Key? key,
    required this.imagePaths,
    required this.isMobile,
    required this.onDeleteRuleConditionAction,
    this.actionSelected,
    this.mailboxSelected,
    this.errorValue,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.onChangeForwardEmail,
    this.onActionChangeMobile,
    this.onTapActionDetailedCallback,
    this.onActionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isMobile) {
      return Container(
        padding: const EdgeInsetsDirectional.only(start: 12),
        margin: const EdgeInsetsDirectional.only(top: 8),
        decoration: const BoxDecoration(
          color: AppColor.lightGrayF9FAFB,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        height: 72,
        alignment: Alignment.center,
        child: RuleFilterActionRow(
          actionList: EmailRuleFilterAction.values
              .where((action) => action.isSupported)
              .toList(),
          actionSelected: actionSelected,
          onActionChanged: onActionChanged,
          mailboxSelected: mailboxSelected,
          errorValue: errorValue,
          imagePaths: imagePaths,
          onDeleteRuleConditionAction: onDeleteRuleConditionAction,
          forwardEmailEditingController: forwardEmailEditingController,
          forwardEmailFocusNode: forwardEmailFocusNode,
          onChangeForwardEmail: onChangeForwardEmail,
          onTapActionDetailedCallback: onTapActionDetailedCallback,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 8),
        child: Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.15,
            motion: const BehindMotion(),
            children: [
              CustomSlidableAction(
                padding: const EdgeInsets.only(right: 12),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                onPressed: (_) => onDeleteRuleConditionAction(),
                backgroundColor: AppColor.lightGrayF9FAFB,
                child: RuleFilterDeleteButtonWidget(
                  imagePaths: imagePaths,
                  onDeleteRuleConditionAction: onDeleteRuleConditionAction,
                ),
              )
            ],
          ),
          child: Builder(
            builder: (context) {
              SlidableController? slideController = Slidable.of(context);
              return ValueListenableBuilder<int>(
                valueListenable: slideController?.direction ?? ValueNotifier<int>(0),
                builder: (context, value, _) {
                  return Container(
                    padding: const EdgeInsetsDirectional.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.lightGrayF9FAFB,
                      borderRadius: value != -1
                          ? BorderRadius.circular(10)
                          : const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                    ),
                    alignment: Alignment.center,
                    child: RuleFilterActionRowMobile(
                      imagePaths: imagePaths,
                      actionSelected: actionSelected,
                      mailboxSelected: mailboxSelected,
                      errorValue: errorValue,
                      forwardEmailEditingController: forwardEmailEditingController,
                      forwardEmailFocusNode: forwardEmailFocusNode,
                      onChangeForwardEmail: onChangeForwardEmail,
                      onTapActionCallback: onActionChangeMobile,
                      onTapActionDetailedCallback: onTapActionDetailedCallback,
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }
}
