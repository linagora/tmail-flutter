import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form.dart';

class AdvancedSearchFilterOverlay extends StatelessWidget {

  const AdvancedSearchFilterOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Container(
        constraints: BoxConstraints(
          minWidth: 660,
          maxHeight: _getHeightOverlay(context, responsiveUtils),
        ),
        width: 660,
        height: _getHeightOverlay(context, responsiveUtils),
        padding: responsiveUtils.landscapeTabletSupported(context)
          ? EdgeInsets.zero
          : const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: AppColor.colorShadowBgContentEmail,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 0.5)),
            ]),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: responsiveUtils.landscapeTabletSupported(context)
                    ? 16 : 28,
                vertical: responsiveUtils.landscapeTabletSupported(context)
                    ? 16 : 12),
            child: AdvancedSearchInputForm(),
          ),
        ),
      ),
    );
  }

  double _getHeightOverlay(BuildContext context, ResponsiveUtils responsiveUtils) {
    const double maxHeightTopBar = 160;
    const double maxHeightOverlay = 568;
    final currentHeight = responsiveUtils.getSizeScreenHeight(context);
    double maxHeightForm = maxHeightOverlay;

    if (currentHeight < maxHeightOverlay) {
      maxHeightForm = currentHeight > maxHeightTopBar
          ? currentHeight - maxHeightTopBar
          : currentHeight;
    }

    log('AdvancedSearchFilterOverlay::_getHeightOverlay(): maxHeightForm: $maxHeightForm');
    return maxHeightForm;
  }
}
