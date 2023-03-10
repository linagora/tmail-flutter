
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';

typedef OnSelectLanguageAction = Function(Locale? localeSelected);

class LanguageItemWidget extends StatelessWidget {

  final Locale localeSelected;
  final Locale localeCurrent;
  final OnSelectLanguageAction onSelectLanguageAction;

  const LanguageItemWidget({
    super.key,
    required this.localeCurrent,
    required this.localeSelected,
    required this.onSelectLanguageAction,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelectLanguageAction.call(localeCurrent),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(children: [
            Expanded(child: Text(
              localeCurrent.getLanguageName(context),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal,
                color: Colors.black
              ),
              maxLines: 1,
              softWrap: CommonTextStyle.defaultSoftWrap,
              overflow: CommonTextStyle.defaultTextOverFlow,
            )),
            if (localeCurrent == localeSelected)
              SvgPicture.asset(
                imagePaths.icChecked,
                width: 20,
                height: 20,
                fit: BoxFit.fill
              )
          ]),
        ),
      ),
    );
  }
}