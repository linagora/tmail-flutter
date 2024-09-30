import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/extensions/locale_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/language_menu_overlay.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/lanuage_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LanguageMenuPopupDialogWidget extends StatefulWidget {

  final Locale languageSelected;
  final OnSelectLanguageAction onSelectLanguageAction;
  final double maxWidth;

  const LanguageMenuPopupDialogWidget({
    super.key,
    required this.languageSelected,
    required this.maxWidth,
    required this.onSelectLanguageAction,
  });

  @override
  State<LanguageMenuPopupDialogWidget> createState() => _LanguageMenuPopupDialogWidgetState();
}

class _LanguageMenuPopupDialogWidgetState extends State<LanguageMenuPopupDialogWidget> {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _visible,
      portalFollower: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => setState(() => _visible = false)
      ),
      child: PortalTarget(
        anchor: const Aligned(
          follower: Alignment.topRight,
          target: Alignment.bottomRight,
          widthFactor: 1,
          backup: Aligned(
            follower: Alignment.topRight,
            target: Alignment.bottomRight,
            widthFactor: 1,
          ),
        ),
        portalFollower: LanguageRegionOverlay(
          listSupportedLanguages: LocalizationService.supportedLocales,
          localeSelected: widget.languageSelected,
          maxWidth: widget.maxWidth,
          onSelectLanguageAction: (locale) {
            setState(() => _visible = false);
            widget.onSelectLanguageAction(locale);
          },
        ),
        visible: _visible,
        child: TMailButtonWidget(
          text: widget.languageSelected.getLanguageNameByCurrentLocale(context),
          icon: _imagePaths.icDropDown,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
          maxWidth: widget.maxWidth,
          iconAlignment: TextDirection.rtl,
          borderRadius: 10,
          expandedText: true,
          backgroundColor: AppColor.colorItemSelected,
          padding: const EdgeInsetsDirectional.all(10),
          border: Border.all(
            color: AppColor.colorInputBorderCreateMailbox,
            width: 0.5,
          ),
          onTapActionCallback: () => setState(() => _visible = true)
        )
      )
    );
  }
}