
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ChangeLanguageWidget extends StatelessWidget {

  final _controller = Get.find<LanguageAndRegionController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  ChangeLanguageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleLanguageWidget = Text(
        AppLocalizations.of(context).language,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.colorContentEmail));

    final dropDownMenuSelectLanguage = Row(children: [
      Expanded(child: Obx(() =>
        DropDownButtonWidget<Locale>(
          items: _controller.listSupportedLanguages,
          itemSelected: _controller.languageSelected.value,
          onChanged: (newLanguage) =>
              _controller.selectLanguage(newLanguage),
          supportSelectionIcon: true))),
    ]);

    return LayoutBuilder(builder: (context, constraints) {
      return ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleLanguageWidget,
              const SizedBox(height: 8),
              dropDownMenuSelectLanguage
            ]
          )),
        desktop: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleLanguageWidget,
            const SizedBox(height: 8),
            SizedBox(
              width: constraints.maxWidth / 2,
              child: dropDownMenuSelectLanguage
            ),
          ]));
    });
  }
}