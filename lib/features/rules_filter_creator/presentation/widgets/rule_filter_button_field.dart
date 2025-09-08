
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/email_rule_filter_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnRuleTapActionCallback<T> = Function(T? value);

class RuleFilterButtonField<T> extends StatelessWidget {

  final T? value;
  final OnRuleTapActionCallback onTapActionCallback;
  final ImagePaths imagePaths;
  final Color? borderColor;
  final String? hintText;

  const RuleFilterButtonField({
    super.key,
    required this.value,
    required this.imagePaths,
    required this.onTapActionCallback,
    this.borderColor,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onTapActionCallback(value),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: borderColor ?? AppColor.m3Neutral90,
              width: 1,
            ),
            color: Colors.white
          ),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
          child: Row(children: [
            Expanded(child: Text(
              _getName(context, value),
              style: ThemeUtils.textStyleBodyBody3(
                color: value != null
                  ? Colors.black
                  : AppColor.textFieldHintColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            SvgPicture.asset(imagePaths.icDropDown)
          ]),
        ),
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