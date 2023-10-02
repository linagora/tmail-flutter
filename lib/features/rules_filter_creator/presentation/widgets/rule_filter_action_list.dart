import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_widget.dart';

class RuleFilterActionListWidget extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final List<RuleFilterActionArguments> actionList;
  final Function(EmailRuleFilterAction?, int)? onActionChangeMobile;
  final Function(EmailRuleFilterAction?, int)? onActionChanged;
  final TextEditingController? forwardEmailEditingController;
  final FocusNode? forwardEmailFocusNode;
  final Function(int)? tapActionDetailedCallback;
  final Function(int)? tapRemoveCallback;
  final ImagePaths? imagePaths;
  final Function(String?, int)? onChangeForwardEmail;
  final String? errorForwardEmail;
  final String? errorMailboxSelected;

  const RuleFilterActionListWidget({
    Key? key,
    required this.responsiveUtils,
    required this.actionList,
    this.onActionChangeMobile,
    this.onActionChanged,
    this.forwardEmailEditingController,
    this.forwardEmailFocusNode,
    this.tapActionDetailedCallback,
    this.tapRemoveCallback,
    this.imagePaths,
    this.onChangeForwardEmail,
    this.errorForwardEmail,
    this.errorMailboxSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: actionList.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12,);
        },
        itemBuilder: (context, index) {
          final RuleFilterActionArguments currentAction = actionList[index];
          String? errorValue;
          if (currentAction is ForwardActionArguments) {
            errorValue = errorForwardEmail;
          } else {
            errorValue = errorMailboxSelected;
          }
          return RuleFilterActionWidget(
            responsiveUtils: responsiveUtils,
            mailboxSelected: currentAction is MoveMessageActionArguments ? currentAction.mailbox : null,
            errorValue: errorValue,
            onActionChangeMobile: () {
              onActionChangeMobile!(currentAction.action, index);
            },
            onActionChanged: (newAction) {
              if (newAction != currentAction.action) {
                onActionChanged!(newAction, index);
              }
            },
            forwardEmailEditingController: currentAction.action == EmailRuleFilterAction.forwardTo ? forwardEmailEditingController : null,
            forwardEmailFocusNode: currentAction.action == EmailRuleFilterAction.forwardTo ? forwardEmailFocusNode : null,
            onChangeForwardEmail: (value) => onChangeForwardEmail!(value, index),
            actionSelected: currentAction.action,
            tapActionDetailedCallback: () => tapActionDetailedCallback!(index),
            tapRemoveCallback: () => tapRemoveCallback!(index),
            imagePaths: imagePaths,
          );
        },
      );
    });
  }
}
