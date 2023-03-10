import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

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
        Material(
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
                )),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: AppUtils.isDirectionRTL(context) ? 0 : 8,
            right: AppUtils.isDirectionRTL(context) ? 8 : 0,
          ),
          child: Text(
            AppLocalizations.of(context).setDefaultIdentity,
            style: const TextStyle(
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
