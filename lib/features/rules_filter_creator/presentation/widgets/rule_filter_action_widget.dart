import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_row_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_row_mobile_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_condition_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_delete_button_widget.dart';

class RuleFilterActionWidget extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;
  final EmailRuleFilterAction? actionSelected;
  final Function(EmailRuleFilterAction?)? onActionChanged;
  final Function()? onActionChangeMobile;
  final PresentationMailbox? mailboxSelected;
  final String? errorValue;
  final Function()? tapActionDetailedCallback;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final OnChangeFilterInputAction? onChangeForwardEmail;

  const RuleFilterActionWidget({
    Key? key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.onDeleteRuleConditionAction,
    this.actionSelected,
    this.onActionChanged,
    this.mailboxSelected,
    this.errorValue,
    this.tapActionDetailedCallback,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.onChangeForwardEmail,
    this.onActionChangeMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveUtils.isMobile(context);

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
          actionList: EmailRuleFilterAction.values,
          actionSelected: actionSelected,
          onActionChanged: onActionChanged,
          mailboxSelected: mailboxSelected,
          errorValue: errorValue,
          tapActionDetailedCallback: tapActionDetailedCallback,
          imagePaths: imagePaths,
          onDeleteRuleConditionAction: onDeleteRuleConditionAction,
          forwardEmailEditingController: forwardEmailEditingController,
          forwardEmailFocusNode: forwardEmailFocusNode,
          onChangeForwardEmail: onChangeForwardEmail,
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
                    final borderRadius = value != -1
                        ? BorderRadius.circular(10)
                        : const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    );
                    return Container(
                      padding: const EdgeInsetsDirectional.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.lightGrayF9FAFB,
                        borderRadius: borderRadius,
                      ),
                      alignment: Alignment.center,
                      child: RuleFilterActionRowMobile(
                        imagePaths: imagePaths,
                        actionSelected: actionSelected,
                        mailboxSelected: mailboxSelected,
                        errorValue: errorValue,
                        tapActionDetailedCallback: tapActionDetailedCallback,
                        forwardEmailEditingController: forwardEmailEditingController,
                        forwardEmailFocusNode: forwardEmailFocusNode,
                        onChangeForwardEmail: onChangeForwardEmail,
                        tapActionCallback: onActionChangeMobile,
                      ),
                    );
                  },
                );
              }
          ),
        ),
      );
    }
  }
}
