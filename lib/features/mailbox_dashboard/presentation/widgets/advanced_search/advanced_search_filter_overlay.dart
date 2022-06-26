import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form.dart';

class AdvancedSearchFilterOverlay extends StatelessWidget {
  const AdvancedSearchFilterOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 660,
      height: 558,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5)),
        ]
      ),
      child: AdvancedSearchInputForm(),
    );
  }
}
