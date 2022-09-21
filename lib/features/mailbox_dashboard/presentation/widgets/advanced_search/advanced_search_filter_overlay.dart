import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form.dart';

class AdvancedSearchFilterOverlay extends StatelessWidget {

  final double? maxWidth;

  const AdvancedSearchFilterOverlay({
    Key? key,
    this.maxWidth
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: _getHeightOverlay(context, responsiveUtils),
          ),
          width: maxWidth ?? 660,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: AppColor.colorShadowComposer,
                    blurRadius: 32,
                    offset: Offset.zero),
                BoxShadow(
                    color: AppColor.colorDropShadow,
                    blurRadius: 4,
                    offset: Offset.zero),
              ]),
          child: SingleChildScrollView(
            child: AdvancedSearchInputForm(),
          ),
        ),
      ),
    );
  }

  double _getHeightOverlay(BuildContext context, ResponsiveUtils responsiveUtils) {
    const double maxHeightTopBar = 80;
    const double paddingBottom = 16;
    final currentHeight = responsiveUtils.getSizeScreenHeight(context);
    double maxHeightForm = currentHeight - maxHeightTopBar - paddingBottom;
    return maxHeightForm;
  }
}
