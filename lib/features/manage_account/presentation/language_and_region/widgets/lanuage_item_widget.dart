import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectLanguageAction = Function(Locale? localeSelected);

class LanguageItemWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final Locale localeSelected;
  final Locale localeCurrent;
  final OnSelectLanguageAction onSelectLanguageAction;

  const LanguageItemWidget({
    super.key,
    required this.imagePaths,
    required this.localeCurrent,
    required this.localeSelected,
    required this.onSelectLanguageAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelectLanguageAction.call(localeCurrent),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        hoverColor: AppColor.lightGrayEBEDF0.withOpacity(0.6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          height: 51,
          child: Row(children: [
            Expanded(child: Text(
              '${localeCurrent.getLanguageNameByCurrentLocale(AppLocalizations.of(context))} - ${localeCurrent.getSourceLanguageName()}',
              style: ThemeUtils.textStyleInter400.copyWith(
                letterSpacing: -0.15,
                fontSize: 16,
                height: 21.01 / 16,
                color: AppColor.gray424244.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            if (localeCurrent == localeSelected)
              SvgPicture.asset(
                imagePaths.icChecked,
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              )
          ]),
        ),
      ),
    );
  }
}