import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/semantics/checkbox_semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCheckboxChanged = void Function();

class SetDefaultIdentityCheckboxBuilder extends StatelessWidget {
  final ImagePaths imagePaths;
  final OnCheckboxChanged onCheckboxChanged;
  final bool isCheck;

  const SetDefaultIdentityCheckboxBuilder(
    {Key? key,
    required this.imagePaths,
    required this.onCheckboxChanged,
    required this.isCheck})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CheckboxSemantics(
          label: 'Set default identity checkbox',
          value: isCheck,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onCheckboxChanged,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: AppColor.primaryColor, width: 2.0),
                  color: isCheck ? AppColor.primaryColor : Colors.white,
                ),
                child: SvgPicture.asset(
                  imagePaths.icSelectedSB,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: 18,
                  height: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            AppLocalizations.of(context).setDefaultIdentity,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: AppColor.colorSettingExplanation,
            ),
          ),
        ),
      ],
    );
  }
}
