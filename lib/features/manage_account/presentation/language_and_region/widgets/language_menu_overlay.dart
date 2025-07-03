import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/lanuage_item_widget.dart';

class LanguageRegionOverlay extends StatelessWidget {

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final List<Locale> listSupportedLanguages;
  final Locale localeSelected;
  final double? maxWidth;
  final OnSelectLanguageAction onSelectLanguageAction;

  const LanguageRegionOverlay({
    Key? key,
    required this.imagePaths,
    required this.listSupportedLanguages,
    required this.responsiveUtils,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: listSupportedLanguages.length,
        padding: const EdgeInsets.all(7),
        itemBuilder: (_, index) => LanguageItemWidget(
          imagePaths: imagePaths,
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
    final currentHeight = responsiveUtils.getSizeScreenHeight(context);
    double maxHeightForm = currentHeight - maxHeightTopBar - maxHeightTitleLanguage - paddingBottom;
    return maxHeightForm;
  }
}