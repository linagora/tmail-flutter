import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_input_form.dart';

class AdvancedSearchFilterOverlay extends StatelessWidget {

  const AdvancedSearchFilterOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: _getHeightOverlay(context),
          ),
          margin: const EdgeInsetsDirectional.only(top: 4, bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
            ]
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: AdvancedSearchInputForm(),
          ),
        ),
      ),
    );
  }

  double _getHeightOverlay(BuildContext context) {
    const double maxHeightTopBar = 80;
    const double paddingBottom = 16;
    final currentHeight = context.height;
    double maxHeightForm = currentHeight - maxHeightTopBar - paddingBottom;
    return maxHeightForm;
  }
}
