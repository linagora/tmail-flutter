import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

typedef OnDeleteRuleConditionAction = Function();

class RuleFilterDeleteButtonWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final OnDeleteRuleConditionAction onDeleteRuleConditionAction;
  final EdgeInsetsGeometry? margin;

  const RuleFilterDeleteButtonWidget({
    Key? key,
    required this.imagePaths,
    required this.onDeleteRuleConditionAction,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: imagePaths.icDeleteComposer,
      iconSize: 20,
      iconColor: AppColor.steelGrayA540,
      backgroundColor: Colors.transparent,
      margin: margin,
      onTapActionCallback: onDeleteRuleConditionAction,
    );
  }
}