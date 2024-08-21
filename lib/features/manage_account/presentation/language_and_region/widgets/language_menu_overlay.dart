
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/lanuage_item_widget.dart';

class LanguageRegionOverlay extends StatelessWidget {

  final List<Locale> listSupportedLanguages;
  final Locale localeSelected;
  final double? maxWidth;
  final OnSelectLanguageAction onSelectLanguageAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  LanguageRegionOverlay({
    Key? key,
    required this.listSupportedLanguages,
    required this.localeSelected,
    required this.onSelectLanguageAction,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: _getHeightOverlay(context)),
      width: maxWidth,
      margin: const EdgeInsets.only(top: 4, bottom: 24),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            blurRadius: 24,
            offset: Offset(0, 8)),
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            blurRadius: 2,
            offset: Offset.zero),
          ]
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listSupportedLanguages.length,
        itemBuilder: (context, index) => LanguageItemWidget(
          localeSelected: localeSelected,
          localeCurrent: listSupportedLanguages[index],
          onSelectLanguageAction: onSelectLanguageAction
        )
      ),
    );
  }

  double _getHeightOverlay(BuildContext context) {
    const double maxHeightTopBar = 80;
    const double maxHeightTitleLanguage = 200;
    const double paddingBottom = 16;
    final currentHeight = _responsiveUtils.getSizeScreenHeight(context);
    double maxHeightForm = currentHeight - maxHeightTopBar - maxHeightTitleLanguage - paddingBottom;
    return maxHeightForm;
  }
}