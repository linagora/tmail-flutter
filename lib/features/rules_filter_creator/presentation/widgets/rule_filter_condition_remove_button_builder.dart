import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class RuleFilterConditionRemoveButton extends StatelessWidget {
  final Function()? tapRemoveRuleFilterConditionCallback;
  final ImagePaths? imagePath;

  const RuleFilterConditionRemoveButton({
    Key? key,
    this.tapRemoveRuleFilterConditionCallback,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: imagePath!.icRemoveRule,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      onTapActionCallback: tapRemoveRuleFilterConditionCallback,
    );
  }
}