import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/styles/rule_filter_action_styles.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_row_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_row_mobile_builder.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_field_builder.dart';

class RuleFilterActionWidget extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final Function()? tapRemoveCallback;
  final ImagePaths? imagePaths;
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
    this.tapRemoveCallback,
    this.imagePaths,
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
    return Slidable(
      enabled: responsiveUtils.isMobile(context) ? true : false,
      endActionPane: ActionPane(
        extentRatio: RuleFilterActionStyles.extentRatio,
        motion: const BehindMotion(),
        children: [
          CustomSlidableAction(
            padding: const EdgeInsets.only(right: RuleFilterActionStyles.mainPadding),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(RuleFilterActionStyles.mainBorderRadius),
              bottomRight: Radius.circular(RuleFilterActionStyles.mainBorderRadius),
            ),
            onPressed: (_) => tapRemoveCallback!(),
            backgroundColor: AppColor.colorBackgroundFieldConditionRulesFilter,
            child: CircleAvatar(
              backgroundColor: AppColor.colorRemoveRuleFilterConditionButton,
              radius: RuleFilterActionStyles.removeButtonRadius,
              child: SvgPicture.asset(
                imagePaths!.icMinimize,
                fit: BoxFit.fill,
                colorFilter: AppColor.colorDeletePermanentlyButton.asFilter(),
              ),
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
              var borderRadius = value != -1 
                ? BorderRadius.circular(RuleFilterActionStyles.mainBorderRadius)
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(RuleFilterActionStyles.mainBorderRadius),
                    topLeft: Radius.circular(RuleFilterActionStyles.mainBorderRadius),  
                  );
              return Container(
                padding: const EdgeInsets.all(RuleFilterActionStyles.mainPadding),
                decoration: BoxDecoration(
                  color: AppColor.colorBackgroundFieldConditionRulesFilter,
                  borderRadius: borderRadius,
                ),
                child: responsiveUtils.isMobile(context)
                  ? RuleFilterActionRowMobile(
                      actionSelected: actionSelected,
                      mailboxSelected: mailboxSelected,
                      errorValue: errorValue,
                      tapActionDetailedCallback: tapActionDetailedCallback,
                      forwardEmailEditingController: forwardEmailEditingController,
                      forwardEmailFocusNode: forwardEmailFocusNode,
                      onChangeForwardEmail: onChangeForwardEmail,
                      tapActionCallback: onActionChangeMobile,
                    )
                  : RuleFilterActionRow(
                      actionList: EmailRuleFilterAction.values,
                      actionSelected: actionSelected,
                      onActionChanged: onActionChanged,
                      mailboxSelected: mailboxSelected,
                      errorValue: errorValue,
                      tapActionDetailedCallback: tapActionDetailedCallback,
                      imagePaths: imagePaths,
                      tapRemoveActionCallback: tapRemoveCallback,
                      forwardEmailEditingController: forwardEmailEditingController,
                      forwardEmailFocusNode: forwardEmailFocusNode,
                      onChangeForwardEmail: onChangeForwardEmail,
                    )
              );
            },
          );
        }
      ),
    );
  }
}
