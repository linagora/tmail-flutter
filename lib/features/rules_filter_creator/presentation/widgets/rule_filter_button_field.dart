
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnTapActionCallback<T> = Function(T? value);

class RuleFilterButtonField<T> extends StatelessWidget {

  final T? value;
  final OnTapActionCallback? tapActionCallback;
  final Color? borderColor;
  final String? hintText;

  const RuleFilterButtonField({
    super.key,
    this.value,
    this.tapActionCallback,
    this.borderColor,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    final Color textColor = value != null ? Colors.black : AppColor.textFieldHintColor;

    return InkWell(
      onTap: () => tapActionCallback?.call(value),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: borderColor ?? AppColor.colorInputBorderCreateMailbox,
                width: 1),
            color: Colors.white),
        padding: const EdgeInsets.only(left: 12, right: 10),
        child: Row(children: [
          Expanded(child: Text(
            _getName(context, value),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: textColor),
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
          )),
          SvgPicture.asset(imagePaths.icDropDown)
        ]),
      ),
    );
  }

  String _getName(BuildContext context, T? value) {
    final appLocalizations = AppLocalizations.of(context);

    if (value is PresentationMailbox) {
      return value.getDisplayName(context);
    }
    if (value is rule_condition.Field) {
      return value.getTitle(appLocalizations);
    }
    if (value is rule_condition.Comparator) {
      return value.getTitle(appLocalizations);
    }
    if (value is EmailRuleFilterAction) {
      return value.getTitle(appLocalizations);
    }
    if (value is ConditionCombiner) {
      return value.getTitle(appLocalizations);
    }
    return hintText ?? '';
  }
}