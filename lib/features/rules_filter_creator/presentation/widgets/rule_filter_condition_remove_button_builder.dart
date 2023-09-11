import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return InkWell(
    onTap: tapRemoveRuleFilterConditionCallback,
    child: CircleAvatar(
      backgroundColor: AppColor.colorRemoveRuleFilterConditionButton,
      radius: 22,
      child: SvgPicture.asset(
        imagePath!.icMinimize,
        fit: BoxFit.fill,
        colorFilter: AppColor.colorDeletePermanentlyButton.asFilter(),
      ),
    )
  );
  }
}